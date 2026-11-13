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

/** Readable strings from a JSON value (keys dropped), longest content first kept in order. */
function jsonStrings(value: unknown, out: string[], depth = 0) {
  if (depth > 40 || out.length > 4000) return;
  if (typeof value === "string") {
    const s = value.replace(/<[^>]+>/g, " ").replace(/\s+/g, " ").trim();
    // Skip ids, paths, class names and other machine strings.
    if (s.length >= 3 && /\s/.test(s) && !/^[\w./:#?=&%-]+$/.test(s)) out.push(decodeEntities(s));
    else if (/^https?:\/\/\S+$/.test(s) && /apply|admission|application|portal/i.test(s)) out.push(s);
  } else if (Array.isArray(value)) {
    for (const v of value) jsonStrings(v, out, depth + 1);
  } else if (value && typeof value === "object") {
    for (const v of Object.values(value)) jsonStrings(v, out, depth + 1);
  }
}

/**
 * Content that pages built with JavaScript (Next.js, Nuxt, many CMSs) ship
 * inside the HTML as data rather than visible markup: meta descriptions,
 * JSON-LD, and framework state such as __NEXT_DATA__. Used when the visible
 * text is too thin to read.
 */
export function embeddedText(html: string): string {
  const parts: string[] = [];
  for (const m of html.matchAll(/<meta\b[^>]*(?:name|property)\s*=\s*["'](?:description|og:description|og:title)["'][^>]*>/gi)) {
    const content = m[0].match(/content\s*=\s*["']([^"']*)["']/i)?.[1];
    if (content) parts.push(decodeEntities(content).trim());
  }
  const strings: string[] = [];
  for (const m of html.matchAll(/<script\b([^>]*)>([\s\S]*?)<\/script>/gi)) {
    const attrs = m[1];
    let body = m[2].trim();
    if (!body) continue;
    const isJson = /type\s*=\s*["']application\/(ld\+)?json["']/i.test(attrs) || /id\s*=\s*["']__NEXT_DATA__["']/i.test(attrs);
    if (!isJson) {
      // window.__NUXT__ = {...} / self.__next_f.push([...]) style payloads: take the JSON-looking part.
      const start = body.search(/[{[]/);
      if (start < 0 || !/__NUXT__|__INITIAL_STATE__|__APOLLO_STATE__|__next_f|__remixContext/.test(body)) continue;
      body = body.slice(start).replace(/;?\s*$/, "");
    }
    try {
      jsonStrings(JSON.parse(body), strings);
    } catch {
      // Next.js app-router chunks are JS strings, not JSON: pull quoted text out.
      for (const q of body.matchAll(/"((?:[^"\\]|\\.){20,})"/g)) {
        try {
          jsonStrings(JSON.parse(`"${q[1]}"`), strings);
        } catch { /* ignore */ }
      }
    }
  }
  const seen = new Set<string>();
  const unique = [...parts, ...strings].filter((s) => s && !seen.has(s) && (seen.add(s), true));
  return unique.join("\n");
}
