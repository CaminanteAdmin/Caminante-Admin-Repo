// Delte mål for PDF-ens sidearkitektur og Om reisen-siden (side 2).
// Brukes av forslag-print.html (selve layouten og overfull-kontrollen) og
// forslag-editor.html (validering FØR PDF-en genereres), slik at editoren
// regner med nøyaktig de samme tallene som malen faktisk bruker.
//
// Alle mål i px ved 96 dpi (1 mm = 3,78 px), samme enhet som CSS-en.

const PDF_MAAL = {
  MM: 96 / 25.4,
  SIDE_MM: 297,                    // A4
  MELLOMFOOTER_MM: 14,             // svart bunnstripe på innholdssidene (06.09.2026)
  INNHOLD_BREDDE_PX: 666,          // 210 mm - 2 x 64 px sidemarg
  OM_REISEN: {
    TOPP_PX: 84,                   // section.side-start padding-top
    H2_PX: 25,                     // «Om reisen»-overskriften inkl. margin under
    MIN_AVSTAND_MM: 10,            // minste luft mellom siste tekstlinje og galleriet
    BUNN_MM: 12,                   // fast luft mellom galleriet og bunnstripen
    GALLERI_GAP_PX: 10,            // luft mellom bildene i galleriet
    GALLERI_FORHOLD: 16 / 9,       // bildenes bredde/høyde (aspect-ratio) - 16:9 fra 06.09.2026
    SIKKERHET_MM: 3,               // slingringsmonn i editorens forhåndsmåling
  },
};

// Om reisen er fritekst med brukerens egne avsnitt: en blank linje skiller
// avsnitt (<p>), et enkelt linjeskift blir linjeskift innenfor avsnittet.
// Ingenting autogenereres og ingenting normaliseres bort. esc er sidens
// egen HTML-escaper (esc() i malen, escapeHtml() i editoren).
function omReisenAvsnittHtml(tekst, esc){
  const s = (tekst || "").replace(/\r\n?/g, "\n").trim();
  if(!s) return "";
  return s.split(/\n[ \t]*\n+/)
    .map(a => `<p>${esc(a).replace(/\n/g, "<br>")}</p>`)
    .join("");
}

// Galleriets høyde: alltid to i bredden, n/2 rader (2, 4 eller 6 bilder).
function omReisenGalleriHoydePx(antallBilder){
  const O = PDF_MAAL.OM_REISEN;
  const rader = Math.ceil((antallBilder || 0) / 2);
  if(!rader) return 0;
  const bildeBredde = (PDF_MAAL.INNHOLD_BREDDE_PX - O.GALLERI_GAP_PX) / 2;
  const bildeHoyde = bildeBredde / O.GALLERI_FORHOLD;
  return rader * bildeHoyde + (rader - 1) * O.GALLERI_GAP_PX;
}

// Hvor høy teksten (avsnittene under overskriften) kan være på side 2 med
// et gitt antall galleribilder, uten å kollidere med galleriet eller
// bunnstripen. Brukes av editoren mot faktisk målt teksthøyde.
function omReisenTekstBudsjettPx(antallBilder){
  const O = PDF_MAAL.OM_REISEN, MM = PDF_MAAL.MM;
  const tilgjengelig = (PDF_MAAL.SIDE_MM - PDF_MAAL.MELLOMFOOTER_MM - O.BUNN_MM) * MM - O.TOPP_PX - O.H2_PX;
  const galleri = omReisenGalleriHoydePx(antallBilder);
  const avstand = antallBilder ? O.MIN_AVSTAND_MM * MM : 0;
  return tilgjengelig - galleri - avstand - O.SIKKERHET_MM * MM;
}
