-- ====================================================================
-- DOKUMENTASJON av migrasjon som allerede er kjørt i Supabase.
-- Navn i Supabase: reise_v1_trinn2_forsidebilde
-- Kjørt: 2026-08-31 (via Supabase MCP)
-- Denne filen skal IKKE kjøres på nytt - den gjenspeiler det som ble kjørt.
-- ====================================================================

-- Reise v1.0 trinn 2: Forsidebilde. Kun additivt.

-- 1) Forsidebildet ligger PÅ trips: det skal kunne leses av kundesiden for
--    en publisert reise, i motsetning til de interne feltene i trip_internal.
alter table trips add column forsidebilde_url text;

-- 2) Hvilket bankbilde det kom fra. on delete set null: ryddes bildet bort
--    fra reisemålets bank, beholder reisen fortsatt adressen sin (kolonnen
--    over) og viser bildet - kun sporet forsvinner.
alter table trips add column forsidebilde_bank_id uuid references reisemaal_bilder(id) on delete set null;

-- 3) Hvilket reisemål bildet ble hentet fra. Brukes til merknaden
--    "Forsidebildet er hentet fra Marokko" når reisen senere kobles til et
--    ANNET reisemål (produktbeslutning 31.08.2026: et bevisst valgt bilde
--    slettes eller byttes aldri automatisk - det beholdes med en tydelig
--    merknad, og brukeren velger selv om det skal byttes).
--    Navnet lagres som kopi ved siden av id-en, etter samme kopimønster som
--    resten av registerbruken, slik at merknaden fortsatt gir mening om
--    reisemålet senere fjernes fra registeret.
alter table trips add column forsidebilde_reisemaal_id uuid references reisemaal(id) on delete set null;
alter table trips add column forsidebilde_reisemaal_navn text;

-- 4) Lagringsplass for forsidebilder som lastes opp på selve reisen.
--    PRODUKTREGEL (besluttet 31.08.2026): «Last opp bilde» i Påmeldingstur
--    lagrer ALLTID her, uansett om reisen er koblet til et reisemål eller
--    ikke. En opplasting fra en tur skal aldri havne i reisemaal_bilder
--    eller et annet registers bildebank - bildebanken er et bevisst kuratert
--    bibliotek, og det kureres i registeret. Bilder som VELGES fra banken
--    peker derimot på bankens egne filer og ligger ikke her.
--    Speiler oppsettet for forslag-bilder: offentlig lesing (bildet skal
--    vises for kunden), men kun innloggede kan legge til eller slette.
insert into storage.buckets (id, name, public) values ('reise-bilder', 'reise-bilder', true)
on conflict (id) do nothing;

create policy "Offentlig lesetilgang reise-bilder" on storage.objects
  for select using (bucket_id = 'reise-bilder');
create policy "Innloggede kan laste opp reise-bilder" on storage.objects
  for insert with check (bucket_id = 'reise-bilder' and auth.role() = 'authenticated');
create policy "Innloggede kan slette reise-bilder" on storage.objects
  for delete using (bucket_id = 'reise-bilder' and auth.role() = 'authenticated');
