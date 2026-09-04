-- ====================================================================
-- DOKUMENTASJON av migrasjoner som allerede er kjørt i Supabase.
-- Navn i Supabase: gruppetilbud_del3_vilkaar_og_frister  (04.09.2026)
--                  gruppetilbud_del3_vilkaar_korrigert   (04.09.2026)
-- Denne filen skal IKKE kjøres på nytt - den gjenspeiler sluttresultatet
-- av begge, slik feltene faktisk ser ut i basen i dag.
-- ====================================================================

-- Gruppetilbud Del 3: Vilkår og frister.
--
-- Fanen består av: Tilbudsfrist, Forbehold (for tilbud),
-- Betalingsbetingelser, Avbestillingsbetingelser, Særlige vilkår.
--
-- Ingenting er påkrevd under vanlig redigering. Kravene gjelder først ved
-- «Generer tilbud» (Del 4), som minst skal kreve pris og tilbudsfrist.
-- Feltene er derfor nullable.

-- 1) TILBUDSFRIST - fristen kunden har på tilbudet. Ett datofelt.
--    (Het «tilbud_gyldig_til» i første utgave, omdøpt i korrigeringen.)
alter table forslag add column tilbudsfrist date;
comment on column forslag.tilbudsfrist is
  'Fristen kunden har på tilbudet. Kreves ved «Generer tilbud» (Del 4), ikke ellers.';

-- MERK: et felt for «opsjonsfrist» ble opprettet i første utgave og deretter
-- FJERNET igjen (aldri tatt i bruk). Leverandørenes opsjoner på fly og hotell
-- er noe annet enn kundens tilbudsfrist, og de kan ha ulike frister hver for
-- seg. Skal eventuelt håndteres senere som operative frister knyttet til
-- fly/hotell, ikke som ett generelt felt i Vilkår og frister.

-- 2) FORBEHOLD FOR TILBUD. Et SEPARAT felt fra forslag.forbehold_tekst, som
--    er reiseforslagets forbehold og står helt urørt - ikke samme tekst vist
--    to steder.
--    Et reiseforslag kan ta et uforpliktende forbehold om at kapasitet ikke
--    holdes og at priser kan endres. I et tilbud har vi normalt undersøkt og
--    ofte holdt kapasitet hos fly og hotell, men kan likevel ikke garantere
--    endelig kapasitet og pris før bestillingen er bekreftet hos
--    leverandørene.
--    Standardtekst er BEVISST ikke satt: ordlyden skal kvalitetssikres før
--    lansering. Da settes den som column default på samme måte som
--    forbehold_tekst har i dag, og alle nye gruppetilbud får den
--    forhåndsutfylt uten at editoren må endres.
alter table forslag add column tilbud_forbehold_tekst text;
comment on column forslag.tilbud_forbehold_tekst is
  'Forbehold for TILBUD. Separat fra forbehold_tekst, som er reiseforslagets forbehold og skal stå urørt. Standardtekst skal kvalitetssikres før lansering.';

-- 3) BETALINGSBETINGELSER - stort fritekstfelt med standardtekst for nye
--    gruppetilbud, fritt redigerbart per sak. Ingen strukturerte
--    prosent-/dagfelt.
alter table forslag add column betalingsbetingelser text default
  'Normalt faktureres 30 % av reisens totalbeløp ved bestilling, og full betaling skjer senest 60 dager før avreise. Har dere spesielle ønsker omkring betaling, finner vi en løsning som passer dere.';
comment on column forslag.betalingsbetingelser is
  'Betalingsbetingelser for tilbudet. Standardtekst ligger som column default og kan redigeres fritt per gruppetilbud. Ingen strukturerte prosent-/dagfelt.';

-- 4) AVBESTILLINGSBETINGELSER - stort fritekstfelt uten standardtekst.
--    Standardtekst for avbestillingsbetingelser skal kvalitetssikres før
--    lansering. Ingen avbestillingslogikk (f.eks. en 60-dagersregel) er
--    bygget, og skal ikke bygges nå.
alter table forslag add column avbestillingsbetingelser text;
comment on column forslag.avbestillingsbetingelser is
  'Avbestillingsbetingelser for tilbudet. Standardtekst for avbestillingsbetingelser skal kvalitetssikres før lansering - ingen default satt, og ingen avbestillingslogikk (f.eks. 60-dagersregel) er bygget.';

-- 5) SÆRLIGE VILKÅR - frivillig fritekst, tomt som standard.
alter table forslag add column saerlige_vilkaar text;
comment on column forslag.saerlige_vilkaar is
  'Særlige vilkår for denne saken. Forbehold ligger i tilbud_forbehold_tekst (tilbud) og forbehold_tekst (reiseforslag) og dupliseres ikke her.';

-- ENGANGSKORREKSJON (kjørt 04.09.2026, etter avklaring med produkteier):
-- en column default gjelder kun NYE rader, så de ti eksisterende
-- gruppetilbudene sto uten betalingsbetingelser. Disse er modell-/testsaker
-- som ikke skal brukes som reelle kundesaker, og skulle følge den nye
-- standarden. «= default» henter kolonnens egen standardverdi, slik at
-- teksten blir tegn for tegn identisk med den nye gruppetilbud får:
--
--   update forslag set betalingsbetingelser = default
--    where betalingsbetingelser is null;
--
-- Verifisert etterpå: 10 av 10 rader har teksten, kun én distinkt verdi, og
-- ingen andre felt ble berørt.

-- DUPLISERING (site/forslag.html): tilbudsfristen arves IKKE av en kopi -
-- en kopi laget senere ville ellers fått en gammel dato som ser bevisst satt
-- ut. Tekstfeltene i Vilkår og frister arves som resten av innholdet.
