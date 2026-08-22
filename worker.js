// v: Caminante Admin sin Worker. Var tidligere ren statisk filhosting (kun
// "assets" i wrangler.jsonc, ingen egen kode). Fra 2026-08-22 håndterer denne
// også /api/bildebank/*-endepunktene mot R2-bucketen "caminante-bilder"
// (opplasting/liste/sletting av bilder for Reisemål/Hoteller/Forslag), og
// faller tilbake til å servere de statiske filene (env.ASSETS.fetch) for
// alt annet - akkurat som før.
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

export default {
  async fetch(request, env, ctx) {
    const url = new URL(request.url);
    const origin = request.headers.get("Origin");

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
