-- ====================================================================
-- DOKUMENTASJON av migrasjon som allerede er kjørt i Supabase.
-- Navn i Supabase: reiser_v1_grunnstruktur
-- Kjørt: 2026-08-30 (via Supabase MCP, verifisert etterpå:
--        Krakow = 2 alternativer, Marokko = 1, 0 opphold uten alternativ)
-- Denne filen skal IKKE kjøres på nytt - den gjenspeiler det som ble kjørt.
-- ====================================================================

-- Reiser v1: grunnstruktur for Reise-editoren.
-- Kun additivt: nye tabeller, nye nullable/default-kolonner, datamigrering av
-- eksisterende testreiser. Ingen eksisterende kolonner endres eller fjernes.

-- 1) Interne felt i EGEN tabell uten anonym tilgang (Kahn K1: alle kolonner
--    på trips er offentlig lesbare for publiserte reiser - interne data skal
--    aldri ligge der).
create table trip_internal (
  trip_id uuid primary key references trips(id) on delete cascade,
  kalkyle_id uuid references kalkyler(id) on delete set null,
  kalkyle_sist_endret_ved_kobling timestamptz,
  interne_notater text,
  updated_at timestamptz not null default now()
);
alter table trip_internal enable row level security;
create policy authenticated_full_access_trip_internal
  on trip_internal for all to authenticated using (true) with check (true);
-- Bevisst INGEN anon-policy.

-- 2) Overnattingsalternativ: enheten som senere baerer pris/kategorier.
--    capacity null = ingen egen grense (skal aldri tolkes som 0).
--    included_extra/excluded_extra = alternativspesifikke avvik fra reisens
--    felles inkludert-liste (besluttet modell: felles grunnlag + avvik).
create table trip_options (
  id uuid primary key default gen_random_uuid(),
  trip_id uuid not null references trips(id) on delete cascade,
  name text not null default '',
  description text,
  self_arranged boolean not null default false,
  capacity integer,
  active boolean not null default true,
  included_extra text[] not null default '{}',
  excluded_extra text[] not null default '{}',
  sort_order integer not null default 0,
  created_at timestamptz not null default now()
);
alter table trip_options enable row level security;
create policy authenticated_full_access_trip_options
  on trip_options for all to authenticated using (true) with check (true);
-- Bevisst INGEN anon-policy naa: aapnes foerst naar kundesiden faktisk
-- trenger den, med et bevisst kolonneutvalg (prinsipp fra produkteier).

-- 3) Opphold hoerer til et alternativ. Sletting av alternativ tar oppholdene
--    med seg; bookings.selected_trip_hotel_id (NO ACTION) blokkerer fortsatt
--    sletting av et opphold noen har meldt seg paa.
alter table trip_hotels
  add column trip_option_id uuid references trip_options(id) on delete cascade;

-- 4) Nye kundevendte felt paa trips (trygge aa eksponere).
create type trip_accommodation_mode as enum
  ('fast_reiserute','kunden_velger','kunden_onsker');
alter table trips add column accommodation_mode trip_accommodation_mode not null default 'fast_reiserute';
alter table trips add column sections jsonb not null default '{}'::jsonb;
alter table trips add column daily_rhythm jsonb;
alter table trips add column registration_deadline date;
alter table trips add column min_participants integer;
alter table trips add column min_participants_note text;

-- 5) Datamigrering av eksisterende testreiser, slik at editoren aapner dem
--    gjenkjennelig. Reiser med minst ett bookable-hotell (Krakow) faar ett
--    alternativ per hotell; oevrige reiser med hoteller (Marokko m.fl.) faar
--    ett felles "Reiserute"-alternativ med alle oppholdene i rekkefoelge.
insert into trip_options (trip_id, name, sort_order)
select h.trip_id, h.name, h.sort_order
from trip_hotels h
where h.bookable = true;

update trip_hotels h
set trip_option_id = o.id
from trip_options o
where o.trip_id = h.trip_id and o.name = h.name and h.bookable = true
  and h.trip_option_id is null;

update trips t
set accommodation_mode = 'kunden_velger'
where exists (select 1 from trip_hotels h where h.trip_id = t.id and h.bookable = true);

insert into trip_options (trip_id, name, sort_order)
select distinct h.trip_id, 'Reiserute', 0
from trip_hotels h
where h.trip_option_id is null;

update trip_hotels h
set trip_option_id = o.id
from trip_options o
where o.trip_id = h.trip_id and o.name = 'Reiserute'
  and h.trip_option_id is null;

-- Seksjonsvalg utledet av eksisterende innhold: dag-for-dag paa der det
-- finnes programdager, grunnrytme av overalt (ingen har lagret en ennaa).
update trips t
set sections = jsonb_build_object(
  'dagfordag', exists (select 1 from trip_days d where d.trip_id = t.id),
  'grunnrytme', false
);
