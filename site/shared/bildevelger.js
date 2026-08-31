// v: Delt bildevelger for Caminante Admin, lagt til 2026-08-31 (Reise v1.0
// trinn 2). Én bildeplass = én boks med miniatyr, og ett vindu der man
// plukker fra bildebanken til det registeret plassen er koblet til.
//
// Besluttet knapp-prioritet, gjennomgående i Admin:
//   PRIMÆR    "Velg fra bildebank"  - fylt blå
//   SEKUNDÆR  "Last opp bilde"      - omrisset
// Bilder skal aldri velges automatisk; brukeren velger alltid selv.
//
// PRODUKTREGEL for de to knappene (besluttet 31.08.2026) - gjelder ALLE
// bildeplasser i Påmeldingstur, og MÅ følges av enhver ny kaller:
//
//   "Velg fra bildebank"  bruker et bilde som allerede ligger i det
//                         relevante registerets bildebank.
//   "Last opp bilde"      lagrer bildet KUN på det stedet i turen det ble
//                         lastet opp - aldri i noe bildebankregister.
//
// Bildebanken er et bevisst kuratert bibliotek. En tur kan bruke bilder fra
// biblioteket, men et bilde som lastes opp mens man bygger en tur skal
// ALDRI automatisk legges tilbake i biblioteket - heller ikke når turen er
// koblet til reisemålet eller hotellet bildet ville havnet hos. Skal et
// bilde inn permanent, gjøres det bevisst i Reisemål- eller Hotell-
// registeret.
//
// Konkret for de kommende bruksstedene:
//   Reiseinfo   velg fra reisemålets bank  / last opp kun til reisen
//   Program     velg fra reisemålets bank  / last opp kun til programdagen
//   Hotell      velg fra hotellets bank    / last opp kun til hotelloppholdet
//   Om reisen   velg fra reisemålets bank  / last opp kun til reisen
//
// Modulen gjør ingen opplasting selv - den kaller opts.onLastOpp(file).
// Regelen håndheves derfor av hver kaller, og skal ikke brytes der.
//
// Modulen kjenner ikke til noen tabell eller lagringsplass. Den som bruker
// den leverer et `bank`-objekt (hvor bildene kommer fra) og får beskjed via
// callbacks når noe velges, fjernes eller lastes opp. Se
// reise-editor.html (Forsidebilde) for et komplett eksempel.
//
// Denne filen gjør ingen nettverkskall på egen hånd - verken lesing eller
// opplasting. Kalleren leverer begge deler.

