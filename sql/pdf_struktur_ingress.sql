-- ====================================================================
-- DOKUMENTASJON av migrasjon som allerede er kjørt i Supabase.
-- Navn i Supabase: pdf_struktur_ingress  (05.09.2026, via Supabase MCP)
-- Denne filen skal IKKE kjøres på nytt - den gjenspeiler det som ble kjørt.
-- ====================================================================

-- PDF-struktur for Reiseforslag og Tilbud (05.09.2026).
--
-- Forsiden får en egen kort ingress (nytt felt). forslag.om_reisen - som
-- til nå var forsidens tekst (60 ord) - blir den romslige salgsteksten
-- på side 2 «Om reisen» (maks 1 500 tegn), sammen med galleriet.
--
-- forslag.om_reisemalet og forslag.muligheter_opplevelser vises ikke
-- lenger i PDF-en. om_reisemalet er skjult i editoren, men BEHOLDES i
-- basen og lagres uendret (ingen data slettes). Ingen kolonner fjernes.
--
-- Alle PDF-tekster begrenses nå i TEGN i editoren (ikke ord), fordi
-- ordgrenser ikke ga forutsigbar høyde i PDF-en. Et linjeskift teller som
-- 100 tegn. Grensene er målt mot den faktiske PDF-layouten og håndheves i
-- site/forslag-editor.html (TEGN-konstanten) - ikke i databasen.
alter table forslag add column if not exists ingress text;
comment on column forslag.ingress is
  'Kort ingress på PDF-ens forside (maks 350 tegn, ingen linjeskift). om_reisen er den lange teksten på side 2.';

-- DUPLISERING (site/forslag.html) kopierer hele raden («...rest»), så
-- ingress arves av en kopi på samme måte som de andre tekstfeltene.
