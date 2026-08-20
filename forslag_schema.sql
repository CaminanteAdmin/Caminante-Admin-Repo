-- ============================================================
-- Forslag & Tilbud - v1 datamodell
-- Kjøres i sin helhet, i denne rekkefølgen. Trygt å kjøre på nytt
-- (alt er "if not exists" / "on conflict do nothing" der det er mulig).
-- ============================================================

-- ---------- Enums ----------

do $$ begin
  create type forslag_status as enum (
    'Utkast','Sendt','Kunde interessert','Gått videre til tilbud','Avslått','Arkivert'
  );
exception when duplicate_object then null; end $$;

do $$ begin
  create type forslag_kundetype as enum ('Firma','Skole','Forening','Annen gruppe');
exception when duplicate_object then null; end $$;

do $$ begin
  create type forslag_transporttype as enum ('Fly','Buss','Tog','Ferge','Annet');
exception when duplicate_object then null; end $$;

do $$ begin
  create type forslag_bildekategori as enum ('Hovedbilde','Destinasjon','Hotell','Program');
exception when duplicate_object then null; end $$;

-- ---------- Hovedtabell ----------

create sequence if not exists forslag_lopenummer_seq;

create table if not exists public.forslag (
  id uuid primary key default gen_random_uuid(),
  lopenummer integer not null default nextval('forslag_lopenummer_seq'),
  forslagsnummer text unique,

  -- Grunninfo
  tittel text not null,
  destinasjon text,
  kundetype forslag_kundetype not null default 'Annen gruppe',
  kunde_navn text,
  kontaktperson text,
  skole_id uuid references public.skoler(id) on delete set null,
  ansvarlig uuid references public.profiles(id) on delete set null,
  antall_reisende integer,
  fra_dato date,
  til_dato date,
  periode_tekst text,
  avreisested text,
  status forslag_status not null default 'Utkast',
  interne_notater text,

  -- Kobling mot Priskalkulator (kalkyle "eier" prisen, forslag presenterer en frosset kopi)
  kalkyle_id uuid references public.kalkyler(id) on delete set null,
  kalkyle_sist_endret_ved_kobling timestamptz,

  -- Pris (kun det kunden skal se - ingen kost/margin/provisjon her)
  pris_per_person numeric,
  er_fra_pris boolean not null default false,
  pris_antall_personer integer,
  valuta text not null default 'NOK',
  kursgrunnlag text,
  enkeltromstillegg numeric,
  prisgrunnlag_forklaring text,
  pris_intern_kommentar text,

  -- Inkludert / ikke inkludert
  inkludert text[] not null default '{}',
  ikke_inkludert text[] not null default '{}',

  -- Presentasjonstekster
  ingress text,
  om_reisemalet text,
  om_hotellet text,
  muligheter_opplevelser text,
  hvorfor_passer text,

  -- Forbehold (default = standardtekst, kan overstyres per forslag)
  forbehold_tekst text not null default
    'Priser og kapasitet er indikative og ikke reservert. Fly- og hotellpriser kan endres frem til bestilling. Endelig pris og kapasitet bekreftes dersom dere ønsker å gå videre med dette forslaget.',

  hovedbilde_url text,

  opprettet_av uuid references public.profiles(id) on delete set null,
  opprettet_dato timestamptz not null default now(),
  sist_endret timestamptz not null default now()
);

create index if not exists forslag_status_idx on public.forslag(status);
create index if not exists forslag_skole_idx on public.forslag(skole_id);
create index if not exists forslag_kalkyle_idx on public.forslag(kalkyle_id);

-- Forslagsnummer genereres automatisk ved opprettelse, f.eks. F-2026-014
create or replace function set_forslagsnummer()
returns trigger as $$
begin
  if new.forslagsnummer is null then
    new.forslagsnummer := 'F-' || to_char(now(), 'YYYY') || '-' || lpad(new.lopenummer::text, 3, '0');
  end if;
  return new;
end;
$$ language plpgsql;

drop trigger if exists trg_forslag_forslagsnummer on public.forslag;
create trigger trg_forslag_forslagsnummer
  before insert on public.forslag
  for each row execute function set_forslagsnummer();

-- Gjenbruker eksisterende set_sist_endret()-funksjon (samme som skoler/hoteller/kalkyler)
drop trigger if exists trg_forslag_sist_endret on public.forslag;
create trigger trg_forslag_sist_endret
  before update on public.forslag
  for each row execute function set_sist_endret();

-- ---------- Transport (fly/buss/tog/ferge/annet - flere segmenter per forslag) ----------

