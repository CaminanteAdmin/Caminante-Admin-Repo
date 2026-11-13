-- DOKUMENTASJON av migrasjon som allerede er kjørt i Supabase.
-- Navn i Supabase: trips_cancellation_rows
-- Kjørt: 2026-11-13 (via Supabase MCP)
-- Avbestillingstabellen for påmeldingsturer, redigert i Reisebetingelser-fanen
-- i reise-editor.html. Array av {when, refund}, f.eks.
--   [{"when":"Mer enn 60 dager før avreise","refund":"Innbetalt beløp refunderes, med unntak av depositum"}]
-- NULL = Caminantes standardtabell (Caminante Web må falle tilbake til standard).
-- [] = ingen avbestillingstabell vises.
alter table public.trips add column if not exists cancellation_rows jsonb;
