// v: Klient for den delte bildebanken (Cloudflare R2, bucket "caminante-bilder"),
// lagt til 2026-08-22. Brukes til å laste opp/liste/slette bilder som ligger
// klare til gjenbruk på tvers av reisemål/hoteller/forslag (og etter hvert Web).
// Selve filene serveres direkte fra R2 sin offentlige URL (se BILDEBANK_PUBLIC_BASE
// under) - kun opplasting/liste/sletting går via /api/bildebank/*-endepunktene i
// caminante-admin-workeren, som krever innlogget Supabase-økt.
//
// v: MERK - denne peker foreløpig på Cloudflares midlertidige "Public Development
// URL" (pub-xxxx.r2.dev). Skal flyttes til et eget domene (f.eks. bilder.caminante.no)
// før bildebanken fylles opp for fullt - se Neste steg i prosjektdokumentasjonen.
window.BILDEBANK_PUBLIC_BASE = "https://pub-8f4270b9a9cf448a80b2613124b09894.r2.dev";

// Gjør et navn (reisemål- eller hotellnavn) om til en URL-sikker mappe-slug,
// f.eks. "Zakopane/Tatrafjellene" -> "zakopane-tatrafjellene". Må gi IDENTISK
// resultat uansett hvor den kalles fra (opplasting i Reisemål/Hoteller og
// visning/plukking i Forslag), ellers finner ikke plukkeren mappen igjen.
function slugifyBildebank(navn){
  return (navn || "").toString().trim().toLowerCase()
    // \u00e6/\u00f8/\u00e5 dekomponeres IKKE av NFD under (de er egne bokstaver, ikke
    // bokstav+diakritisk tegn) - m\u00e5 skrives om eksplisitt f\u00f8rst, ellers
    // forsvinner de sporl\u00f8st i stedet for \u00e5 bli til lesbare ae/o/a.
    .replace(/\u00e6/g, "ae").replace(/\u00f8/g, "o").replace(/\u00e5/g, "a")
    .normalize("NFD").replace(/[\u0300-\u036f]/g, "")
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-+|-+$/g, "")
    .slice(0, 80) || null;
}

async function bildebankAuthHeader(){
  const { data } = await window.sb.auth.getSession();
  const token = data && data.session && data.session.access_token;
  if(!token) throw new Error("Ikke innlogget.");
  return { Authorization: `Bearer ${token}` };
}

async function bildebankUpload(file, mappe, slug){
  const headers = await bildebankAuthHeader();
  const form = new FormData();
  form.append("file", file);
  form.append("mappe", mappe);
  form.append("slug", slug);
  const res = await fetch("/api/bildebank/upload", { method: "POST", headers, body: form });
  const data = await res.json();
  if(!res.ok) throw new Error(data.error || "Kunne ikke laste opp bilde.");
  return data; // { key, url }
}

async function bildebankList(mappe, slug){
  const headers = await bildebankAuthHeader();
  const qs = new URLSearchParams({ mappe, slug });
  const res = await fetch(`/api/bildebank/list?${qs}`, { headers });
  const data = await res.json();
  if(!res.ok) throw new Error(data.error || "Kunne ikke hente bilder fra bildebanken.");
  return data.bilder; // [{key, url, size, lastet_opp}]
}

async function bildebankDelete(key){
  const headers = await bildebankAuthHeader();
  const res = await fetch("/api/bildebank/delete", {
    method: "POST",
    headers: { ...headers, "Content-Type": "application/json" },
    body: JSON.stringify({ key }),
  });
  const data = await res.json();
  if(!res.ok) throw new Error(data.error || "Kunne ikke slette bilde.");
  return data;
}
