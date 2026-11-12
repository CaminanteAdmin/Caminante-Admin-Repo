-- Kontaktinfo til reiserådgiver i tilbuds-/forslags-PDF (forslag-print.html).
-- pdf_navn brukes i PDF i stedet for navn når det er satt.
alter table public.profiles
  add column if not exists pdf_navn text,
  add column if not exists telefon text,
  add column if not exists kontakt_epost text;

update public.profiles set pdf_navn = 'Jan-Tore Olsen', telefon = '48 26 50 53', kontakt_epost = 'post@caminante.no'
 where id = '3b8d4be7-8425-47e4-b250-3e7d743d5806';
update public.profiles set telefon = '41 57 24 72', kontakt_epost = 'vidar@okreiser.no'
 where id = '12b37edb-3266-483e-b445-69fbc3f855d4';
