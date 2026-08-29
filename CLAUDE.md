# Caminante Admin

Internt admin-verktøy for Caminante Travel AS. Statiske HTML-sider i `site/`,
Cloudflare Worker i `worker.js`, Supabase som database og innlogging.

## Git-arbeidsflyt

Vidar beholder godkjenningen og kontrollen. Claude håndterer selve Git-arbeidet.

1. Claude gjør kodeendringene.
2. `kaia`-subagenten kvalitetssikrer når det er relevant (read-only QA).
3. Vidar tester manuelt og godkjenner.
4. **Ikke commit eller push mens vi utvikler eller tester.**
5. Når Vidar sier at endringen er godkjent, foreslår Claude en kort og
   beskrivende commitmelding.
6. Før commit viser Claude hvilke filer som vil bli inkludert.
7. Når Vidar eksplisitt godkjenner commit/push, gjør Claude både commit og push.
8. Ikke inkluder andre endrede filer uten å gjøre Vidar oppmerksom på det først.
9. **Aldri force-push eller omskriv publisert Git-historikk** uten at Vidar
   uttrykkelig ber om det.

Punkt 4 og 7 er absolutte: ingen commit eller push uten en eksplisitt
godkjenning fra Vidar i den aktuelle økten. En godkjenning gjelder for den ene
endringen den ble gitt for, ikke for senere endringer.

## Hvorfor arbeidsflyten er slik

- Ingen tester, ingen linting, ingen CI. Ingenting fanger feil automatisk.
- Ingen staging. Push til `main` kan gå rett i produksjon via Cloudflare.
- Autolagring skriver til produksjonsdatabasen 1,5-2,5 sekunder etter en
  endring, så en feil som korrumperer tilstand i UI blir fort permanent.

Manuell testing er derfor den eneste ekte kontrollen før produksjon, og den må
være gjort før noe committes.

## Lokal testing

`node`, `npm` og `wrangler` er ikke installert på utviklingsmaskinen. Start
testserveren slik i stedet, fra `site/`:

```bash
python3 -m http.server 8788 --bind 127.0.0.1
```

Det dekker alt unntatt `/api/bildebank/*` (R2-opplasting), som krever worker.
Supabase-URL og anon-nøkkel er hardkodet i `site/shared/supabase-client.js`, så
innlogging, kalkyler og forslag virker uten worker. Merk at lokal testing går
mot **produksjonsdatabasen** - bruk forslag og kalkyler som kan ofres.
