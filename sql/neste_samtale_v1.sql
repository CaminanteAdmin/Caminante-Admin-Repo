-- "Neste samtale": felles, ikke-hastende huskeliste mellom Vidar og Jan-Tore.
-- Kjørt i Supabase (migrasjon neste_samtale_punkter).
create table if not exists public.neste_samtale (
  id uuid primary key default gen_random_uuid(),
  tekst text not null,
  notat text,
  opprettet_av uuid references public.profiles(id) on delete set null default auth.uid(),
  opprettet_ved timestamptz not null default now(),
  ferdig boolean not null default false,
  ferdig_av uuid references public.profiles(id) on delete set null,
  ferdig_ved timestamptz
);

create index if not exists neste_samtale_ferdig_idx on public.neste_samtale (ferdig, opprettet_ved);

alter table public.neste_samtale enable row level security;

create policy "Innloggede har full tilgang"
  on public.neste_samtale
  for all
  using (auth.role() = 'authenticated')
  with check (auth.role() = 'authenticated');
