// v: Caminante Admin sin Worker. Var tidligere ren statisk filhosting (kun
// "assets" i wrangler.jsonc, ingen egen kode). Fra 2026-08-22 håndterer denne
// også /api/bildebank/*-endepunktene mot R2-bucketen "caminante-bilder"
// (opplasting/liste/sletting av bilder for Reisemål/Hoteller/Forslag), og
// faller tilbake til å servere de statiske filene (env.ASSETS.fetch) for
// alt annet - akkurat som før. Fra 2026-09-06 lager den også PDF-ene
// (/api/pdf) med Cloudflare Browser Run, se «PDF» lenger ned.
//
// Mapper i bucketen: destinations/<slug>/... og hoteller/<slug>/...

const MAX_BYTES = 15 * 1024 * 1024; // 15 MB
const TILLATTE_TYPER = {
  "image/jpeg": "jpg",
  "image/png": "png",
  "image/webp": "webp",
  "image/svg+xml": "svg",
  "image/gif": "gif",
};
const GYLDIGE_MAPPER = ["destinations", "hoteller"];

function jsonSvar(data, status) {
  return new Response(JSON.stringify(data), {
    status: status || 200,
    headers: { "Content-Type": "application/json; charset=utf-8" },
  });
}

function cors(resp, origin) {
  resp.headers.set("Access-Control-Allow-Origin", origin || "*");
  resp.headers.set("Access-Control-Allow-Headers", "Authorization, Content-Type");
  resp.headers.set("Access-Control-Allow-Methods", "GET, POST, OPTIONS");
  return resp;
}

// v: verifiserer at forespørselen kommer fra en innlogget Caminante-bruker,
// ved å be Supabase bekrefte access-tokenet fra Authorization-headeren.
// Ingen egen brukerdatabase/rolletabell å vedlikeholde her - Supabase ER
// fasiten på hvem som er innlogget, akkurat som i selve Admin-appen.
async function krevInnlogget(request, env) {
  const auth = request.headers.get("Authorization") || "";
  const token = auth.replace(/^Bearer\s+/i, "").trim();
  if (!token) return null;
  try {
    const res = await fetch(`${env.SUPABASE_URL}/auth/v1/user`, {
      headers: { Authorization: `Bearer ${token}`, apikey: env.SUPABASE_ANON_KEY },
    });
    if (!res.ok) return null;
    const user = await res.json();
    return user && user.id ? user : null;
  } catch (err) {
    return null;
  }
}

function slugFraKey(mappe, slug) {
  if (!GYLDIGE_MAPPER.includes(mappe)) return null;
  if (!/^[a-z0-9-]{1,80}$/.test(slug || "")) return null;
  return `${mappe}/${slug}`;
}

async function handleUpload(request, env) {
  const bruker = await krevInnlogget(request, env);
  if (!bruker) return jsonSvar({ error: "Ikke innlogget." }, 401);

  let form;
  try {
    form = await request.formData();
  } catch (err) {
    return jsonSvar({ error: "Ugyldig opplasting." }, 400);
  }
  const file = form.get("file");
  const mappe = String(form.get("mappe") || "");
  const slug = String(form.get("slug") || "");
  const prefix = slugFraKey(mappe, slug);
  if (!prefix) return jsonSvar({ error: "Ugyldig mappe/slug." }, 400);
  if (!file || typeof file === "string") return jsonSvar({ error: "Mangler fil." }, 400);
  if (file.size > MAX_BYTES) return jsonSvar({ error: "Filen er for stor (maks 15 MB)." }, 400);
  const ext = TILLATTE_TYPER[file.type];
  if (!ext) return jsonSvar({ error: `Filtype ${file.type || "ukjent"} er ikke tillatt - kun bilder.` }, 400);

  const id = crypto.randomUUID();
  const key = `${prefix}/${id}.${ext}`;
  await env.BILDEBANK.put(key, await file.arrayBuffer(), {
    httpMetadata: { contentType: file.type },
  });
  return jsonSvar({ key, url: `${env.R2_PUBLIC_BASE}/${key}` });
}

