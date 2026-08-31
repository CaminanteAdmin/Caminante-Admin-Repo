-- ====================================================================
-- DOKUMENTASJON av migrasjon som allerede er kjørt i Supabase.
-- Navn i Supabase: reiser_4a_prismatrise
-- Kjørt: 2026-08-31 (via Supabase MCP)
-- Denne filen skal IKKE kjøres på nytt - den gjenspeiler det som ble kjørt.
--
-- MERK: Editor-funksjonaliteten som brukte disse tabellene (prismatrise,
-- priskategorier, kundevaluta-lås) ble FORKASTET før den ble committet, da
-- produktspesifikasjonen for Reise v1.0 (31.08.2026) erstattet modellen med
-- én hovedpris + enkeltromstillegg + valgfrie tillegg. Tabellene og
-- triggerne står igjen i basen, tomme og ubrukte, i påvente av
-- Bibelcamp-produktgjennomgangen - de kan være relevante der (f.eks.
-- barnepriser). Ingen kode i repoet leser eller skriver dem i dag.
-- ====================================================================

-- Reiser 4a: priskategorier, prismatrise og tillegg. Kun additivt.
-- Ingen anon-tilgang: aapnes bevisst naar kundesiden trenger den.

-- 1) Priskategori beskriver PERSONEN. Reisen definerer sine egne.
create table trip_price_categories (
  id uuid primary key default gen_random_uuid(),
  trip_id uuid not null references trips(id) on delete cascade,
  name text not null default '',
  note text,
  active boolean not null default true,
  sort_order integer not null default 0,
  created_at timestamptz not null default now()
);
alter table trip_price_categories enable row level security;
create policy authenticated_full_access_trip_price_categories
  on trip_price_categories for all to authenticated using (true) with check (true);

-- 2) Matrisecellen: overnattingsalternativ x priskategori.
--    FRAVAER AV RAD = "ikke utfylt".
create table trip_option_prices (
  id uuid primary key default gen_random_uuid(),
  trip_id uuid not null references trips(id) on delete cascade,
  trip_option_id uuid not null references trip_options(id) on delete cascade,
  category_id uuid not null references trip_price_categories(id) on delete cascade,
  state text not null,
  amount numeric(12,2),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint trip_option_prices_state_ck check (state in ('pris','ikke_tilbudt')),
  constraint trip_option_prices_belop_ck check (
    (state = 'pris' and amount is not null and amount >= 0)
    or (state = 'ikke_tilbudt' and amount is null)
  ),
  constraint trip_option_prices_unik unique (trip_option_id, category_id)
);
alter table trip_option_prices enable row level security;
create policy authenticated_full_access_trip_option_prices
  on trip_option_prices for all to authenticated using (true) with check (true);

-- 3) Tillegg med EKSPLISITT gjelder-omfang.
create table trip_supplements (
  id uuid primary key default gen_random_uuid(),
  trip_id uuid not null references trips(id) on delete cascade,
  name text not null default '',
  amount numeric(12,2),
  calc text not null default 'per_person',
  scope text not null default 'reise',
  trip_option_id uuid references trip_options(id) on delete cascade,
  sort_order integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint trip_supplements_calc_ck check (calc in ('per_person','per_bestilling')),
  constraint trip_supplements_scope_ck check (
    (scope = 'reise' and trip_option_id is null)
    or (scope = 'alternativ' and trip_option_id is not null)
  ),
  constraint trip_supplements_belop_ck check (amount is null or amount >= 0)
);
alter table trip_supplements enable row level security;
create policy authenticated_full_access_trip_supplements
  on trip_supplements for all to authenticated using (true) with check (true);

-- 4) Kundevaluta: NY kolonne uten standardverdi.
alter table trips add column customer_currency text;

-- 5) VALUTALAASEN i databasen.
create or replace function trips_valutalaas() returns trigger as $$
begin
  if new.customer_currency is distinct from old.customer_currency then
    if exists (select 1 from trip_option_prices p
               where p.trip_id = old.id and p.state = 'pris')
       or exists (select 1 from trip_supplements s
                  where s.trip_id = old.id and s.amount is not null)
    then
      raise exception 'VALUTALAAS: Reisen har utfylte beloep. Fjern beloepene foer kundevalutaen kan endres.';
    end if;
  end if;
  return new;
end;
$$ language plpgsql;

create trigger trips_valutalaas_trg
  before update on trips
  for each row execute function trips_valutalaas();

-- 6) Et beloep uten valuta avvises.
create or replace function krev_kundevaluta() returns trigger as $$
declare v text;
begin
  if new.amount is not null then
    select customer_currency into v from trips where id = new.trip_id;
    if v is null then
      raise exception 'VALUTA_MANGLER: Velg kundevaluta paa reisen foer du legger inn beloep.';
    end if;
  end if;
  return new;
end;
$$ language plpgsql;

create trigger trip_option_prices_valuta_trg
  before insert or update on trip_option_prices
  for each row execute function krev_kundevaluta();

create trigger trip_supplements_valuta_trg
  before insert or update on trip_supplements
  for each row execute function krev_kundevaluta();
