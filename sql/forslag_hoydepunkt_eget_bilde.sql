-- ====================================================================
-- DOKUMENTASJON av migrasjon som allerede er kjørt i Supabase.
-- Navn i Supabase: forslag_hoydepunkt_eget_bilde
-- Kjørt: 2026-08-31 (via Supabase MCP)
-- Denne filen skal IKKE kjøres på nytt - den gjenspeiler det som ble kjørt.
-- ====================================================================

-- Et høydepunkt i et reiseforslag kunne til nå BARE peke på et bilde i
-- reisemålets bildebank (valgt_bilde_id). Etter produktregelen av 31.08.2026
-- skal «Last opp bilde» lagre bildet kun på det aktuelle forslaget, og da
-- trengs et sted å lagre selve adressen.
--
-- De to feltene er gjensidig utelukkende i praksis: velger man fra banken
-- settes valgt_bilde_id og bilde_url nulles, laster man opp settes bilde_url
-- og valgt_bilde_id nulles. Ingen databasesperre på det - editoren eier
-- regelen, og både editoren og forslag-print.html lar bilde_url vinne hvis
-- begge skulle være satt (det mest spesifikke valget).
alter table forslag_hoydepunkter add column bilde_url text;