create table if not exists public.forslag_transport (
  id uuid primary key default gen_random_uuid(),
  forslag_id uuid not null references public.forslag(id) on delete cascade,
  sortering integer not null default 0,
  transporttype forslag_transporttype not null default 'Fly',
  retning text, -- f.eks. 'Utreise' / 'Hjemreise', fritekst
  dato date,
  selskap text, -- flyselskap / operatør
  fra_sted text,
  til_sted text,
  avgangstid text,
  ankomsttid text,
  mellomlanding text,
  bagasje_info text,
  flightinfo text,
  prisreferanse text,
  created_at timestamptz not null default now()
);

create index if not exists forslag_transport_forslag_idx on public.forslag_transport(forslag_id);

-- ---------- Hotellopphold (flere per forslag, alternativ_til for fremtidige alternativer) ----------

create table if not exists public.forslag_hotellopphold (
  id uuid primary key default gen_random_uuid(),
  forslag_id uuid not null references public.forslag(id) on delete cascade,
  sortering integer not null default 0,
  alternativ_til uuid references public.forslag_hotellopphold(id) on delete cascade,
  sted text,
  fra_dato date,
  til_dato date,
  netter integer,
  hotellnavn text,
  standard text,
  romtype text,
  maltider text,
  beskrivelse text,
  prisinfo text,
  tilgjengelighet_merknad text,
  created_at timestamptz not null default now()
);

create index if not exists forslag_hotellopphold_forslag_idx on public.forslag_hotellopphold(forslag_id);

-- ---------- Dagsprogram ----------

create table if not exists public.forslag_dagsprogram (
  id uuid primary key default gen_random_uuid(),
  forslag_id uuid not null references public.forslag(id) on delete cascade,
  dagnummer integer,
  dato date,
  overskrift text,
  tekst text,
  aktiviteter text[] not null default '{}',
  maltider text[] not null default '{}',
  sortering integer not null default 0,
  created_at timestamptz not null default now()
);

create index if not exists forslag_dagsprogram_forslag_idx on public.forslag_dagsprogram(forslag_id);

-- ---------- Bilder (felles for hele forslaget) ----------

create table if not exists public.forslag_bilder (
  id uuid primary key default gen_random_uuid(),
  forslag_id uuid not null references public.forslag(id) on delete cascade,
  kategori forslag_bildekategori not null default 'Destinasjon',
  hotellopphold_id uuid references public.forslag_hotellopphold(id) on delete cascade,
  dagsprogram_id uuid references public.forslag_dagsprogram(id) on delete cascade,
  bilde_url text not null,
  alt_tekst text,
  sortering integer not null default 0,
  created_at timestamptz not null default now()
);

create index if not exists forslag_bilder_forslag_idx on public.forslag_bilder(forslag_id);

-- ---------- RLS (samme mønster som skoler/hoteller/kalkyler: innloggede har full tilgang) ----------

alter table public.forslag enable row level security;
alter table public.forslag_transport enable row level security;
alter table public.forslag_hotellopphold enable row level security;
alter table public.forslag_dagsprogram enable row level security;
alter table public.forslag_bilder enable row level security;

drop policy if exists "Innloggede har full tilgang" on public.forslag;
create policy "Innloggede har full tilgang" on public.forslag
  for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');

drop policy if exists "Innloggede har full tilgang" on public.forslag_transport;
create policy "Innloggede har full tilgang" on public.forslag_transport
  for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');

drop policy if exists "Innloggede har full tilgang" on public.forslag_hotellopphold;
create policy "Innloggede har full tilgang" on public.forslag_hotellopphold
  for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');

drop policy if exists "Innloggede har full tilgang" on public.forslag_dagsprogram;
create policy "Innloggede har full tilgang" on public.forslag_dagsprogram
  for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');

drop policy if exists "Innloggede har full tilgang" on public.forslag_bilder;
create policy "Innloggede har full tilgang" on public.forslag_bilder
  for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');

-- ---------- Supabase Storage: bilder til Forslag ----------
-- Offentlig lesetilgang (bildene skal vises i PDF/forhåndsvisning uten
-- innlogging), men kun innloggede kan laste opp/slette.

insert into storage.buckets (id, name, public)
values ('forslag-bilder', 'forslag-bilder', true)
on conflict (id) do nothing;

drop policy if exists "Offentlig lesetilgang forslag-bilder" on storage.objects;
create policy "Offentlig lesetilgang forslag-bilder" on storage.objects
  for select using (bucket_id = 'forslag-bilder');

drop policy if exists "Innloggede kan laste opp forslag-bilder" on storage.objects;
create policy "Innloggede kan laste opp forslag-bilder" on storage.objects
  for insert with check (bucket_id = 'forslag-bilder' and auth.role() = 'authenticated');

drop policy if exists "Innloggede kan slette forslag-bilder" on storage.objects;
create policy "Innloggede kan slette forslag-bilder" on storage.objects
  for delete using (bucket_id = 'forslag-bilder' and auth.role() = 'authenticated');
