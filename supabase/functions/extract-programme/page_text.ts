// Turns a fetched HTML page into readable text for the model: drops scripts,
// styles and navigation chrome, keeps headings/paragraph breaks, and keeps
// link targets (so the model can find the application portal).

const ENTITIES: Record<string, string> = {
  amp: "&", lt: "<", gt: ">", quot: '"', apos: "'", nbsp: " ", ndash: "–", mdash: "—",
  rsquo: "’", lsquo: "‘", rdquo: "”", ldquo: "“", hellip: "…", euro: "€", pound: "£", yen: "¥",
};

function decodeEntities(s: string): string {
  return s.replace(/&(#x?[0-9a-f]+|[a-z]+);/gi, (m, code: string) => {
    if (code[0] === "#") {
      const n = code[1].toLowerCase() === "x" ? parseInt(code.slice(2), 16) : parseInt(code.slice(1), 10);
      return Number.isFinite(n) && n > 0 && n < 0x110000 ? String.fromCodePoint(n) : m;
    }
    return ENTITIES[code.toLowerCase()] ?? m;
  });
}

export function htmlToText(html: string, baseUrl: string): { title: string; text: string } {
  const title = decodeEntities(html.match(/<title[^>]*>([\s\S]*?)<\/title>/i)?.[1] ?? "").trim();
  let s = html
    .replace(/<!--[\s\S]*?-->/g, " ")
    .replace(/<(script|style|noscript|svg|template|iframe|canvas)\b[\s\S]*?<\/\1>/gi, " ")
    .replace(/<(nav|footer)\b[\s\S]*?<\/\1>/gi, " ");
  // Links: "text (https://absolute/url)", relative links resolved.
  s = s.replace(/<a\b[^>]*href\s*=\s*["']([^"'#][^"']*)["'][^>]*>([\s\S]*?)<\/a>/gi, (_m, href: string, inner: string) => {
    const label = inner.replace(/<[^>]+>/g, " ").replace(/\s+/g, " ").trim();
    let abs = href;
    try {
      abs = new URL(decodeEntities(href), baseUrl).toString();
    } catch { /* keep as-is */ }
    if (!/^https?:/i.test(abs)) return label;
    return label ? `${label} (${abs})` : `(${abs})`;
  });
  s = s
    .replace(/<(br|hr)\b[^>]*>/gi, "\n")
    .replace(/<\/?(p|div|section|article|main|header|h[1-6]|li|ul|ol|tr|table|dl|dt|dd|blockquote)\b[^>]*>/gi, "\n")
    .replace(/<(td|th)\b[^>]*>/gi, " | ")
    .replace(/<[^>]+>/g, " ");
  const text = decodeEntities(s)
    .split("\n")
    .map((line) => line.replace(/[ \t ]+/g, " ").trim())
    .filter((line, i, arr) => line !== "" || (i > 0 && arr[i - 1] !== ""))
    .join("\n")
    .trim();
  return { title, text };
}
