-- ====================================================================
-- DOKUMENTASJON av migrasjon som allerede er kjørt i Supabase.
-- Navn i Supabase: reise_v1_trinn3_program
-- Kjørt: 2026-08-31 (via Supabase MCP)
-- Denne filen skal IKKE kjøres på nytt - den gjenspeiler det som ble kjørt.
-- ====================================================================

-- Reise v1.0 trinn 3: Program. Kun additivt + én lettelse.

-- 1) Spor av hvor et dagsbilde kommer fra. Satt = plukket fra reisemålets
--    bildebank (kan velges inn igjen uten videre). Tomt = lastet opp direkte
--    på dagen og finnes ingen andre steder - da spør editoren før fjerning.
--    on delete set null: ryddes bankbildet bort fra registeret, beholder
--    dagen adressen sin og viser bildet - kun sporet forsvinner.
--    Samme mønster som trips.forsidebilde_bank_id.
alter table trip_day_images add column bank_id uuid references reisemaal_bilder(id) on delete set null;

-- 2) Tittelen kan stå tom. Dagene genereres nå automatisk fra reisens
--    datoer og finnes før noen har skrevet noe på dem; «ikke utfylt» er null,
--    som overalt ellers i Admin.
alter table trip_days alter column title drop not null;

-- 3) SYNLIGHETSREGELEN, dokumentert der datamodellen bor.
--
--    Programdagene har ingen datokolonne. Datoen regnes ut fra
--    trips.start_date + (day_number - 1), og innholdet hører til
--    DAGNUMMERET - det flyttes aldri mellom dager når reisens datoer endres
--    (produktbeslutning 31.08.2026: flyttes fra-datoen, beholder dag 1 sitt
--    innhold og får ny dato).
--
--    Forkortes reisen, SLETTES IKKE dagene som faller utenfor perioden.
--    De ligger bevart med day_number større enn reisens antall dager, og
--    kommer tilbake hvis reisen forlenges igjen. De er INAKTIVE og skal
--    ALDRI vises offentlig. Enhver leser - en fremtidig kundeside, en PDF,
--    et eksport - MÅ filtrere:
--
--        day_number <= (trips.end_date - trips.start_date + 1)
--
--    Mangler start_date eller end_date, eller er end_date før start_date,
--    finnes det INGEN synlige dager - vis ikke noe program i det hele tatt.
--
--    Merk at trips.days er en lagret kopi som kan drive (Sarajevo-reisen
--    hadde days = 5 uten datoer); regn alltid fra datoene. Radene er
--    anonymt lesbare for publiserte reiser (RLS), så filteret MÅ ligge hos
--    leseren - databasen skjuler dem ikke.
--
--    Regelen ligger også som kommentar på tabellene i basen, slik at den er
--    synlig for enhver som ser på skjemaet.
comment on table trip_days is
  'Programdager. Dato = trips.start_date + (day_number - 1). Innhold hører til dagnummeret. '
  'Dager med day_number > (end_date - start_date + 1) er BEVARTE/INAKTIVE og skal aldri vises offentlig - filtrer hos leseren. '
  'Regn alltid antall dager fra datoene, ikke fra trips.days.';

comment on table trip_day_images is
  'Bilder på en programdag. Arver synligheten til dagen: vis aldri bilder for en dag med day_number utenfor reiseperioden. '
  'bank_id satt = plukket fra reisemaal_bilder; tomt = lastet opp direkte på dagen.';

-- Editoren (site/reise-editor.html) følger regelen slik:
--   - en dag treffes på sitt day_number og slettes ALDRI fra Program
--   - lat oppretting: en dag uten innhold får aldri noen rad
--   - antall dager regnes fra datoene i beregnDager(), aldri fra trips.days
