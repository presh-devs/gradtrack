// Digest email rendering. Pure: no Deno or network APIs, so it can be tested
// with plain Node (tool/test_digest_render.mjs).

export type FeedItem = {
  item_type: string;
  item_id: string;
  application_id: string | null;
  professor_id: string | null;
  title: string;
  context: string | null;
  reason: string | null;
  due_at: string;
  due_tz: string | null;
  score: number;
};

export type Digest = { subject: string; html: string; text: string; count: number };

type Bucket = "overdue" | "today" | "week" | "later";

const BUCKETS: { key: Bucket; label: string }[] = [
  { key: "overdue", label: "Overdue" },
  { key: "today", label: "Today" },
  { key: "week", label: "This week" },
  { key: "later", label: "Later" },
];

/** YYYY-MM-DD of [d] in [zone]. */
function localDate(d: Date, zone: string): string {
  return new Intl.DateTimeFormat("en-CA", { timeZone: zone, year: "numeric", month: "2-digit", day: "2-digit" })
    .format(d);
}

function daysBetween(a: string, b: string): number {
  return Math.round((Date.parse(b + "T00:00:00Z") - Date.parse(a + "T00:00:00Z")) / 86_400_000);
}

export function bucketOf(item: FeedItem, now: Date, zone: string): Bucket {
  const due = new Date(item.due_at);
  // An opening date that has passed means "open now", not overdue.
  if (due < now && item.item_type !== "application_opens") return "overdue";
  const days = daysBetween(localDate(now, zone), localDate(due, zone));
  if (days <= 0) return "today";
  if (days <= 7) return "week";
  return "later";
}

function formatWhen(d: Date, zone: string): string {
  return new Intl.DateTimeFormat("en-GB", {
    timeZone: zone,
    weekday: "short",
    day: "numeric",
    month: "short",
    hour: "2-digit",
    minute: "2-digit",
    hour12: false,
  }).format(d);
}

function zoneAbbrev(d: Date, zone: string): string {
  const part = new Intl.DateTimeFormat("en-US", { timeZone: zone, timeZoneName: "short" })
    .formatToParts(d)
    .find((p) => p.type === "timeZoneName");
  return part?.value ?? zone;
}

/** "Thu 14 Nov, 23:59" in the reader's zone, plus the university's own time
 *  when the item was published in a different zone. */
export function dueLine(item: FeedItem, now: Date, zone: string): string {
  const due = new Date(item.due_at);
  if (item.item_type === "application_opens" && due < now) return "Open now";
  const mine = formatWhen(due, zone);
  if (item.due_tz && item.due_tz !== zone) {
    const theirs = new Intl.DateTimeFormat("en-GB", {
      timeZone: item.due_tz,
      day: "numeric",
      month: "short",
      hour: "2-digit",
      minute: "2-digit",
      hour12: false,
    }).format(due);
    return `${mine} your time · ${theirs} ${zoneAbbrev(due, item.due_tz)}`;
  }
  return mine;
}

export function linkFor(item: FeedItem, appUrl: string): string {
  const base = appUrl.replace(/\/+$/, "");
  if (item.application_id) return `${base}/applications/${item.application_id}`;
  if (item.professor_id) return `${base}/people`;
  return `${base}/`;
}

const esc = (s: string) =>
  s.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/"/g, "&quot;");

export function subjectFor(counts: Record<Bucket, number>): string {
  const soon = counts.today + counts.week;
  if (counts.overdue === 0 && soon === 0) {
    return counts.later === 0 ? "gradll · All clear today" : "gradll · Nothing urgent today";
  }
  const parts = [];
  if (counts.overdue > 0) parts.push(`${counts.overdue} overdue`);
  if (counts.today > 0) parts.push(`${counts.today} due today`);
  if (counts.week > 0) parts.push(`${counts.week} due this week`);
  return `gradll · ${parts.join(", ")}`;
}

export function renderDigest(opts: {
  items: FeedItem[];
  now: Date;
  timezone: string;
  name?: string | null;
  appUrl: string;
}): Digest {
  const { items, now, timezone, name, appUrl } = opts;
  const groups: Record<Bucket, FeedItem[]> = { overdue: [], today: [], week: [], later: [] };
  for (const item of items) groups[bucketOf(item, now, timezone)].push(item);
  const counts = {
    overdue: groups.overdue.length,
    today: groups.today.length,
    week: groups.week.length,
    later: groups.later.length,
  };
  const subject = subjectFor(counts);
  const base = appUrl.replace(/\/+$/, "");
  const hello = name ? `Good morning, ${name}.` : "Good morning.";
  const settings = `${base}/settings`;

  // Plain text
  const text: string[] = [hello, ""];
  if (items.length === 0) text.push("Nothing needs you today. Enjoy it.");
  for (const { key, label } of BUCKETS) {
    if (groups[key].length === 0) continue;
    text.push(label.toUpperCase());
    for (const i of groups[key]) {
      text.push(`- ${i.title}${i.context ? ` (${i.context})` : ""}`);
      text.push(`  ${[i.reason, dueLine(i, now, timezone)].filter(Boolean).join(" · ")}`);
      text.push(`  ${linkFor(i, appUrl)}`);
    }
    text.push("");
  }
  text.push(`Open gradll: ${base}/`, `Change digest time or turn it off: ${settings}`);

  // HTML (inline styles; email clients ignore <style> blocks unevenly)
  const colors: Record<Bucket, string> = { overdue: "#b42318", today: "#0151c2", week: "#5b4bc4", later: "#475467" };
  const sections = BUCKETS.filter(({ key }) => groups[key].length > 0)
    .map(({ key, label }) => {
      const rows = groups[key]
        .map(
          (i) => `
        <tr><td style="padding:10px 0;border-top:1px solid #eaecf0;">
          <a href="${esc(linkFor(i, appUrl))}" style="color:#101828;font-weight:600;text-decoration:none;">${esc(i.title)}</a>
          ${i.context ? `<div style="color:#475467;font-size:13px;">${esc(i.context)}</div>` : ""}
          <div style="color:#475467;font-size:13px;">${esc([i.reason, dueLine(i, now, timezone)].filter(Boolean).join(" · "))}</div>
        </td></tr>`,
        )
        .join("");
      return `
      <h2 style="margin:24px 0 4px;font-size:13px;letter-spacing:.06em;text-transform:uppercase;color:${colors[key]};">${label} · ${groups[key].length}</h2>
      <table role="presentation" width="100%" cellpadding="0" cellspacing="0">${rows}</table>`;
    })
    .join("");

  const html = `<!doctype html>
<html><body style="margin:0;background:#f5f7fb;font-family:-apple-system,Segoe UI,Roboto,Helvetica,Arial,sans-serif;color:#101828;">
  <div style="max-width:560px;margin:0 auto;padding:24px;">
    <div style="background:#ffffff;border-radius:12px;padding:24px;">
      <p style="margin:0 0 4px;font-size:16px;">${esc(hello)}</p>
      ${items.length === 0 ? `<p style="color:#475467;">Nothing needs you today. Enjoy it.</p>` : sections}
      <p style="margin:24px 0 0;"><a href="${esc(base)}/" style="display:inline-block;background:#0b63f6;color:#ffffff;padding:10px 16px;border-radius:8px;text-decoration:none;font-weight:600;">Open gradll</a></p>
    </div>
    <p style="color:#667085;font-size:12px;text-align:center;margin-top:16px;">
      Sent by gradll. <a href="${esc(settings)}" style="color:#667085;">Change the time or turn it off</a>.
    </p>
  </div>
</body></html>`;

  return { subject, html, text: text.join("\n"), count: items.length };
}
