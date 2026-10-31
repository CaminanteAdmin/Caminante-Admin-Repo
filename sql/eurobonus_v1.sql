-- EuroBonus-modul: oversikt over poengkontoene (Caminante, Vidar, Jan-Tore) og bonusreiser.
-- Kjørt i Supabase (migrasjon eurobonus_kontoer_og_reiser).

create table if not exists public.eurobonus_kontoer (
  konto text primary key check (konto in ('caminante','vidar','jan-tore')),
  saldo bigint check (saldo is null or saldo >= 0),
  saldo_dato date,
  inngaaende_saldo bigint check (inngaaende_saldo is null or inngaaende_saldo >= 0), -- per 31.12.2026
  sist_endret timestamptz not null default now()
);

insert into public.eurobonus_kontoer (konto) values ('caminante'), ('vidar'), ('jan-tore')
on conflict (konto) do nothing;

create table if not exists public.eurobonus_reiser (
  id uuid primary key default gen_random_uuid(),
  konto text not null references public.eurobonus_kontoer(konto),
  reisetype text not null check (reisetype in ('enkel','tur_retur','open_jaw')),
  fra text not null,
  til text not null,
  dato date not null,
  retur_fra text,
  retur_til text,
  retur_dato date,
  poeng integer not null check (poeng >= 0),          -- totalt for hele bestillingen
  skatter numeric(10,2) not null default 0 check (skatter >= 0), -- totalt, NOK
  antall_personer integer not null default 1 check (antall_personer >= 1),
  reisende text[] not null default '{}',
  notat text,
  opprettet_av uuid references public.profiles(id) on delete set null default auth.uid(),
  opprettet_ved timestamptz not null default now(),
  constraint eurobonus_reiser_retur_ok check (
    reisetype = 'enkel' or (retur_fra is not null and retur_til is not null and retur_dato is not null)
  )
);

create index if not exists eurobonus_reiser_opprettet_idx on public.eurobonus_reiser (opprettet_ved desc);

alter table public.eurobonus_kontoer enable row level security;
alter table public.eurobonus_reiser enable row level security;

create policy "Innloggede har full tilgang" on public.eurobonus_kontoer
  for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');
create policy "Innloggede har full tilgang" on public.eurobonus_reiser
  for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');

-- ---------------------------------------------------------------------------
-- v2 (migrasjon eurobonus_samlet_saldo): én samlet saldo (den faktiske saldoen
-- på kontoen) føres manuelt. Fordelingen regnes ut i eurobonus.html:
--   Vidar     = inngående 31.12.2026 - poeng brukt fra Vidars konto
--   Jan-Tore  = inngående 31.12.2026 - poeng brukt fra Jan-Tores konto
--   Caminante = samlet saldo - Vidar - Jan-Tore   (alt opptjent etter 01.01.2027)
create table if not exists public.eurobonus_saldo (
  id smallint primary key default 1 check (id = 1),
  saldo bigint check (saldo is null or saldo >= 0),
  saldo_dato date,
  sist_endret timestamptz not null default now()
);
insert into public.eurobonus_saldo (id) values (1) on conflict (id) do nothing;

alter table public.eurobonus_saldo enable row level security;
create policy "Innloggede har full tilgang" on public.eurobonus_saldo
  for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');

-- Kolonnene saldo/saldo_dato på eurobonus_kontoer brukes ikke lenger (beholdes inntil videre).

-- v3 (migrasjon eurobonus_inngaaende_kan_vaere_negativ): inngående saldo kan være
-- negativ (en konto kan ha lånt av de andre allerede ved oppstart).
alter table public.eurobonus_kontoer drop constraint if exists eurobonus_kontoer_inngaaende_saldo_check;

-- v4 (migrasjon eurobonus_companion_tickets): companion tickets - inngående antall
-- per konto (31.12.2026) og antall brukt per bonusreise.
alter table public.eurobonus_kontoer
  add column if not exists inngaaende_companion integer not null default 0 check (inngaaende_companion >= 0);
update public.eurobonus_kontoer set inngaaende_companion = 2 where konto = 'jan-tore';

alter table public.eurobonus_reiser
  add column if not exists companion_brukt integer not null default 0 check (companion_brukt >= 0);

-- v5 (migrasjon eurobonus_companion_saldo): companion tickets (CT) - samlet CT-saldo på
-- kontoen føres manuelt, og Vidars/Jan-Tores CT-saldo føres manuelt per konto.
-- Caminantes CT = samlet - Vidar - Jan-Tore.
alter table public.eurobonus_saldo
  add column if not exists companion integer check (companion is null or companion >= 0);
alter table public.eurobonus_kontoer
  add column if not exists companion_saldo integer not null default 0;
update public.eurobonus_kontoer set companion_saldo = 2 where konto = 'jan-tore';
