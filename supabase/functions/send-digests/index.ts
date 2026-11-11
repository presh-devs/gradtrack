// send-digests: the daily email digest (docs/spec/06-digest.md).
//
// Two ways in:
//   * Cron (pg_cron → pg_net, every 15 min): `Authorization: Bearer <CRON_SECRET>`.
//     Claims every user whose local digest hour has arrived today, sends each
//     one digest, and records the outcome. claim_due_digests() guarantees one
//     digest per user per local day; the run id doubles as Resend's
//     idempotency key, so a retry can't send twice.
//   * Settings → "Send test digest": the signed-in user's JWT and
//     `{"test": true}`. Sends that user's digest now, without bookkeeping.
//
// Secrets: SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY (provided by Supabase),
// RESEND_API_KEY, CRON_SECRET, APP_BASE_URL, DIGEST_FROM.
//
// Deployed with verify_jwt = false (supabase/config.toml): the cron secret
// isn't a JWT, so this function checks both kinds of caller itself.

import { createClient, type SupabaseClient } from "jsr:@supabase/supabase-js@2";
import { type FeedItem, renderDigest } from "./render.ts";

const cors = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

const json = (body: unknown, status = 200) =>
  new Response(JSON.stringify(body), { status, headers: { ...cors, "Content-Type": "application/json" } });

const env = (name: string) => Deno.env.get(name) ?? "";

type Claimed = {
  run_id: string;
  owner_id: string;
  email: string | null;
  display_name: string | null;
  timezone: string;
  digest_date: string;
  send_when_empty: boolean;
};

async function feedFor(admin: SupabaseClient, owner: string): Promise<FeedItem[]> {
  const { data, error } = await admin.rpc("attention_feed_for", { p_owner: owner, p_horizon: "14 days" });
  if (error) throw new Error(`feed: ${error.message}`);
  return (data ?? []) as FeedItem[];
}

/** Sends through Resend; returns the provider message id. */
async function sendEmail(
  to: string,
  digest: { subject: string; html: string; text: string },
  idempotencyKey?: string,
): Promise<string> {
  const res = await fetch("https://api.resend.com/emails", {
    method: "POST",
    headers: {
      Authorization: `Bearer ${env("RESEND_API_KEY")}`,
      "Content-Type": "application/json",
      ...(idempotencyKey ? { "Idempotency-Key": idempotencyKey } : {}),
    },
    body: JSON.stringify({
      from: env("DIGEST_FROM"),
      to: [to],
      subject: digest.subject,
      html: digest.html,
      text: digest.text,
    }),
  });
  const body = await res.json().catch(() => ({}));
  if (!res.ok) throw new Error(`resend ${res.status}: ${body?.message ?? JSON.stringify(body)}`);
  return body.id as string;
}

async function runOne(admin: SupabaseClient, row: Claimed, now: Date) {
  const started = Date.now();
  const finish = (status: string, extra: Record<string, unknown> = {}) =>
    admin.rpc("finish_digest_run", { p_run_id: row.run_id, p_status: status, ...extra });
  try {
    if (!row.email) throw new Error("user has no email address");
    const items = await feedFor(admin, row.owner_id);
    if (items.length === 0 && !row.send_when_empty) {
      await finish("skipped_empty", { p_item_count: 0 });
      console.log(JSON.stringify({ run_id: row.run_id, status: "skipped_empty", items: 0, ms: Date.now() - started }));
      return "skipped_empty";
    }
    const digest = renderDigest({
      items,
      now,
      timezone: row.timezone,
      name: row.display_name,
      appUrl: env("APP_BASE_URL"),
    });
    const messageId = await sendEmail(row.email, digest, row.run_id);
    await finish("sent", { p_item_count: items.length, p_provider_message_id: messageId });
    console.log(JSON.stringify({ run_id: row.run_id, status: "sent", items: items.length, ms: Date.now() - started }));
    return "sent";
  } catch (e) {
    const message = e instanceof Error ? e.message : String(e);
    await finish("failed", { p_error: message.slice(0, 500) });
    console.log(JSON.stringify({ run_id: row.run_id, status: "failed", error: message, ms: Date.now() - started }));
    return "failed";
  }
}

async function runCron(admin: SupabaseClient) {
  const now = new Date();
  const { data, error } = await admin.rpc("claim_due_digests", { p_now: now.toISOString() });
  if (error) return json({ error: `claim: ${error.message}` }, 500);
  const rows = (data ?? []) as Claimed[];
  const results: Record<string, number> = { sent: 0, skipped_empty: 0, failed: 0 };
  // At most 5 at a time.
  for (let i = 0; i < rows.length; i += 5) {
    const batch = await Promise.all(rows.slice(i, i + 5).map((r) => runOne(admin, r, now)));
    for (const status of batch) results[status]++;
  }
  return json({ claimed: rows.length, ...results });
}

async function runTest(admin: SupabaseClient, jwt: string) {
  const { data: auth, error } = await admin.auth.getUser(jwt);
  if (error || !auth.user) return json({ error: "sign in again" }, 401);
  const user = auth.user;
  if (!user.email) return json({ sent: false, items: 0, message: "Your account has no email address." });

  const { data: profile } = await admin
    .from("profiles")
    .select("display_name, timezone")
    .eq("id", user.id)
    .single();
  const items = await feedFor(admin, user.id);
  const digest = renderDigest({
    items,
    now: new Date(),
    timezone: profile?.timezone ?? "UTC",
    name: profile?.display_name,
    appUrl: env("APP_BASE_URL"),
  });
  if (!env("RESEND_API_KEY") || !env("DIGEST_FROM")) {
    return json({
      sent: false,
      items: items.length,
      message: `Email isn’t set up yet (RESEND_API_KEY or DIGEST_FROM is missing). It would have sent “${digest.subject}”.`,
    });
  }
  try {
    await sendEmail(user.email, digest);
    return json({ sent: true, items: items.length, to: user.email });
  } catch (e) {
    return json({ sent: false, items: items.length, message: e instanceof Error ? e.message : String(e) }, 502);
  }
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: cors });
  if (req.method !== "POST") return json({ error: "POST only" }, 405);

  const token = (req.headers.get("Authorization") ?? "").replace(/^Bearer\s+/i, "");
  const body = await req.json().catch(() => ({}));
  const isTest = new URL(req.url).searchParams.get("test") === "1" || body?.test === true;
  const admin = createClient(env("SUPABASE_URL"), env("SUPABASE_SERVICE_ROLE_KEY"), {
    auth: { persistSession: false, autoRefreshToken: false },
  });

  if (isTest) {
    if (!token) return json({ error: "sign in first" }, 401);
    return runTest(admin, token);
  }
  const secret = env("CRON_SECRET");
  if (!secret || token !== secret) return json({ error: "unauthorized" }, 401);
  return runCron(admin);
});
