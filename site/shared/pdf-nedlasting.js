// Servergenerert PDF av et forslag (worker.js /api/pdf → Cloudflare Browser
// Run). Brukes av Gruppetilbud-editoren (knappene «Reiseforslag / PDF» og
// «Tilbud / PDF») og av forhåndsvisningen forslag-print.html («Last ned
// PDF»). Nettleserens Skriv ut brukes ikke: PDF-en lages av den samme
// malen i headless Chromium på serveren, uavhengig av Safari/Chrome og
// lokale utskriftsinnstillinger, og lander som en vanlig fil i Nedlastinger.
//
// Forutsetter window.sb (shared/supabase-client.js) for brukerens token.
// Tokenet går bare til vår egen worker - aldri videre til Browser Run.

// Knappetilstand. Settes SYNKRONT i selve klikket, før noe som helst
// asynkront (lagring, nettverk) - ellers står knappen urørt i flere
// sekunder mens editoren lagrer først, og brukeren vet ikke om klikket
// tok. Returnerer false hvis knappen allerede er opptatt (dobbeltklikk).
// Original tekst huskes på elementet, så tilstanden kan gjenopprettes av
// hvem som helst som har knappen - uansett hvor feilen oppstår.
function pdfKnappStart(knapp){
  if(!knapp) return true;
  if(knapp.dataset.pdfOpptatt === "1") return false;
  knapp.dataset.pdfOpptatt = "1";
  knapp.dataset.pdfTekst = knapp.textContent;
  knapp.disabled = true;
  knapp.classList.add("pdf-opptatt");
  knapp.textContent = "Genererer PDF…";
  return true;
}
function pdfKnappFerdig(knapp){
  if(!knapp || knapp.dataset.pdfOpptatt !== "1") return;
  knapp.textContent = knapp.dataset.pdfTekst || knapp.textContent;
  knapp.classList.remove("pdf-opptatt");
  knapp.disabled = false;
  delete knapp.dataset.pdfOpptatt;
  delete knapp.dataset.pdfTekst;
}
// Gir nettleseren én tegnerunde, slik at den nye knappetilstanden faktisk
// er malt på skjermen før det tunge arbeidet starter. requestAnimationFrame
// fyrer ikke i en skjult fane - derfor et lite tidsavbrudd som reserve, så
// PDF-en aldri blir stående og vente på at fanen blir synlig.
function laNettleserenTegne(){
  return new Promise(res=>{
    const reserve = setTimeout(res, 120);
    requestAnimationFrame(()=> requestAnimationFrame(()=>{ clearTimeout(reserve); res(); }));
  });
}

async function lastNedForslagPdf(forslagId, erTilbud, knapp){
  if(!forslagId){ alert("Mangler forslag-id."); return false; }
  // Kalleren kan ha satt knappen opptatt allerede (editoren gjør det før
  // lagringen). Er den ikke det, gjøres det her - og et nytt klikk på en
  // knapp som allerede jobber, ignoreres.
  const startetHer = knapp && knapp.dataset.pdfOpptatt !== "1";
  if(startetHer){
    if(!pdfKnappStart(knapp)) return false;
    await laNettleserenTegne();
  }
  // Aldri to samtidige PDF-kall fra samme knapp, uansett hvem som kaller.
  if(knapp && knapp.dataset.pdfHenter === "1") return false;
  if(knapp) knapp.dataset.pdfHenter = "1";
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
    if(knapp) delete knapp.dataset.pdfHenter;
    if(startetHer) pdfKnappFerdig(knapp);
  }
}

function filnavnFraDisposition(h){
  if(!h) return null;
  const m = /filename\*=UTF-8''([^;]+)/i.exec(h);
  if(m){ try{ return decodeURIComponent(m[1].trim()); }catch(e){} }
  const m2 = /filename="([^"]+)"/i.exec(h);
  return m2 ? m2[1] : null;
}
