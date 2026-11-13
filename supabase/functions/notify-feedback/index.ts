// notify-feedback: emails the gradll owner when someone sends feedback.
//
// Called by the database (trigger on public.feedback → pg_net) with
// `Authorization: Bearer <CRON_SECRET>` and `{"feedback_id": "<uuid>"}`.
// Loads the row and the sender's email with the service role, emails
// FEEDBACK_NOTIFY_TO through Resend, and stamps feedback.notified_at so a
// retry never emails twice (the feedback id is also Resend's idempotency key).
//
// Secrets: SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY (provided by Supabase),
// RESEND_API_KEY, CRON_SECRET, FEEDBACK_NOTIFY_TO, FEEDBACK_FROM
// (defaults to DIGEST_FROM, then Resend's test sender, which only delivers to
// the Resend account's own address). tool/setup_feedback_email.sh sets them.
//
// Deployed with verify_jwt = false: the shared secret isn't a JWT.

import { createClient } from "jsr:@supabase/supabase-js@2";

const env = (name: string) => Deno.env.get(name) ?? "";
const json = (body: unknown, status = 200) =>
  new Response(JSON.stringify(body), { status, headers: { "Content-Type": "application/json" } });

const kindLabels: Record<string, string> = {
  feature: "Feature request",
  problem: "Something’s wrong",
  other: "Feedback",
};

const escapeHtml = (s: string) =>
  s.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/"/g, "&quot;");

Deno.serve(async (req) => {
  if (req.method !== "POST") return json({ error: "POST only" }, 405);
  const secret = env("CRON_SECRET");
  if (!secret || req.headers.get("Authorization") !== `Bearer ${secret}`) {
    return json({ error: "unauthorized" }, 401);
  }
  const to = env("FEEDBACK_NOTIFY_TO");
  if (!to || !env("RESEND_API_KEY")) return json({ skipped: "email not configured" });

  const { feedback_id: id } = await req.json().catch(() => ({}));
  if (typeof id !== "string") return json({ error: "feedback_id required" }, 400);

  const admin = createClient(env("SUPABASE_URL"), env("SUPABASE_SERVICE_ROLE_KEY"), {
    auth: { persistSession: false },
  });
  const { data: row, error } = await admin
    .from("feedback")
    .select("id, owner_id, kind, message, created_at, notified_at")
    .eq("id", id)
    .maybeSingle();
  if (error) return json({ error: error.message }, 500);
  if (!row) return json({ error: "not found" }, 404);
  if (row.notified_at) return json({ skipped: "already notified" });

  const { data: user } = await admin.auth.admin.getUserById(row.owner_id);
  const from = user?.user?.email ?? "an unknown user";
  const kind = kindLabels[row.kind] ?? "Feedback";
  const firstLine = row.message.split("\n")[0].slice(0, 60);
  const subject = `gradll · ${kind}: ${firstLine}${row.message.length > firstLine.length ? "…" : ""}`;
  const text = `${kind} from ${from}\n\n${row.message}\n\n` +
    `Reply to them directly, or set its status in Supabase → Table Editor → feedback.`;
  const html = `<div style="font-family:system-ui,sans-serif;font-size:15px;line-height:1.5;color:#111">
<p style="margin:0 0 4px;color:#555">${escapeHtml(kind)} from <b>${escapeHtml(from)}</b></p>
<blockquote style="margin:12px 0;padding:12px 16px;background:#f4f6fb;border-left:3px solid #0066ff;white-space:pre-wrap">${
    escapeHtml(row.message)
  }</blockquote>
<p style="margin:0;color:#777;font-size:13px">Reply to this email to answer them, or set its status in Supabase → Table Editor → feedback.</p>
</div>`;

  const res = await fetch("https://api.resend.com/emails", {
    method: "POST",
    headers: {
      Authorization: `Bearer ${env("RESEND_API_KEY")}`,
      "Content-Type": "application/json",
      "Idempotency-Key": `feedback-${row.id}`,
    },
    body: JSON.stringify({
      from: env("FEEDBACK_FROM") || env("DIGEST_FROM") || "gradll <onboarding@resend.dev>",
      to: [to],
      ...(user?.user?.email ? { reply_to: user.user.email } : {}),
      subject,
      text,
      html,
    }),
  });
  const body = await res.json().catch(() => ({}));
  if (!res.ok) return json({ error: `resend ${res.status}: ${body?.message ?? JSON.stringify(body)}` }, 502);

  await admin.from("feedback").update({ notified_at: new Date().toISOString() }).eq("id", row.id);
  return json({ sent: body.id });
});
