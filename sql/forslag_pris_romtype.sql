-- Romtype prisen gjelder for i PDF (forslag-print.html). null = delt dobbeltrom.
alter table public.forslag add column if not exists pris_romtype text;
