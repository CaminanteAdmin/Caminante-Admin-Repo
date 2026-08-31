-- ====================================================================
-- DOKUMENTASJON av migrasjon som allerede er kjørt i Supabase.
-- Navn i Supabase: reise_v1_trinn1_reiseinfo
-- Kjørt: 2026-08-31 (via Supabase MCP)
-- Denne filen skal IKKE kjøres på nytt - den gjenspeiler det som ble kjørt.
-- ====================================================================

-- Reise v1.0 trinn 1: Reiseinfo. Kun additivt + én besluttet dataflytting.
-- Prismatrise-tabellene (trip_price_categories/trip_option_prices) og
-- trip_options RØRES IKKE her - de kan være relevante for Bibelcamp og
-- vurderes i den produktgjennomgangen. Editoren slutter bare å bruke dem.

-- 1) Reisemål kobles til Reisemål-registeret.
alter table trips add column reisemaal_id uuid references reisemaal(id) on delete set null;

-- 2) Antall deltakere er Caminantes INTERNE kapasitet og skal ikke ligge
--    på den offentlig lesbare trips-raden. Flyttes til trip_internal.
alter table trip_internal add column antall_deltakere integer;

insert into trip_internal (trip_id, antall_deltakere)
select id, capacity from trips where capacity is not null
on conflict (trip_id) do update set antall_deltakere = excluded.antall_deltakere;

update trips set capacity = null where capacity is not null;