(function(){
  "use strict";

  function esc(str){
    return (str ?? "").toString().replace(/[&<>"']/g, m => ({"&":"&amp;","<":"&lt;",">":"&gt;",'"':"&quot;","'":"&#39;"}[m]));
  }

  /* ---------------- Delt vindu (bygges én gang, ved første bruk) ------- */

  let modalBg = null, modalTittel = null, modalTeller = null, modalKropp = null;
  // Hvert åpne-kall får sitt eget nummer. Et tregt nettverkskall som kommer
  // tilbake etter at vinduet er lukket - eller etter at en ANNEN plass har
  // åpnet det - skal ikke tegne inn i vinduet. Uten dette kunne bildene til
  // én plass dukke opp i plukkeren til en annen.
  let aapentNr = 0;

  // Stilarket legges inn for seg, og kalles BÅDE fra bildeplassen og fra
  // vinduet. Lå det bare i byggModal(), ville en bildeplass tegnet ved
  // sidelast stått helt ustylet til noen tilfeldigvis åpnet bildebanken -
  // og et stort bilde ville da vist seg i sin fulle originalstørrelse.
  let stilLagtInn = false;
  function sikreStil(){
    if(stilLagtInn) return;
    stilLagtInn = true;

    const css = document.createElement("style");
    css.textContent = `
      .bv-modal-bg{
        display:none; position:fixed; inset:0; background:rgba(11,11,11,0.35);
        z-index:60; align-items:center; justify-content:center;
      }
      .bv-modal-bg.open{ display:flex; }
      .bv-modal{
        background:var(--surface-1,#fff); border-radius:12px;
        width:min(760px,94vw); max-height:86vh; display:flex; flex-direction:column;
        box-shadow:0 10px 34px rgba(0,0,0,0.18);
      }
      .bv-modal-head{
        display:flex; align-items:flex-start; justify-content:space-between;
        gap:12px; padding:16px 20px 10px; border-bottom:1px solid var(--hairline,#e4e2dc);
      }
      .bv-modal-head h3{ margin:0; font-size:15px; color:var(--ink-primary,#1a1a1a); }
      .bv-modal-teller{ font-size:12px; color:var(--ink-muted,#8a8880); margin-top:2px; }
      .bv-modal-close{
        border:none; background:none; font-size:22px; line-height:1; cursor:pointer;
        color:var(--ink-muted,#8a8880); padding:0 2px;
      }
      .bv-modal-close:hover{ color:var(--ink-primary,#1a1a1a); }
      .bv-modal-body{ padding:16px 20px; overflow-y:auto; }
      .bv-modal-loading, .bv-modal-empty{ font-size:12.5px; color:var(--ink-muted,#8a8880); line-height:1.5; }
      .bv-modal-grid{
        display:grid; grid-template-columns:repeat(auto-fill,minmax(130px,1fr)); gap:10px;
      }
      .bv-thumb-wrap{
        border-radius:8px; overflow:hidden; cursor:pointer; background:var(--page,#f6f5f2);
        outline:2px solid transparent; transition:outline-color 0.1s;
      }
      .bv-thumb-wrap:hover{ outline-color:var(--blue,#2a78d6); }
      .bv-thumb-wrap img{ width:100%; height:90px; object-fit:cover; display:block; }

      /* ---- Bildeplassen ---- */
      /* Breddetaket hører hjemme HER, ikke hos hver enkelt kaller - da er
         boksen like kompakt uansett hvor bred spalte den settes inn i
         (f.eks. et fullbreddes dagskort senere). En kaller som vil ha den
         smalere, setter fortsatt sin egen, snevrere ramme rundt. */
      .bv-slot{
        background:rgba(42,120,214,0.09); border:1.5px solid var(--blue,#2a78d6);
        border-radius:10px; padding:12px; display:flex; flex-direction:column;
        max-width:280px;
      }
      .bv-slot-label{
        font-size:11.5px; font-weight:600; color:var(--blue-dark,#184f95);
        text-transform:uppercase; letter-spacing:0.03em; margin-bottom:8px;
      }
      /* Forhåndsvisningen er en KOMPAKT visning av bildet, ikke en
         gjengivelse av hvordan det ser ut for kunden. To krav styrer den:
           - Riktige proporsjoner. Derfor ingen object-fit:cover her, som
             ville beskåret bildet i visningen og gitt et feil inntrykk av
             hva som faktisk er valgt. Bildefilen røres aldri.
           - Kompakt. Boksen slutter seg om bildet (auto på både bredde og
             høyde, med tak på begge), så et høyt portrettbilde ikke drar
             kortet ut i lengden og et bredt bilde ikke tar over fanen.
         Taket på 150px ligger i samme sjikt som resten av Admin, der
         miniatyrer er 90-100px (se .rm-img-card/.hotel-img-card/.img-card) -
         litt større, siden dette er ETT utvalgt bilde og ikke et galleri. */
      .bv-slot-thumb{
        margin-bottom:8px; display:flex; justify-content:center; align-items:center;
        min-height:60px;   /* et bilde som ikke laster skal ikke kollapse til ingenting */
      }
      .bv-slot-thumb img{
        display:block; width:auto; height:auto; max-width:100%; max-height:150px;
        border-radius:7px; background:var(--page,#f6f5f2);
      }
      .bv-slot-tom{
        font-size:12px; color:var(--ink-muted,#8a8880); text-align:center; padding:30px 8px;
        background:rgba(255,255,255,0.6); border-radius:7px; margin-bottom:8px;
      }
      /* Merknad: bildet er hentet fra et ANNET reisemål enn reisen er
         koblet til nå. Bildet beholdes alltid - merknaden er en beskjed,
         ikke en feil. */
      .bv-slot-merknad{
        display:flex; align-items:center; gap:10px; flex-wrap:wrap;
        background:#fdf4e3; border:1px solid #eddaaf; border-radius:7px;
        padding:8px 10px; margin-bottom:8px; font-size:12px; color:#8a6a1d;
      }
      .bv-slot-merknad .bv-slot-merknad-tekst{ flex:1; min-width:140px; }
      .bv-slot-merknad button{
        border:1px solid #d9bd7e; background:var(--surface-1,#fff); color:#7a5d18;
        border-radius:6px; padding:4px 10px; font-size:11.5px; cursor:pointer; white-space:nowrap;
      }
      .bv-slot-merknad button:hover{ background:#f7ecd6; }
      .bv-slot-primar{
        width:100%; font-size:12.5px; padding:8px 6px; margin-bottom:7px;
        border:1px solid var(--blue,#2a78d6); border-radius:7px;
        background:var(--blue,#2a78d6); color:#fff; cursor:pointer;
      }
      .bv-slot-primar:hover{ background:var(--blue-dark,#184f95); border-color:var(--blue-dark,#184f95); }
      .bv-slot-sekundar{
        width:100%; font-size:12.5px; padding:8px 6px;
        border:1px solid var(--blue,#2a78d6); border-radius:7px;
        background:var(--surface-1,#fff); color:var(--blue,#2a78d6); cursor:pointer;
      }
      .bv-slot-sekundar:hover{ background:var(--blue,#2a78d6); color:#fff; }
      .bv-slot-primar:disabled, .bv-slot-sekundar:disabled{
        opacity:0.55; cursor:default; background:var(--page,#f6f5f2);
        color:var(--ink-muted,#8a8880); border-color:var(--hairline,#e4e2dc);
      }
      .bv-slot-actions{
        display:flex; gap:10px; margin-top:10px; padding-top:8px;
        border-top:1px solid rgba(42,120,214,0.22);
      }
      .bv-slot-actions button{
        flex:1; font-size:11.5px; border:none; background:none; color:var(--blue,#2a78d6);
        text-decoration:underline; cursor:pointer; padding:3px 0;
      }
      .bv-slot-actions .bv-slot-fjern{ color:#b04a4a; }
      .bv-slot-actions button:disabled{
        color:var(--ink-muted,#8a8880); text-decoration:none; cursor:default;
      }
      .bv-slot-status{ font-size:11.5px; color:var(--ink-muted,#8a8880); margin-top:6px; min-height:15px; }
    `;
    document.head.appendChild(css);
  }

  function byggModal(){
    sikreStil();
    if(modalBg) return;

    modalBg = document.createElement("div");
    modalBg.className = "bv-modal-bg";
    modalBg.innerHTML = `
      <div class="bv-modal">
        <div class="bv-modal-head">
          <div>
            <h3 class="bv-modal-tittel">Bildebank</h3>
            <div class="bv-modal-teller"></div>
          </div>
          <button type="button" class="bv-modal-close" title="Lukk">&times;</button>
        </div>
        <div class="bv-modal-body"></div>
      </div>`;
    document.body.appendChild(modalBg);

    modalTittel = modalBg.querySelector(".bv-modal-tittel");
    modalTeller = modalBg.querySelector(".bv-modal-teller");
    modalKropp  = modalBg.querySelector(".bv-modal-body");

    modalBg.querySelector(".bv-modal-close").addEventListener("click", lukkModal);
    modalBg.addEventListener("click", (e)=>{ if(e.target === modalBg) lukkModal(); });
    document.addEventListener("keydown", (e)=>{
      if(e.key === "Escape" && modalBg.classList.contains("open")) lukkModal();
    });
  }

  function lukkModal(){
    aapentNr++;               // ugyldiggjør et pågående kall
    if(modalBg) modalBg.classList.remove("open");
  }

  // bank = {
  //   tittel:      string
  //   erKoblet:    ()=>bool          - er plassen koblet til et register?
  //   tomBeskjed:  string            - vises når erKoblet() er usann
  //   hentBilder:  async ()=>[{id,url,alt_tekst}]
  //   brukteIds:   ()=>Set|null      - valgfritt: skjul bilder som alt er i bruk
  //   maks:        number|null       - valgfritt: vises i telleren
  // }
  // onVelg(bilde) kalles med det valgte bildet. Vinduet lukkes selv.
  async function aapne(bank, onVelg){
    byggModal();
    const mittNr = ++aapentNr;

    modalTittel.textContent = bank.tittel || "Bildebank";
    modalTeller.textContent = "";
    modalKropp.innerHTML = `<div class="bv-modal-loading">Henter bilder…</div>`;
    modalBg.classList.add("open");

    // Plassen er ikke koblet til noe register ennå. Knappen skal likevel
    // kunne trykkes - en grå, død knapp forklarer ikke hva som mangler.
    if(!bank.erKoblet()){
      modalKropp.innerHTML = `<div class="bv-modal-empty">${esc(bank.tomBeskjed || "")}</div>`;
      return;
    }

    let alle;
    try{
      alle = await bank.hentBilder();
    } catch(err){
      if(mittNr !== aapentNr) return;
      modalKropp.innerHTML = `<div class="bv-modal-empty">Kunne ikke hente bildene: ${esc(err && err.message ? err.message : err)}</div>`;
      return;
    }
    if(mittNr !== aapentNr) return;   // lukket, eller en annen plass har tatt over

    alle = alle || [];
    const brukte = (bank.brukteIds && bank.brukteIds()) || null;
    const ledige = brukte ? alle.filter(b => !brukte.has(b.id)) : alle;

    modalTeller.textContent = bank.maks
      ? `${alle.length} / ${bank.maks} bilder i banken`
      : `${alle.length} bilde${alle.length===1?"":"r"} i banken`;

    if(!alle.length){
      // MÅ ikke love at en opplasting herfra fyller banken - den gjør den
      // ikke, og en tekst som antyder noe annet ville aktivt motarbeide
      // produktregelen øverst i filen.
      modalKropp.innerHTML = `<div class="bv-modal-empty">Ingen bilder i bildebanken ennå. `
        + `Bildebanken fylles i registeret. Vil du bruke et bilde bare her, `
        + `lukk dette vinduet og velg «Last opp bilde».</div>`;
      return;
    }
    if(!ledige.length){
      modalKropp.innerHTML = `<div class="bv-modal-empty">Alle bildene i banken er allerede i bruk her.</div>`;
      return;
    }

    const grid = document.createElement("div");
    grid.className = "bv-modal-grid";
    ledige.forEach(b=>{
      const wrap = document.createElement("div");
      wrap.className = "bv-thumb-wrap";
      wrap.title = "Klikk for å velge dette bildet";
      wrap.innerHTML = `<img src="${esc(b.url)}" loading="lazy" alt="${esc(b.alt_tekst || "")}">`;
      wrap.addEventListener("click", ()=>{ lukkModal(); onVelg(b); });
      grid.appendChild(wrap);
    });
    modalKropp.innerHTML = "";
    modalKropp.appendChild(grid);
  }

  /* ---------------- Bildeplassen ---------------- */

  // opts = {
  //   label:        string
  //   getUrl:       ()=>string|null      - bildet som ligger i plassen nå
  //   getMerknad:   ()=>string|null      - valgfri beskjed over knappene
  //   bank:         ()=>bankObjekt       - leses PÅ KLIKK, ikke ved tegning
  //   onVelg:       (bilde)=>void
  //   onFjern:      ()=>void
  //   onLastOpp:    async (file)=>void   - kalleren gjør selve opplastingen
  //   erFraBank:    ()=>bool             - ligger bildet også i bildebanken?
  //   erOpptatt:    ()=>bool             - pågår det en opplasting nå?
  //   settOpptatt:  (bool)=>void         - sett/nullstill det flagget
  //   etterEndring: ()=>void             - be siden tegne plassen på nytt
  // }
  // MERK: «opptatt»-flagget MÅ ligge hos kalleren, ikke på DOM-noden. Boksen
  // kan tegnes på nytt midt i en opplasting (f.eks. hvis reisemålet byttes),
  // og en lås som bare satt `disabled` på knappene ville forsvunnet med den
  // gamle noden - da kunne to opplastinger kjøre samtidig.
  function slot(opts){
    sikreStil();
    const url = opts.getUrl();
    const merknad = opts.getMerknad ? opts.getMerknad() : null;
    const opptatt = opts.erOpptatt ? !!opts.erOpptatt() : false;

    const box = document.createElement("div");
    box.className = "bv-slot";
    box.innerHTML = `
      <div class="bv-slot-label">${esc(opts.label || "")}</div>
      ${url
        ? `<div class="bv-slot-thumb"><img src="${esc(url)}" alt=""></div>`
        : `<div class="bv-slot-tom">Ingen bilde valgt</div>`}
      ${merknad
        ? `<div class="bv-slot-merknad">
             <span class="bv-slot-merknad-tekst">${esc(merknad)}</span>
             <button type="button" class="bv-slot-merknad-bytt"${opptatt ? " disabled" : ""}>Bytt bilde</button>
           </div>`
        : ``}
      <!-- Begge veiene er tilgjengelige HELE TIDEN, også når plassen alt
           har et bilde: man skal ikke måtte fjerne det gamle bildet først
           for å laste opp et nytt. -->
      <button type="button" class="bv-slot-primar"${opptatt ? " disabled" : ""}>${url ? "Bytt bilde" : "Velg fra bildebank"}</button>
      <button type="button" class="bv-slot-sekundar"${opptatt ? " disabled" : ""}>Last opp bilde</button>
      ${url
        ? `<div class="bv-slot-actions"><button type="button" class="bv-slot-fjern"${opptatt ? " disabled" : ""}>Fjern</button></div>`
        : ``}
      <div class="bv-slot-status">${opptatt ? "Laster opp…" : ""}</div>
      <input type="file" accept="image/*" class="bv-slot-file" style="display:none">
    `;

    const status = box.querySelector(".bv-slot-status");
    const filInput = box.querySelector(".bv-slot-file");

    const aapneBank = ()=> aapne(opts.bank(), (bilde)=>{
      opts.onVelg(bilde);
      if(opts.etterEndring) opts.etterEndring();
    });

    box.querySelectorAll(".bv-slot-primar, .bv-slot-merknad-bytt")
       .forEach(btn => btn.addEventListener("click", aapneBank));

    const fjernBtn = box.querySelector(".bv-slot-fjern");
    if(fjernBtn) fjernBtn.addEventListener("click", ()=>{
      // Et bilde fra bildebanken kan velges inn igjen når som helst - der
      // er «Fjern» ufarlig og skal ikke koste et ekstra klikk. Et bilde som
      // er lastet opp her finnes derimot ingen andre steder, så der spør vi.
      const fraBank = opts.erFraBank ? !!opts.erFraBank() : false;
      if(!fraBank && !confirm(
        "Dette bildet kan ikke velges inn igjen fra bildebanken.\n\n"
        + "Fjerner du det, må du laste det opp på nytt.\n\nFjerne bildet?")) return;
      opts.onFjern();
      if(opts.etterEndring) opts.etterEndring();
    });

    const lastOppBtn = box.querySelector(".bv-slot-sekundar");
    if(lastOppBtn){
      lastOppBtn.addEventListener("click", ()=> filInput.click());
      filInput.addEventListener("change", async (e)=>{
        const input = e.target;
        const valgt = input.files[0];
        if(!valgt) return;
        if(!valgt.type || !valgt.type.startsWith("image/")){
          input.value = "";
          alert("Kun bildefiler kan lastes opp.");
          return;
        }

        // Lås plassen mens opplastingen pågår, slik at to raske klikk ikke
        // kan starte to opplastinger. Flagget ligger hos kalleren, så låsen
        // overlever at boksen tegnes på nytt av noe annet underveis.
        if(opts.settOpptatt) opts.settOpptatt(true);
        box.querySelectorAll("button").forEach(b=> b.disabled = true);
        status.textContent = "Laster opp…";

        try{
          // Filen leses inn i minnet FØRST, før noe annet skjer.
          //
          // En File fra en <input type="file"> er bare en referanse til en
          // fil på disk, eid av det input-elementet. Blir elementet revet ut
          // av dokumentet mens filen leses - og det kan skje, siden
          // reisemål-nedtrekket tegner bildeboksen på nytt - kan lesingen
          // stoppe UTEN at det kastes noen feil. Da blir opplastingen
          // stående på "Laster opp…" for alltid.
          //
          // Ved å ta en uavhengig kopi med det samme, spiller det ingen rolle
          // hva som senere skjer med input-elementet eller boksen. En fil som
          // ikke lar seg lese gir dessuten en EKTE feil her, i stedet for
          // stillhet.
          const bytes = await valgt.arrayBuffer();
          const fil = new File([bytes], valgt.name, { type: valgt.type });
          await opts.onLastOpp(fil);
        } catch(err){
          alert("Kunne ikke laste opp: " + (err && err.message ? err.message : err));
        } finally{
          // Tømmes først nå, slik at samme fil kan velges på nytt etter en feil.
          input.value = "";
          if(opts.settOpptatt) opts.settOpptatt(false);
          box.querySelectorAll("button").forEach(b=> b.disabled = false);
          status.textContent = "";
          // Kaster kallerens opptegning, skal ikke låsen bli hengende.
          try{ if(opts.etterEndring) opts.etterEndring(); }
          catch(tegnefeil){ console.error("Kunne ikke tegne bildeplassen på nytt:", tegnefeil); }
        }
      });
    }
    return box;
  }

  window.bildevelger = { aapne, slot, lukk: lukkModal };
})();
