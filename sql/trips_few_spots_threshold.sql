-- DOKUMENTASJON av migrasjon som allerede er kjørt i Supabase.
-- Navn i Supabase: trips_few_spots_threshold
-- Kjørt: 2026-11-13 (via Supabase MCP)
-- Antall ledige plasser (eller færre) hvor en påmeldingstur vises som
-- «Få plasser igjen». Settes i Priser-fanen i reise-editor.html.
alter table public.trips add column if not exists few_spots_threshold integer default 5;