async function handleList(request, env) {
  const bruker = await krevInnlogget(request, env);
  if (!bruker) return jsonSvar({ error: "Ikke innlogget." }, 401);

  const url = new URL(request.url);
  const mappe = url.searchParams.get("mappe") || "";
  const slug = url.searchParams.get("slug") || "";
  const prefix = slugFraKey(mappe, slug);
  if (!prefix) return jsonSvar({ error: "Ugyldig mappe/slug." }, 400);

  const listing = await env.BILDEBANK.list({ prefix: prefix + "/" });
  const bilder = listing.objects.map((o) => ({
    key: o.key,
    url: `${env.R2_PUBLIC_BASE}/${o.key}`,
    size: o.size,
    lastet_opp: o.uploaded,
  }));
  return jsonSvar({ bilder });
}

async function handleDelete(request, env) {
  const bruker = await krevInnlogget(request, env);
  if (!bruker) return jsonSvar({ error: "Ikke innlogget." }, 401);

  let body;
  try {
    body = await request.json();
  } catch (err) {
    return jsonSvar({ error: "Ugyldig forespørsel." }, 400);
  }
  const key = String(body.key || "");
  // v: kan kun slette innenfor de kjente bildebank-mappene, aldri vilkårlige nøkler.
  if (!/^(destinations|hoteller)\/[a-z0-9-]{1,80}\/[a-f0-9-]{36}\.[a-z]+$/.test(key)) {
    return jsonSvar({ error: "Ugyldig nøkkel." }, 400);
  }
  await env.BILDEBANK.delete(key);
  return jsonSvar({ ok: true });
}


// ---------- PDF (Cloudflare Browser Run) ----------
// «Reiseforslag / PDF» og «Tilbud / PDF» lages her, ikke med nettleserens
// Skriv ut. Flyt: editoren kaller GET /api/pdf?id=…[&type=tilbud] med
// brukerens Supabase-token → workeren henter forslagets rader fra Supabase
// REST med SAMME token (RLS gjelder som i appen) → radene settes inn i
// forslag-print.html som window.PDF_DATA → Browser Run (headless Chromium)
// kjører malens egen måle- og sidefordelingskode, venter på fonter, bilder
// og markøren #pdf-klar, og tar PDF-en med faste A4-innstillinger.
// Tokenet sendes aldri til Browser Run: headless-siden får ferdige data,
// Supabase-/CDN-skriptene i malen fjernes (pdf-datakilde-markørene) og
// forespørsler dit blokkeres i tillegg.

const PDF_VENT_MS = 45000;

async function sbHent(env, token, sti) {
  const res = await fetch(`${env.SUPABASE_URL}/rest/v1/${sti}`, {
    headers: { apikey: env.SUPABASE_ANON_KEY, Authorization: `Bearer ${token}` },
  });
  if (!res.ok) throw new Error(`Supabase svarte ${res.status} for ${sti.split("?")[0]}`);
  return res.json();
}

// Nøyaktig de radene forslag-print.html sin hentData() ellers henter selv i
// forhåndsvisningen - samme tabeller, samme sortering.
async function hentForslagData(env, token, id) {
  const q = encodeURIComponent(id);
  const [forslagRader, transportRows, hotellRows, bildeRows, hpRows, dagRows] = await Promise.all([
    sbHent(env, token, `forslag?id=eq.${q}&select=*`),
    sbHent(env, token, `forslag_transport?forslag_id=eq.${q}&select=*&order=sortering.asc`),
    sbHent(env, token, `forslag_hotellopphold?forslag_id=eq.${q}&select=*&order=sortering.asc`),
    sbHent(env, token, `forslag_bilder?forslag_id=eq.${q}&select=*&order=sortering.asc`),
    sbHent(env, token, `forslag_hoydepunkter?forslag_id=eq.${q}&select=*&order=sortering.asc`),
    sbHent(env, token, `forslag_dagsprogram?forslag_id=eq.${q}&select=*&order=dagnummer.asc`),
  ]);
  const f = forslagRader[0];
  if (!f) return null;

  let ansvarligNavn = null;
  if (f.ansvarlig) {
    const p = await sbHent(env, token, `profiles?id=eq.${encodeURIComponent(f.ansvarlig)}&select=navn`);
    ansvarligNavn = (p[0] && p[0].navn) || null;
  }
  let hoydepunktBank = [], hoydepunktBildeBank = [], reisemaalLand = null;
  if (f.reisemaal_id) {
    const r = encodeURIComponent(f.reisemaal_id);
    const [hpBank, rmBilder, rm] = await Promise.all([
      sbHent(env, token, `reisemaal_hoydepunkter?reisemaal_id=eq.${r}&select=*`),
      sbHent(env, token, `reisemaal_bilder?reisemaal_id=eq.${r}&select=*`),
      sbHent(env, token, `reisemaal?id=eq.${r}&select=land`),
    ]);
    hoydepunktBank = hpBank;
    hoydepunktBildeBank = rmBilder;
    reisemaalLand = (rm[0] && rm[0].land) || null;
  }
  return { f, transportRows, hotellRows, bildeRows, hpRows, dagRows, ansvarligNavn, hoydepunktBank, hoydepunktBildeBank, reisemaalLand };
}

