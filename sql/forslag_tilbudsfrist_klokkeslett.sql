-- Valgfritt klokkeslett på tilbudsfristen (HH:MM), vises i tilbuds-PDF.
alter table public.forslag add column if not exists tilbudsfrist_klokkeslett text;
