// Tests for the digest email renderer (supabase/functions/send-digests/render.ts).
// Run: node tool/test_digest_render.mjs   (Node 23+ strips TypeScript types)
import assert from "node:assert/strict";
import { test } from "node:test";
import { bucketOf, dueLine, linkFor, renderDigest, subjectFor } from "../supabase/functions/send-digests/render.ts";

const now = new Date("2026-11-12T06:00:00Z"); // 07:00 in Lagos
const zone = "Africa/Lagos";
const item = (over) => ({
  item_type: "requirement",
  item_id: "r1",
  application_id: "a1",
  professor_id: null,
  title: "Official transcript",
  context: "University of Toronto · PhD Computer Science",
  reason: "Not started",
  due_at: "2026-11-15T04:59:00Z",
  due_tz: "America/Toronto",
  score: 50,
  ...over,
});

test("buckets use the reader's local day", () => {
  assert.equal(bucketOf(item({ due_at: "2026-11-12T05:00:00Z" }), now, zone), "overdue");
  assert.equal(bucketOf(item({ due_at: "2026-11-12T22:00:00Z" }), now, zone), "today"); // 23:00 Lagos
  assert.equal(bucketOf(item({ due_at: "2026-11-12T23:30:00Z" }), now, zone), "week"); // 00:30 next day in Lagos
  assert.equal(bucketOf(item({ due_at: "2026-11-30T12:00:00Z" }), now, zone), "later");
  // A portal that already opened isn't "overdue".
  assert.equal(bucketOf(item({ item_type: "application_opens", due_at: "2026-11-11T08:00:00Z" }), now, zone), "today");
});

test("due line shows both zones when they differ", () => {
  assert.equal(dueLine(item({}), now, zone), "Sun 15 Nov, 05:59 your time · 14 Nov, 23:59 EST");
  assert.equal(dueLine(item({ due_tz: null }), now, zone), "Sun 15 Nov, 05:59");
  assert.equal(dueLine(item({ item_type: "application_opens", due_at: "2026-11-11T08:00:00Z" }), now, zone), "Open now");
});

test("subjects", () => {
  assert.equal(subjectFor({ overdue: 2, today: 0, week: 3, later: 1 }), "gradll · 2 overdue, 3 due this week");
  assert.equal(subjectFor({ overdue: 0, today: 1, week: 0, later: 0 }), "gradll · 1 due today");
  assert.equal(subjectFor({ overdue: 0, today: 0, week: 0, later: 2 }), "gradll · Nothing urgent today");
  assert.equal(subjectFor({ overdue: 0, today: 0, week: 0, later: 0 }), "gradll · All clear today");
});

test("links", () => {
  assert.equal(linkFor(item({}), "https://app.example/"), "https://app.example/applications/a1");
  assert.equal(linkFor(item({ application_id: null, professor_id: "p1" }), "https://app.example"), "https://app.example/people");
});

test("render escapes HTML and includes a text part", () => {
  const d = renderDigest({
    items: [item({ title: "<script>x</script> & co" })],
    now,
    timezone: zone,
    name: "Precious",
    appUrl: "https://app.example",
  });
  assert.equal(d.count, 1);
  assert.equal(d.subject, "gradll · 1 due this week");
  assert.ok(d.html.includes("&lt;script&gt;x&lt;/script&gt; &amp; co"));
  assert.ok(!d.html.includes("<script>"));
  assert.ok(d.text.startsWith("Good morning, Precious."));
  assert.ok(d.text.includes("THIS WEEK"));
  assert.ok(d.text.includes("https://app.example/applications/a1"));
  const empty = renderDigest({ items: [], now, timezone: zone, appUrl: "https://app.example" });
  assert.equal(empty.subject, "gradll · All clear today");
  assert.ok(empty.text.includes("Nothing needs you today"));
});