// Statiske filer leses fra ASSETS. Med standard html_handling kan
// «/forslag-print.html» svare med en omdirigering til «/forslag-print» -
// den følges.
async function hentAsset(env, request, sti) {
  let url = new URL(sti, request.url);
  for (let i = 0; i < 3; i++) {
    const res = await env.ASSETS.fetch(new Request(url.toString()));
    const videre = res.headers.get("Location");
    if (res.status >= 300 && res.status < 400 && videre) { url = new URL(videre, url); continue; }
    if (!res.ok) throw new Error(`Fant ikke ${sti} (${res.status}).`);
    return res.text();
  }
  throw new Error(`Fant ikke ${sti} (omdirigering).`);
}

// Malen sendes til Browser Run som ren HTML-streng, og siden får da ingen
// adresse (about:blank). Relative skript som <script src="shared/…">
// kan derfor ikke lastes der - de må bakes inn i selve HTML-en. (Feilen
// 06.09.2026: shared/pdf-maal.js ble lagt til i malen, ble aldri lastet
// i Browser Run, main() feilet på PDF_MAAL og #pdf-klar kom aldri.)
// Bilder (absolutte R2-adresser), fonter (Google) og logoer (data-URI)
// er upåvirket.
async function hentPdfMal(env, request) {
  let html = await hentAsset(env, request, "/forslag-print.html");
  // Supabase-/innloggingsskriptene fjernes FØR innbakingen, så de aldri
  // havner i det som sendes til Browser Run.
  html = html.replace(/<!-- pdf-datakilde:start[\s\S]*?pdf-datakilde:slutt -->/, "");
  const relative = [...html.matchAll(/<script\s+src="(shared\/[^"]+\.js)"><\/script>/g)];
  for (const m of relative) {
    const kode = await hentAsset(env, request, "/" + m[1]);
    html = html.replace(m[0], `<script>/* ${m[1]} */\n${kode.replace(/<\/script/gi, "<\\/script")}\n</script>`);
  }
  return html;
}

