-- ====================================================================
-- DOKUMENTASJON av migrasjon som allerede er kjørt i Supabase.
-- Navn i Supabase: gruppetilbud_vilkaar_standardtekster  (08.09.2026, via Supabase MCP,
-- med eksplisitt klarsignal fra Vidar)
-- Denne filen skal IKKE kjøres på nytt - den gjenspeiler det som ble kjørt.
-- ====================================================================

-- Gruppetilbud, fanen «Vilkår og frister» (site/forslag-editor.html) og
-- siden «Vilkår og frister» i Tilbud-PDF-en (site/forslag-print.html).
--
-- Rekkefølge i Admin og PDF: Tilbudsfrist, Forbehold, Betalingsbetingelser,
-- Navneliste og navneendringer, Avbestillingsbetingelser, Øvrige betingelser.
--
-- Prinsipp som før (sql/gruppetilbud_del3_vilkaar_og_frister.sql):
-- standardtekstene ligger som column default og gjelder NYE rader; per sak
-- er tekstene fritt redigerbare. Eksisterende rader ble oppdatert kun der
-- feltet var tomt eller inneholdt den gamle standardteksten uendret -
-- brukerredigert tekst ble ikke rørt (verifisert etterpå: de fire radene
-- med egen tekst i avbestilling/øvrige/forbehold sto uendret).
--
-- Den tidligere standardteksten for betalingsbetingelser («Normalt
-- faktureres 30 % …») sto uendret i alle 12 rader og ble byttet ut.
-- Teksten «Depositum kr 2 000 per person …» fantes ikke i denne tabellen
-- - den hører til Påmeldingsturer.
--
-- «Særlige vilkår» heter nå «Øvrige betingelser» i Admin og PDF.
-- Kolonnenavnet saerlige_vilkaar er beholdt (ingen unødvendig migrering).
--
-- Vilkårsfeltene teller linjeskift som ett tegn i editoren (maks 500), slik
-- at avbestillingsbetingelsene kan stå med én periode per linje.

alter table forslag add column if not exists navneliste_tekst text default
  'Komplett navneliste må sendes Caminante Travel AS senest 60 dager før avreise. Navneendringer etter denne fristen følger flyselskapets gjeldende vilkår og frister.';
comment on column forslag.navneliste_tekst is
  'Navneliste og navneendringer (Vilkår og frister i Gruppetilbud). Standardtekst som column default, fritt redigerbar per sak.';

alter table forslag alter column betalingsbetingelser set default
  'Reisens totalbeløp forfaller til betaling senest 60 dager før avreise, med mindre annet er spesifisert i tilbudet.';

-- Første versjon av avbestillingsteksten (kjørt i denne migrasjonen):
alter table forslag alter column avbestillingsbetingelser set default
  E'60 dager eller mer før avreise: Kostnader Caminante Travel AS ikke får refundert fra flyselskap, hotell eller øvrige leverandører.\n59–30 dager før avreise: 50 % av reisens pris. Dersom kostnaden for ikke-refunderbare flybilletter og øvrige tjenester overstiger dette beløpet, gjelder den faktiske kostnaden.\nMindre enn 30 dager før avreise: 100 % av reisens pris.';
comment on column forslag.avbestillingsbetingelser is
  'Avbestillingsbetingelser for tilbudet. Standardtekst som column default med én periode per linje, fritt redigerbar per sak. Ingen avbestillingslogikk er bygget.';

alter table forslag alter column saerlige_vilkaar set default
  'Caminante Travel AS forbeholder seg retten til å justere prisen ved betydelige endringer i kostnader knyttet til drivstoff og energi, skatter og avgifter eller relevante valutakurser. En eventuell prisjustering tilsvarer den faktiske kostnadsendringen og skal varsles senest 20 dager før avreise. Ved en prisøkning på mer enn 8 % kan kunden avbestille reisen uten kostnad.';
comment on column forslag.saerlige_vilkaar is
  'Vises som «Øvrige betingelser» i Admin og Tilbud-PDF (kolonnenavnet er beholdt). Standardtekst som column default, fritt redigerbar per sak.';

alter table forslag alter column tilbud_forbehold_tekst set default
  'Tilbudet er gitt med forbehold om tilgjengelighet og eventuelle endringer hos våre leverandører. Dersom tilbudet aksepteres, anses reisen som endelig bekreftet når kunden har mottatt reisebekreftelsen fra Caminante Travel AS.';

-- Eksisterende rader: gammel standard (uendret) → ny standard; tomme felt → standard.
update forslag set betalingsbetingelser = default
  where betalingsbetingelser is null or btrim(betalingsbetingelser) = ''
     or betalingsbetingelser = 'Normalt faktureres 30 % av reisens totalbeløp ved bestilling, og full betaling skjer senest 60 dager før avreise. Har dere spesielle ønsker omkring betaling, finner vi en løsning som passer dere.';
update forslag set navneliste_tekst = default where navneliste_tekst is null or btrim(navneliste_tekst) = '';
update forslag set avbestillingsbetingelser = default where avbestillingsbetingelser is null or btrim(avbestillingsbetingelser) = '';
update forslag set saerlige_vilkaar = default where saerlige_vilkaar is null or btrim(saerlige_vilkaar) = '';
update forslag set tilbud_forbehold_tekst = default where tilbud_forbehold_tekst is null or btrim(tilbud_forbehold_tekst) = '';

-- DUPLISERING (site/forslag.html) kopierer hele raden («...rest»), så
-- navneliste_tekst arves av en kopi som de andre vilkårstekstene.

-- ====================================================================
-- OPPFØLGING samme dag, også kjørt i Supabase (08.09.2026, via Supabase MCP):
-- gruppetilbud_avbestilling_standardtekst_v2
-- Justert standardtekst for avbestillingsbetingelser: innledende setning,
-- blank linje, én periode per linje. Rader som fortsatt hadde den første
-- versjonen uendret fikk den nye (11 rader); brukerredigert tekst
-- («Kan ikke avbestilles», 1 rad) ble ikke rørt. Gjeldende default:
-- ====================================================================
alter table forslag alter column avbestillingsbetingelser set default
  E'Ved avbestilling gjelder følgende avbestillingskostnader:\n\n60 dager eller mer før avreise: Kostnader Caminante Travel AS ikke får refundert fra flyselskap, hotell eller øvrige leverandører.\n59–30 dager før avreise: 50 % av reisens pris. Dersom kostnader Caminante Travel AS ikke får refundert fra flyselskap, hotell eller øvrige leverandører overstiger dette beløpet, gjelder disse kostnadene.\nMindre enn 30 dager før avreise: 100 % av reisens pris.';

update forslag set avbestillingsbetingelser = default
  where avbestillingsbetingelser = E'60 dager eller mer før avreise: Kostnader Caminante Travel AS ikke får refundert fra flyselskap, hotell eller øvrige leverandører.\n59–30 dager før avreise: 50 % av reisens pris. Dersom kostnaden for ikke-refunderbare flybilletter og øvrige tjenester overstiger dette beløpet, gjelder den faktiske kostnaden.\nMindre enn 30 dager før avreise: 100 % av reisens pris.';
