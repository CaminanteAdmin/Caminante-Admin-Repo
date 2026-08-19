# sql/

Her ligger SQL-migreringene som er kjørt manuelt i Supabase SQL Editor
(schema.sql, kalender-/hoteller-migreringer, skole-import osv.) .

Denne mappen ligger BEVISST utenfor `site/`, som er den eneste mappen
`wrangler.jsonc` peker til (`assets.directory: "./site"`). Filene her
blir derfor aldri en del av selve nettstedet og lastes aldri opp til
live-siden - de er kun til referanse/historikk i git.

Legg inn dine eksisterende .sql-filer her ved behov.
