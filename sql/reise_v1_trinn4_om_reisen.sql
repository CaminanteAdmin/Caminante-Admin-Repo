-- ====================================================================
-- DOKUMENTASJON av migrasjon som allerede er kjørt i Supabase.
-- Navn i Supabase: reise_v1_trinn4_om_reisen
-- Kjørt: 2026-08-31 (via Supabase MCP)
-- Denne filen skal IKKE kjøres på nytt - den gjenspeiler det som ble kjørt.
-- ====================================================================

-- Reise v1.0 trinn 4: Om reisen + Personregister.
--
-- PRODUKTMODELL (besluttet 31.08.2026):
--   Personregisteret (trip_leaders): en person registreres ÉN gang med
--   navn, masterpresentasjon (bio), interne kontaktopplysninger og en egen
--   bildebank (trip_leader_images).
--   På den enkelte reisen (trip_trip_leaders) settes rolle (fritekst),
--   valgt bilde fra personens bank, og presentasjonen (bio_override).
--   bio_override er en KOPI av masterpresentasjonen tatt idet personen
--   legges til reisen (besluttet 03.09.2026), og er deretter reisens egen
--   tekst: den arver ikke senere endringer i registeret, og redigering på
--   reisen rører aldri registeret. Masterdataene røres aldri fra en reise.
--   Samme person kan dermed fremstå ulikt på ulike reiser.
--
-- TILGANG: Personregisteret er FORELØPIG HELT INTERNT. Den gamle
--   anon-policyen på trip_leaders var «qual = true» - hele registeret,
--   inkludert telefon og e-post, lå åpent lesbart for alle med den
--   offentlige nøkkelen. Den er fjernet, og koblingen til reisen er også
--   stengt for anonym lesing. Når kundesiden bygges, får den en egen,
--   kontrollert lesevei som kun kan hente navn, valgt bilde, gjeldende
--   presentasjon og rolle for personer på en publisert reise.
--   Telefon og e-post skal ALDRI eksponeres.

-- 1) Personens egen bildebank.
create table trip_leader_images (
  id uuid primary key default gen_random_uuid(),
  trip_leader_id uuid not null references trip_leaders(id) on delete cascade,
  bilde_url text not null,
  alt_tekst text,
  sortering integer not null default 0,
  created_at timestamptz not null default now()
);
alter table trip_leader_images enable row level security;
create policy authenticated_full_access_trip_leader_images
  on trip_leader_images for all to authenticated using (true) with check (true);

-- 2) Eksisterende personbilde (ett per person) flyttet inn i banken.
insert into trip_leader_images (trip_leader_id, bilde_url, sortering)
select id, photo_url, 0 from trip_leaders where photo_url is not null and photo_url <> '';

-- 3) Koblingen eier rolle og valgt bilde. Eksisterende roller fulgte med
--    fra personen, og det ene eksisterende bildet ble valgt bilde.
alter table trip_trip_leaders add column role text;
alter table trip_trip_leaders add column bilde_id uuid references trip_leader_images(id) on delete set null;
update trip_trip_leaders c set role = l.role
from trip_leaders l where l.id = c.trip_leader_id and c.role is null;
update trip_trip_leaders c set bilde_id = i.id
from trip_leader_images i where i.trip_leader_id = c.trip_leader_id and c.bilde_id is null;

-- 4) Rolle og bilde fjernet fra personen (dataene var flyttet først).
alter table trip_leaders drop column role;
alter table trip_leaders drop column photo_url;

-- 5) Tilgang strammet - se toppen.
drop policy if exists public_read_trip_leaders on trip_leaders;
drop policy if exists public_read_trip_trip_leaders on trip_trip_leaders;
comment on table trip_leaders is
  'Personregister. HELT INTERNT - ingen anon-policy. Telefon og e-post er interne operative felt og skal aldri eksponeres. '
  'Rolle og valgt bilde ligger på trip_trip_leaders (per reise), ikke her. Bildene ligger i trip_leader_images.';
comment on table trip_trip_leaders is
  'Person på en reise: role (fritekst), bilde_id (valgt fra personens bank), bio_override (tilpasset presentasjon). '
  'INTERN inntil kundesiden får en kontrollert lesevei.';

-- 6) Om reisen-bilder (trip_images): spor av bankbilde, som på programdagene.
alter table trip_images add column bank_id uuid references reisemaal_bilder(id) on delete set null;
comment on table trip_images is
  'Bilder i Om reisen. bank_id satt = plukket fra reisemaal_bilder; tomt = lastet opp direkte på reisen.';

-- 7) Lagringsplass for personbilder. Selve filene ligger på uforutsigbare
--    adresser (som alle andre bilder i Admin) og skal senere vises på
--    kundesiden. Det som er internt er REGISTERET: hvem, tekst, kontakt og
--    hvilket bilde som hører til hvem.
insert into storage.buckets (id, name, public) values ('person-bilder', 'person-bilder', true)
on conflict (id) do nothing;
create policy "Offentlig lesetilgang person-bilder" on storage.objects
  for select using (bucket_id = 'person-bilder');
create policy "Innloggede kan laste opp person-bilder" on storage.objects
  for insert with check (bucket_id = 'person-bilder' and auth.role() = 'authenticated');
create policy "Innloggede kan slette person-bilder" on storage.objects
  for delete using (bucket_id = 'person-bilder' and auth.role() = 'authenticated');

-- Om reisen sin overskrift og tekst bruker de eksisterende kolonnene
-- trips.intro_heading og trips.intro_text - ingen nye kolonner.

-- ====================================================================
-- DATAKORREKSJON etter migrasjonen (kjørt 2026-09-03, via Supabase MCP).
--
-- Trinn 2) over flyttet trip_leaders.photo_url inn i banken slik verdien
-- sto. For Jan-Tore Olsen var verdien «/images/jan-tore-olsen.webp» - en
-- RELATIV sti fra det gamle nettstedet, som ikke finnes noe sted (404 på
-- caminante.no, og aldri i Admins lagring). Referansen var død allerede
-- før migrasjonen; migrasjonen bare bar den videre. Raden er fjernet, og
-- reisekoblingens bilde_id ble nullet av on delete set null. Et ekte bilde
-- må lastes opp i Personregisteret.
--
-- Youssefs bilde peker på en fullstendig adresse hos det gamle nettstedet
-- (usercontent.one/…/Youssef-4.png). Den virker i dag, men ligger utenfor
-- Admins lagring - verdt å laste opp på nytt i registeret ved anledning.
delete from trip_leader_images
 where id = 'be3cb8d2-9d4b-4391-99d0-0806c15d2dd4'
   and bilde_url = '/images/jan-tore-olsen.webp';