// Samme tittelregel som PDF-ens forside: «Reisemål, Land», landet utelatt
// når reisemålet ER landet.
function pdfFilnavn(data, erTilbud) {
  const f = data.f;
  const dest = (f.destinasjon || f.tittel || "Reiseforslag").trim();
  const land = (data.reisemaalLand || "").trim();
  const tittel = land && dest.toLowerCase() !== land.toLowerCase() ? `${dest}, ${land}` : dest;
  const navn = `${erTilbud ? "Tilbud" : "Reiseforslag"} - ${tittel}`
    .replace(/[\\/:*?"<>|\r\n]+/g, " ").replace(/\s+/g, " ").trim();
  return `${navn}.pdf`;
}

async function handlePdf(request, env) {
  const bruker = await krevInnlogget(request, env);
  if (!bruker) return jsonSvar({ error: "Ikke innlogget." }, 401);
  const token = (request.headers.get("Authorization") || "").replace(/^Bearer\s+/i, "").trim();

  const url = new URL(request.url);
  const id = url.searchParams.get("id") || "";
  const erTilbud = url.searchParams.get("type") === "tilbud";
  if (!/^[0-9a-f-]{36}$/i.test(id)) return jsonSvar({ error: "Ugyldig forslag-id." }, 400);
  if (!env.BROWSER) return jsonSvar({ error: "PDF-tjenesten (Browser Run) er ikke konfigurert på serveren." }, 500);

  let data;
  try {
    data = await hentForslagData(env, token, id);
  } catch (err) {
    return jsonSvar({ error: "Kunne ikke hente forslaget: " + err.message }, 502);
  }
  if (!data) return jsonSvar({ error: "Fant ikke dette forslaget." }, 404);

  let html;
  try {
    html = await hentPdfMal(env, request);
  } catch (err) {
    return jsonSvar({ error: err.message }, 500);
  }
  if (!html.includes("<!-- pdf-data -->")) return jsonSvar({ error: "PDF-malen mangler datamarkøren." }, 500);
  const json = JSON.stringify({ ...data, erTilbud })
    .replace(/<\//g, "<\\/").replace(/\u2028/g, "\\u2028").replace(/\u2029/g, "\\u2029");
  html = html.replace("<!-- pdf-data -->", `<script>window.PDF_DATA = ${json};</script>`);

  let svar;
  try {
    svar = await env.BROWSER.quickAction("pdf", {
      html,
      // Samme medium som dokumentet er målt og designet mot (@media print,
      // @page A4 uten marg) - også under selve målingen i siden.
      emulateMediaType: "print",
      viewport: { width: 1000, height: 1400 },
      gotoOptions: { waitUntil: "load", timeout: 30000 },
      // Siden setter #pdf-klar først når dokumentet er bygget og alle
      // bilder er lastet og dekodet (fontene ventes på før målingen).
      waitForSelector: { selector: "#pdf-klar", timeout: PDF_VENT_MS },
      rejectRequestPattern: ["supabase\\.co", "cdn\\.jsdelivr\\.net"],
      pdfOptions: {
        format: "a4",
        printBackground: true,
        preferCSSPageSize: true,
        margin: { top: "0", right: "0", bottom: "0", left: "0" },
        timeout: 60000,
      },
    });
  } catch (err) {
    console.error("Browser Run-kall feilet", err);
    return jsonSvar({ error: "PDF-tjenesten svarte ikke: " + (err && err.message ? err.message : err) }, 502);
  }

  if (!svar.ok) {
    const detalj = (await svar.text()).slice(0, 500);
    console.error("Browser Run feilet", svar.status, detalj);
    if (svar.status === 429) return jsonSvar({ error: "Mange PDF-er lages samtidig. Prøv igjen om noen sekunder." }, 429);
    const melding = /timeout|timed out/i.test(detalj)
      ? "Dokumentet ble ikke ferdig bygget innen tidsfristen. Prøv igjen, og si fra hvis det gjentar seg."
      : `PDF-genereringen feilet hos Browser Run (${svar.status}).`;
    return jsonSvar({ error: melding }, 502);
  }

  const filnavn = pdfFilnavn(data, erTilbud);
  const ascii = filnavn.replace(/[^\x20-\x7e]/g, "_").replace(/"/g, "");
  return new Response(svar.body, {
    status: 200,
    headers: {
      "Content-Type": "application/pdf",
      "Content-Disposition": `attachment; filename="${ascii}"; filename*=UTF-8''${encodeURIComponent(filnavn)}`,
      "Cache-Control": "no-store",
      "X-Browser-Ms-Used": svar.headers.get("X-Browser-Ms-Used") || "",
    },
  });
}

export default {
  async fetch(request, env, ctx) {
    const url = new URL(request.url);
    const origin = request.headers.get("Origin");

    if (url.pathname === "/api/pdf") {
      if (request.method === "OPTIONS") return cors(new Response(null, { status: 204 }), origin);
      if (request.method !== "GET") return cors(jsonSvar({ error: "Ukjent endepunkt." }, 404), origin);
      return cors(await handlePdf(request, env), origin);
    }

    if (url.pathname.startsWith("/api/bildebank/")) {
      if (request.method === "OPTIONS") return cors(new Response(null, { status: 204 }), origin);

      let resp;
      if (url.pathname === "/api/bildebank/upload" && request.method === "POST") {
        resp = await handleUpload(request, env);
      } else if (url.pathname === "/api/bildebank/list" && request.method === "GET") {
        resp = await handleList(request, env);
      } else if (url.pathname === "/api/bildebank/delete" && request.method === "POST") {
        resp = await handleDelete(request, env);
      } else {
        resp = jsonSvar({ error: "Ukjent endepunkt." }, 404);
      }
      return cors(resp, origin);
    }

    // Alt annet: server de statiske filene som før.
    return env.ASSETS.fetch(request);
  },
};
