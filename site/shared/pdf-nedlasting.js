// Servergenerert PDF av et forslag (worker.js /api/pdf → Cloudflare Browser
// Run). Brukes av Gruppetilbud-editoren (knappene «Reiseforslag / PDF» og
// «Tilbud / PDF») og av forhåndsvisningen forslag-print.html («Last ned
// PDF»). Nettleserens Skriv ut brukes ikke: PDF-en lages av den samme
// malen i headless Chromium på serveren, uavhengig av Safari/Chrome og
// lokale utskriftsinnstillinger, og lander som en vanlig fil i Nedlastinger.
//
// Forutsetter window.sb (shared/supabase-client.js) for brukerens token.
// Tokenet går bare til vår egen worker - aldri videre til Browser Run.

async function lastNedForslagPdf(forslagId, erTilbud, knapp){
  if(!forslagId){ alert("Mangler forslag-id."); return false; }
  const original = knapp ? knapp.textContent : "";
  if(knapp){ knapp.disabled = true; knapp.textContent = "Genererer PDF…"; }
  try{
    const { data: { session } } = await window.sb.auth.getSession();
    if(!session) throw new Error("Du er ikke innlogget lenger. Logg inn på nytt og prøv igjen.");

    const url = `/api/pdf?id=${encodeURIComponent(forslagId)}${erTilbud ? "&type=tilbud" : ""}`;
    const res = await fetch(url, { headers: { Authorization: `Bearer ${session.access_token}` } });
    if(!res.ok){
      let melding = `PDF-genereringen feilet (HTTP ${res.status}).`;
      try{ const j = await res.json(); if(j && j.error) melding = j.error; }catch(e){}
      throw new Error(melding);
    }
    const type = res.headers.get("Content-Type") || "";
    if(!type.includes("application/pdf")) throw new Error("Serveren returnerte ikke en PDF-fil.");

    const blob = await res.blob();
    const filnavn = filnavnFraDisposition(res.headers.get("Content-Disposition"))
      || (erTilbud ? "Tilbud.pdf" : "Reiseforslag.pdf");
    const objUrl = URL.createObjectURL(blob);
    const a = document.createElement("a");
    a.href = objUrl;
    a.download = filnavn;
    a.style.display = "none";
    document.body.appendChild(a);
    a.click();
    a.remove();
    setTimeout(()=> URL.revokeObjectURL(objUrl), 60000);
    return true;
  }catch(err){
    alert("Kunne ikke lage PDF:\n\n" + (err && err.message ? err.message : err));
    return false;
  }finally{
    if(knapp){ knapp.disabled = false; knapp.textContent = original; }
  }
}

function filnavnFraDisposition(h){
  if(!h) return null;
  const m = /filename\*=UTF-8''([^;]+)/i.exec(h);
  if(m){ try{ return decodeURIComponent(m[1].trim()); }catch(e){} }
  const m2 = /filename="([^"]+)"/i.exec(h);
  return m2 ? m2[1] : null;
}
