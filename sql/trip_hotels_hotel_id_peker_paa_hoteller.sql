-- ====================================================================
-- DOKUMENTASJON av migrasjon som allerede er kjørt i Supabase.
-- Navn i Supabase: trip_hotels_hotel_id_peker_paa_hoteller
-- Kjørt: 2026-08-30 (via Supabase MCP, verifisert etterpå: FK peker på
--        hoteller med delete_rule SET NULL)
-- Denne filen skal IKKE kjøres på nytt - den gjenspeiler det som ble kjørt.
-- ====================================================================

-- Rettelse: trip_hotels.hotel_id pekte på den tomme, ubrukte tabellen
-- "hotels" (engelsk tabellfamilie fra før Admin). Reise-editorens
-- "Hent fra hotelloversikt" kopierer fra Admin-registeret "hoteller",
-- så enhver kopiering ga FK-brudd. Ingen rad har hotel_id satt (verifisert
-- 0 rader), så ompekingen er ren. Samme navn og sletteregel beholdes.
alter table trip_hotels drop constraint trip_hotels_hotel_id_fkey;
alter table trip_hotels
  add constraint trip_hotels_hotel_id_fkey
  foreign key (hotel_id) references hoteller(id) on delete set null;
