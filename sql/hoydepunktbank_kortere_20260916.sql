-- ====================================================================
-- DOKUMENTASJON av dataendring som er kjørt i Supabase (16.09.2026, via Supabase MCP).
-- Denne filen skal IKKE kjøres på nytt - den gjenspeiler det som ble kjørt.
-- Sikkerhetskopi av hele tabellen FØR endringen: reisemaal_hoydepunkter_backup_20260916
-- ====================================================================
--
-- Oppryddingsrunde pkt 13B: destinasjonsbankens høydepunkter er malen for
-- Gruppetilbud, og standardinnholdet skal passe rett inn i PDF-ens
-- høydepunktkort (114 px høyt: tittel på én linje i 176 px bredde,
-- beskrivelse 1-2 korte setninger, ca. 80-120 tegn). Alle 310 rader ble
-- målt: 107 titler var for brede for én linje og 72 beskrivelser over 125
-- tegn. 161 rader er endret (tittel og/eller tekst); resten står urørt.
-- Kun navn/korttekst er rørt - id, rekkefølge og reisemål er uendret, så
-- eksisterende gruppetilbud beholder sine koblinger (og sin egen lokale
-- tekst der den finnes, se navn_override/korttekst_override).
--
-- Før -> etter per rad:
--
-- ### Aberdeen
--   b784eef7 tittel:  «Royal Deeside og Balmoral» -> «Royal Deeside»
--   96c3cff9 tittel:  «Slottsruten: Crathes og Fyvie» -> «Crathes og Fyvie»
--   96c3cff9 tekst:   «Aberdeenshire har flere slott enn noen annen del av Skottland, med de malte takene og hagene på Crathes og det eventyrlige Fyvie som høydepunkter.»
--            -> «Aberdeenshire har flere slott enn noen annen del av Skottland – Crathes med de malte takene og eventyrlige Fyvie.»
--   7c7df3d1 tittel:  «Speyside og whiskydestilleriene» -> «Speyside»
--   7c7df3d1 tekst:   «Verdens tetteste samling av whiskydestillerier, med omvisning og smaking hos Glenfiddich, Macallan eller mindre destillerier.»
--            -> «Verdens tetteste samling av whiskydestillerier, med omvisning og smaking hos Glenfiddich eller Macallan.»
--   c9058f26 tekst:   «Middelalderbydelen med St Machar-katedralen, King's College fra 1495 og brosteinsgater rundt et av Skottlands eldste universiteter.»
--            -> «Middelalderbydelen med St Machar-katedralen, King's College fra 1495 og brosteinsgater rundt universitetet.»
--
-- ### Amsterdam
--   41a2c243 tittel:  «Kanalbåt gjennom grachtene» -> «Kanalbåt»
--   41a2c243 tekst:   «Byens 1600-tallskanaler sett fra vannet, med kjøpmannshusene, broene og husbåtene, den klassiske introduksjonen til Amsterdam.»
--            -> «Byens 1600-tallskanaler sett fra vannet, med kjøpmannshus, broer og husbåter – den klassiske introduksjonen.»
--   e4d71fa6 tittel:  «Jordaan og De Negen Straatjes» -> «Jordaan»
--   e4d71fa6 tekst:   «Den gamle arbeiderbydelen med smale gater, kafeer og markeder, og de ni handlegatene mellom kanalene med små butikker.»
--            -> «Den gamle arbeiderbydelen med smale gater, kafeer og markeder, og de ni små handlegatene mellom kanalene.»
--   13fd893b tittel:  «Keukenhof og tulipanmarkene» -> «Keukenhof»
--   13fd893b tekst:   «Verdens største blomsterpark med syv millioner løker i blomst fra mars til mai, omgitt av fargerike tulipanmarker.»
--            -> «Verdens største blomsterpark med syv millioner løker i blomst fra mars til mai, omgitt av tulipanmarker.»
--
-- ### Alicante
--   ca8ccc2e tittel:  «Explanada de España og Postiguet» -> «Explanada de España»
--   ca8ccc2e tekst:   «Den berømte promenaden med seks millioner marmorfliser i bølgemønster under palmene, og bystranden rett ved sentrum.»
--            -> «Den berømte promenaden med seks millioner marmorfliser i bølgemønster under palmene, med bystranden rett ved.»
--   57a8d7d0 tittel:  «Mercado Central og Rambla» -> «Mercado Central»
--   57a8d7d0 tekst:   «Matmarkedet fra 1921 med lokale produkter, og Rambla med kafeer, butikker og byliv fra sentrum til havnen.»
--            -> «Matmarkedet fra 1921 med lokale produkter, og Rambla med kafeer, butikker og byliv fra sentrum til havnen.»
--   3f78ab78 tekst:   «Byen med Europas største palmehage, over 200 000 palmer på UNESCOs liste, og basilikaen med det middelalderske Elche-mysteriet.»
--            -> «Byen med Europas største palmehage – over 200 000 palmer på UNESCOs liste – og basilikaen med Elche-mysteriet.»
--
-- ### Athen
--   c393dd9b tekst:   «Antikkens torg og møteplass, der Sokrates diskuterte med athenerne og Paulus ifølge Apostlenes gjerninger talte fra Areopagos-høyden.»
--            -> «Antikkens torg der Sokrates diskuterte med athenerne, og Areopagos-høyden der Paulus ifølge Apostlenes gjerninger talte.»
--   6b11d7f9 tekst:   «Dagstur til ruinene av antikkens Korint, byen Paulus bodde i og skrev til, og den imponerende Korintkanalen skåret gjennom fjellet.»
--            -> «Dagstur til ruinene av antikkens Korint, byen Paulus bodde i og skrev til, og den imponerende Korintkanalen.»
--
-- ### Bali
--   a31a6967 tittel:  «Rismarkene i Tegallalang og Jatiluwih» -> «Rismarkene»
--   a31a6967 tekst:   «De berømte terrasserte rismarkene, med Jatiluwih på UNESCOs liste for det tradisjonelle subak-vanningssystemet.»
--            -> «De berømte terrasserte rismarkene i Tegallalang og Jatiluwih, sistnevnte på UNESCOs liste for subak-vanningen.»
--   6771ca51 tittel:  «Snorkling i Amed og Nusa Penida» -> «Snorkling»
--   6771ca51 tekst:   «Korallrev og det japanske skipsvraket ved Amed i øst, eller båttur til Nusa Penida med Kelingking-stranden og mantarokker.»
--            -> «Korallrev og det japanske skipsvraket ved Amed, eller båttur til Nusa Penida med Kelingking-stranden og mantarokker.»
--   4d0bef05 tittel:  «Balinesisk landsby og seremonier» -> «Balinesisk landsby»
--   4d0bef05 tekst:   «Besøk i en tradisjonell landsby som Penglipuran, med tempelseremoni, ofringer og innblikk i det balinesiske hverdagslivet.»
--            -> «Besøk i en tradisjonell landsby som Penglipuran, med tempelseremoni, ofringer og innblikk i hverdagslivet.»
--
-- ### Barcelona
--   aa6be267 tittel:  «Det gotiske kvarteret og katedralen» -> «Det gotiske kvarteret»
--   aa6be267 tekst:   «Barcelonas middelalderkjerne med smale gater, romerske murer, katedralen og plasser der byens historie ligger tett.»
--            -> «Barcelonas middelalderkjerne med smale gater, romerske murer, katedralen og plasser der historien ligger tett.»
--   4e75939d tekst:   «Gaudís ufullendte basilika, et av verdens mest særegne kirkebygg, med skoglignende søyler og lys gjennom fargerike glassmalerier.»
--            -> «Gaudís ufullendte basilika med skoglignende søyler og lys gjennom fargerike glassmalerier – et av verdens mest særegne kirkebygg.»
--   7c4dcc3e tittel:  «Camp Nou og FC Barcelona» -> «Camp Nou»
--
-- ### Berlin
--   f7515470 tittel:  «Brandenburger Tor og Riksdagen» -> «Brandenburger Tor»
--   f7515470 tekst:   «Byens symbol ved Pariser Platz, og parlamentsbygningen med glasskuppelen og utsikt over Berlin, med besøk etter forhåndsbestilling.»
--            -> «Byens symbol ved Pariser Platz, og Riksdagen med glasskuppelen og utsikt over Berlin (forhåndsbestilling).»
--   f487496d tittel:  «Berlinmuren og Bernauer Straße» -> «Berlinmuren»
--   f487496d tekst:   «Minnestedet der Muren står bevart med dødsstripen, vakttårnet og dokumentasjonssenteret om den delte byen.»
--            -> «Minnestedet ved Bernauer Straße der Muren står bevart med dødsstripen, vakttårnet og dokumentasjonssenteret.»
--   23232763 tittel:  «Checkpoint Charlie og den kalde krigen» -> «Checkpoint Charlie»
--   23232763 tekst:   «Den berømte grenseovergangen mellom øst og vest, med Mauermuseum og DDR-museet om hverdagen i Øst-Berlin.»
--            -> «Den berømte grenseovergangen mellom øst og vest, med Mauermuseum og DDR-museet om hverdagen i Øst-Berlin.»
--   1d8775e4 tittel:  «Holocaust-minnesmerket og Topographie des Terrors» -> «Holocaust-minnesmerket»
--   1d8775e4 tekst:   «Stelefeltet ved Brandenburger Tor, og dokumentasjonssenteret på stedet der Gestapo og SS hadde sine hovedkvarterer.»
--            -> «Stelefeltet ved Brandenburger Tor, og Topographie des Terrors der Gestapo og SS hadde sine hovedkvarterer.»
--   fa4f8329 tittel:  «East Side Gallery og Kreuzberg» -> «East Side Gallery»
--   fa4f8329 tekst:   «Den lengste bevarte delen av Muren, malt av kunstnere fra hele verden, og den mangfoldige bydelen Kreuzberg rett ved.»
--            -> «Den lengste bevarte delen av Muren, malt av kunstnere fra hele verden, og den mangfoldige bydelen Kreuzberg.»
--   e128e3e3 tekst:   «Frederik den stores Sanssouci-slott og parker, og Cecilienhof der Potsdam-konferansen ble holdt i 1945, en halvtime fra Berlin.»
--            -> «Frederik den stores Sanssouci-slott og parker, og Cecilienhof der Potsdam-konferansen ble holdt i 1945.»
--
-- ### Bilbao & San Sebastián
--   6f9806d3 tekst:   «Frank Gehrys titanbygg ved elven Nervión, som forvandlet Bilbao og huser moderne kunst i verdensklasse, med Puppy og Maman utenfor.»
--            -> «Frank Gehrys titanbygg ved elven Nervión, som forvandlet Bilbao og huser moderne kunst i verdensklasse.»
--   bf5cae79 tittel:  «Casco Viejo og elvefronten» -> «Casco Viejo»
--   bf5cae79 tekst:   «Bilbaos gamleby med de syv gatene, Santiago-katedralen og Ribera-markedet, og den moderniserte elvefronten med Zubizuri-broen.»
--            -> «Bilbaos gamleby med de syv gatene, Santiago-katedralen og Ribera-markedet, og den moderniserte elvefronten.»
--   3007ada3 tittel:  «La Concha og Monte Igueldo» -> «La Concha»
--   3007ada3 tekst:   «En av Europas vakreste bystrender i den skjellformede bukten, og utsiktspunktet Monte Igueldo med funikulær og tivoli fra 1912.»
--            -> «En av Europas vakreste bystrender i den skjellformede bukten, og utsiktspunktet Monte Igueldo med tivoli fra 1912.»
--   0502458b tittel:  «San Sebastiáns gamleby og pintxos» -> «Pintxos i gamlebyen»
--   0502458b tekst:   «Parte Vieja under Monte Urgull, med barer på hvert hjørne der pintxos-kulturen har utviklet seg til småretter i verdensklasse.»
--            -> «Parte Vieja under Monte Urgull, med barer på hvert hjørne der pintxos-kulturen er småretter i verdensklasse.»
--   5a373fe2 tittel:  «Getaria og kystlandsbyene» -> «Getaria»
--
-- ### Brela
--   31c88ed1 tittel:  «Punta Rata og strendene» -> «Punta Rata»
--   31c88ed1 tekst:   «Brelas mest kjente strand, kåret til en av Europas vakreste, med furutrær ned til vannet og den karakteristiske steinen Kamen Brela ute i sjøen.»
--            -> «Brelas mest kjente strand, kåret til en av Europas vakreste, med furutrær ned til vannet og steinen Kamen Brela ute i sjøen.»
--   ffc69815 tittel:  «Strandpromenaden til Baška Voda» -> «Strandpromenaden»
--   f9816cc9 tittel:  «Split og Diokletians palass» -> «Split»
--   f9816cc9 tekst:   «Dalmatias hovedstad en time unna, med romerkeiserens palass som fortsatt er en levende bydel med gater, kirker og kafeer.»
--            -> «Dalmatias hovedstad en time unna, der Diokletians palass fortsatt er en levende bydel med gater, kirker og kafeer.»
--   dc05b973 tekst:   «Utflukt over grensen til Bosnia-Hercegovina, til den gjenoppbygde osmanske broen Stari Most og den gamle bydelen ved elven Neretva.»
--            -> «Utflukt til Bosnia-Hercegovina, til den gjenoppbygde osmanske broen Stari Most og den gamle bydelen ved Neretva.»
--
-- ### Brussel
--   963b4ecb tekst:   «Byens storslåtte hovedplass med rådhuset og de gylne laugshusene fra 1600-tallet, på UNESCOs liste og vakkert opplyst om kvelden.»
--            -> «Byens storslåtte hovedplass med rådhuset og de gylne laugshusene fra 1600-tallet, vakkert opplyst om kvelden.»
--   428b902b tittel:  «Europaparlamentet og EU-kvarteret» -> «Europaparlamentet»
--   428b902b tekst:   «Besøk i parlamentet og Parlamentarium, der EU-samarbeidet forklares, midt i kvarteret der europeisk politikk formes.»
--            -> «Besøk i parlamentet og Parlamentarium, der EU-samarbeidet forklares, midt i kvarteret der europeisk politikk formes.»
--   f77368d2 tekst:   «Symbolet fra verdensutstillingen i 1958, ni stålkuler 102 meter over bakken, med utsikt over Brussel og utstillinger inne i kulene.»
--            -> «Symbolet fra verdensutstillingen i 1958 – ni stålkuler 102 meter over bakken, med utsikt over Brussel.»
--   ed4c73bf tittel:  «Tegneseriemuseet og jugendhusene» -> «Tegneseriemuseet»
--   ed4c73bf tekst:   «Tintin og Smurfene i Victor Hortas jugendbygning, og Hortas egne hus i Saint-Gilles som viser Brussels rolle i jugendstilen.»
--            -> «Tintin og Smurfene i Victor Hortas jugendbygning, og Hortas egne hus i Saint-Gilles som viser Brussels jugendstil.»
--
-- ### Cinque Terre
--   15cf5c19 tittel:  «Kyststien Sentiero Azzurro» -> «Sentiero Azzurro»
--   9ed3c71c tittel:  «Båttur langs kysten og Portovenere» -> «Båttur langs kysten»
--   9ed3c71c tekst:   «Fra sjøen ser man landsbyene slik de var ment å ses, og turen kan fortsette til Portovenere med kirken på klippen og øya Palmaria.»
--            -> «Fra sjøen ser man landsbyene slik de var ment å ses, gjerne videre til Portovenere med kirken på klippen.»
--
-- ### Edinburgh
--   ebe355a1 tekst:   «Gaten fra slottet til Holyrood gjennom middelalderbyen, med St Giles-katedralen, smale closes og historier fra byens mørke fortid.»
--            -> «Gaten fra slottet til Holyrood gjennom middelalderbyen, med St Giles-katedralen og de smale closes.»
--   08fd2ba6 tittel:  «Holyrood Palace og Arthur's Seat» -> «Holyrood Palace»
--   08fd2ba6 tekst:   «Kongefamiliens skotske residens ved foten av Royal Mile, og den utdødde vulkanen bak med utsikt over hele byen.»
--            -> «Kongefamiliens skotske residens ved foten av Royal Mile, og vulkanen Arthur's Seat med utsikt over hele byen.»
--   b922c337 tittel:  «National Museum of Scotland» -> «National Museum»
--   b922c337 tekst:   «Skottlands historie fra geologi og vikinger til Dolly the Sheep, i et av Storbritannias beste museer, gratis inngang.»
--            -> «Skottlands historie fra geologi og vikinger til Dolly the Sheep, i et av Storbritannias beste museer – gratis.»
--   afac8911 tittel:  «Highlands og Loch Lomond» -> «Loch Lomond»
--
-- ### Gardasjøen
--   fc51e768 tekst:   «Den historiske byen på halvøya i sørenden av sjøen, med Scaligero-borgen ved vannet, termalbad og ruinene av en romersk villa.»
--            -> «Den historiske byen på halvøya i sørenden av sjøen, med Scaligero-borgen ved vannet og termalbad.»
--   1ec3f24c tittel:  «Malcesine og Monte Baldo» -> «Malcesine»
--   58f4231a tekst:   «Romeo og Julies by med den romerske arenaen, Piazza delle Erbe og et av Italias best bevarte historiske sentrum, en time fra sjøen.»
--            -> «Romeo og Julies by med den romerske arenaen, Piazza delle Erbe og et av Italias best bevarte sentrum.»
--
-- ### Gdansk
--   cad08148 tittel:  «Europeisk solidaritetssenter» -> «Solidaritetssenteret»
--   cad08148 tekst:   «Museet ved verftsporten der Solidaritet ble født i 1980, og som forteller historien om veien til kommunismens fall i Europa.»
--            -> «Museet ved verftsporten der Solidaritet ble født i 1980, om veien til kommunismens fall i Europa.»
--   28b507f6 tittel:  «Museet for andre verdenskrig» -> «Andre verdenskrig»
--   28b507f6 tekst:   «Et av Europas største og mest moderne historiemuseer, om krigen sett fra Polen og fra menneskene som opplevde den.»
--            -> «Et av Europas største og mest moderne historiemuseer, om krigen sett fra Polen og fra menneskene som opplevde den.»
--
-- ### Helsinki
--   41e63698 tittel:  «Senatsplassen og Domkirken» -> «Senatsplassen»
--   41e63698 tekst:   «Byens monumentale hjerte, med den hvite Domkirken på toppen av trappene og Engels klassisistiske bygninger rundt plassen.»
--            -> «Byens monumentale hjerte, med den hvite Domkirken på toppen av trappene og Engels klassisistiske bygninger rundt.»
--   3d22f4e8 tittel:  «Kauppatori og Uspenskij-katedralen» -> «Kauppatori»
--   cf2894f9 tekst:   «Saunakulturen står på UNESCOs liste over immateriell kulturarv, og offentlige saunaer som Löyly ved sjøen gir grupper en ekte finsk opplevelse.»
--            -> «Saunakulturen står på UNESCOs liste, og offentlige saunaer som Löyly ved sjøen gir gruppen en ekte finsk opplevelse.»
--
-- ### Istanbul & Kappadokia
--   517fbbcc tekst:   «Det bysantinske rikets store kirke fra 500-tallet, senere moské, med den enorme kuppelen og mosaikkene som fortsatt gjør inntrykk etter nesten 1 500 år.»
--            -> «Det bysantinske rikets store kirke fra 500-tallet, senere moské, med den enorme kuppelen og mosaikkene.»
--   c7f25fe3 tittel:  «Den blå moské og Sultanahmet» -> «Den blå moské»
--   c7f25fe3 tekst:   «Istanbuls historiske hjerte, med Den blå moskeens seks minareter, Hippodromen og Topkapi-palasset innenfor gangavstand.»
--            -> «Istanbuls historiske hjerte, med Den blå moskeens seks minareter, Hippodromen og Topkapi-palasset i gangavstand.»
--   5e6cd296 tittel:  «Den store basaren og båttur på Bosporos» -> «Den store basaren»
--   5e6cd296 tekst:   «Et av verdens eldste overbygde markeder, og en seilas på stredet mellom Europa og Asia forbi palasser, moskeer og trevillaer.»
--            -> «Et av verdens eldste overbygde markeder, og en seilas på Bosporos mellom Europa og Asia forbi palasser og moskeer.»
--   0c82de46 tittel:  «Ballongflukt over Kappadokia» -> «Ballongflukt»
--   e029928e tekst:   «Klosteranlegg og kirker hugget inn i fjellet, med bysantinske fresker fra tiden da Kappadokia var et sentrum for tidlig kristendom.»
--            -> «Klosteranlegg og kirker hugget inn i fjellet, med bysantinske fresker fra tidlig kristen tid i Kappadokia.»
--   1a736576 tekst:   «Derinkuyu og Kaymaklı, byer i mange etasjer under jorden der kristne søkte tilflukt, med kirker, staller og lagerrom hugget i fjellet.»
--            -> «Derinkuyu og Kaymaklı, byer i mange etasjer under jorden der kristne søkte tilflukt, med kirker og staller i fjellet.»
--
-- ### Kairo & Luxor
--   8b2005cd tittel:  «Pyramidene i Giza og Sfinksen» -> «Pyramidene i Giza»
--   8b2005cd tekst:   «Verdens mest kjente oldtidsminner ligger på platået like utenfor Kairo, der pyramidene og Sfinksen har stått i over 4 500 år.»
--            -> «Verdens mest kjente oldtidsminner, der pyramidene og Sfinksen har stått på platået utenfor Kairo i over 4 500 år.»
--   2582adbd tekst:   «Verdens største arkeologiske museum ved foten av pyramidene, med Tutankhamons komplette gravskatt og tusenvis av gjenstander fra faraoenes Egypt.»
--            -> «Opplev verdens største arkeologiske museum og skattene fra faraoenes Egypt, inkludert Tutankhamons gravskatt.»
--   1ef9b590 tekst:   «Byens eldste bydel, med Den hengende kirke og St. Sergius-kirken der Den hellige familie etter tradisjonen søkte tilflukt – et levende innblikk i Egypts kristne historie.»
--            -> «Opplev noen av Kairos eldste kirker og sporene etter Egypts lange kristne historie.»
--   8ce9c58d tittel:  «Cave Church / St. Simon-klosteret» -> «St. Simon-klosteret»
--   8ce9c58d tekst:   «En enorm kirke hugget inn i Mokattam-fjellet, midt i bydelen til Kairos koptiske søppelsamlere – et sterkt møte med levende kristen tro i dagens Egypt.»
--            -> «En enorm kirke hugget inn i Mokattam-fjellet – et sterkt møte med levende kristen tro i dagens Egypt.»
--   c35ec4b9 tittel:  «Historiske Kairo – Citadellet og Khan el-Khalili» -> «Historiske Kairo»
--   c35ec4b9 tekst:   «Saladins citadell med Muhammad Ali-moskeen og utsikt over hele byen, og den travle basaren Khan el-Khalili med verksteder, krydder og kaffehus fra middelalderen.»
--            -> «Saladins citadell med Muhammad Ali-moskeen, og den travle basaren Khan el-Khalili med verksteder, krydder og kaffehus.»
--   3663ecef tekst:   «Et av verdens største tempelanlegg, bygget over nesten 2 000 år, med den imponerende søylehallen og den hellige sjøen ved Nilens østbredd.»
--            -> «Et imponerende tempelanlegg med monumentale søyler og nesten 2 000 års historie.»
--   fc3718c7 tekst:   «Faraoenes gravkamre på Nilens vestbredd, der blant andre Tutankhamons grav ble funnet, med fargerike veggmalerier bevart i over 3 000 år.»
--            -> «Utforsk faraoenes berømte gravkamre på vestbredden av Nilen, der også Tutankhamons grav ble funnet.»
--
-- ### København
--   840a946c tittel:  «Amalienborg og Den lille havfrue» -> «Amalienborg»
--   840a946c tekst:   «Kongefamiliens residens med vaktskifte klokken tolv, og spaserturen langs havnen til H.C. Andersens berømte skulptur.»
--            -> «Kongefamiliens residens med vaktskifte klokken tolv, og spaserturen langs havnen til Den lille havfrue.»
--   672718f3 tittel:  «Rosenborg slott og Kongens Have» -> «Rosenborg slott»
--   672718f3 tekst:   «Christian IVs renessanseslott med kronjuvelene i kjelleren, omgitt av byens eldste og mest populære park.»
--            -> «Christian IVs renessanseslott med kronjuvelene i kjelleren, omgitt av byens eldste og mest populære park.»
--   418a1436 tittel:  «Christianshavn og Christiania» -> «Christianshavn»
--   418a1436 tekst:   «Kanalbydelen med Vor Frelsers Kirkes spiraltårn, husbåter og kafeer, og fristaden Christiania rett ved.»
--            -> «Kanalbydelen med Vor Frelsers Kirkes spiraltårn, husbåter og kafeer, og fristaden Christiania rett ved.»
--
-- ### Krakow
--   e5a199b1 tekst:   «Den historiske jødiske bydelen kombinerer viktig kulturhistorie med sjarmerende gater, kafeer, restauranter og en særegen atmosfære.»
--            -> «Den historiske jødiske bydelen, med viktig kulturhistorie, sjarmerende gater, kafeer og en særegen atmosfære.»
--   625d3df9 tittel:  «Saltgruvene i Wieliczka» -> «Saltgruvene»
--   625d3df9 tekst:   «Opplev et fascinerende underjordisk landskap med historiske gruveganger, kamre, skulpturer og den imponerende St. Kinga-kapellet.»
--            -> «Et fascinerende underjordisk landskap med gruveganger, kamre, skulpturer og det imponerende St. Kinga-kapellet.»
--
-- ### Lisboa
--   3bb11008 tittel:  «Alfama og borgen São Jorge» -> «Alfama»
--   3bb11008 tekst:   «Lisboas eldste bydel med smale trapper, fado fra åpne vinduer og den maurske borgen på toppen med utsikt over Tejo.»
--            -> «Lisboas eldste bydel med smale trapper, fado fra åpne vinduer og borgen São Jorge på toppen med utsikt over Tejo.»
--   b7796011 tittel:  «Trikk 28, Baixa og Chiado» -> «Trikk 28 og Baixa»
--   b7796011 tekst:   «Den gule trikken gjennom de gamle bydelene, og handlegatene og kafeene i Baixa og Chiado der byen ble gjenreist etter jordskjelvet i 1755.»
--            -> «Den gule trikken gjennom de gamle bydelene, og handlegatene og kafeene i Baixa og Chiado.»
--   29716477 tittel:  «Time Out Market og LX Factory» -> «Time Out Market»
--   29716477 tekst:   «Byens store matmarked med Lisboas beste kokker under ett tak, og den kreative fabrikkbydelen LX Factory med butikker, gatekunst og kafeer.»
--            -> «Byens store matmarked med Lisboas beste kokker under ett tak, og den kreative fabrikkbydelen LX Factory.»
--
-- ### Liverpool
--   3c942a71 tekst:   «Den restaurerte havnen med røde teglsteinsmagasiner, museer, restauranter og utsikt over Mersey og de tre monumentalbygningene.»
--            -> «Den restaurerte havnen med røde teglsteinsmagasiner, museer og restauranter, med utsikt over Mersey.»
--   78f8e1a8 tittel:  «The Beatles Story og Cavern Club» -> «The Beatles Story»
--   78f8e1a8 tekst:   «Museet om verdens mest kjente band ved havnen, og klubben i Mathew Street der det hele begynte, fortsatt med livemusikk hver dag.»
--            -> «Museet om verdens mest kjente band ved havnen, og Cavern Club der det hele begynte – fortsatt livemusikk hver dag.»
--   be1c911b tekst:   «Liverpool Cathedral, en av verdens største anglikanske kirker, og den moderne katolske Metropolitan Cathedral i hver sin ende av Hope Street.»
--            -> «Liverpool Cathedral, en av verdens største anglikanske kirker, og den moderne katolske katedralen i hver sin ende av Hope Street.»
--   8a1af495 tittel:  «Museum of Liverpool og Pier Head» -> «Museum of Liverpool»
--   8a1af495 tekst:   «Byens egen historie fra havn og utvandring til fotball og musikk, i det moderne museet ved siden av The Three Graces.»
--            -> «Byens egen historie fra havn og utvandring til fotball og musikk, i det moderne museet ved The Three Graces.»
--
-- ### Lloret de Mar
--   65852b61 tittel:  «Stranden og strandpromenaden» -> «Stranden»
--   8de368ca tittel:  «Kyststien Camí de Ronda» -> «Camí de Ronda»
--   8de368ca tekst:   «Sti langs klippene til rolige viker som Cala Boadella og stranden Fenals, med furuskog, turkist vann og utsikt over Costa Brava.»
--            -> «Sti langs klippene til rolige viker som Cala Boadella, med furuskog, turkist vann og utsikt over Costa Brava.»
--
-- ### London
--   96bdb28b tittel:  «Westminster og Buckingham Palace» -> «Westminster»
--   3bbf0693 tittel:  «Tower of London og Tower Bridge» -> «Tower of London»
--   0cdf3bff tekst:   «Et av verdens største museer, med Rosettasteinen, Parthenon-skulpturene og gjenstander fra hele verdenshistorien, gratis inngang.»
--            -> «Et av verdens største museer, med Rosettasteinen og Parthenon-skulpturene – gratis inngang.»
--   9b35d3cf tittel:  «St Paul's Cathedral og City» -> «St Paul's Cathedral»
--   9b35d3cf tekst:   «Christopher Wrens katedral med kuppelen over City, og finansdistriktet der romersk, middelaldersk og moderne London møtes.»
--            -> «Christopher Wrens katedral med kuppelen over City, der romersk, middelaldersk og moderne London møtes.»
--   c2b934ff tekst:   «Camden Market, Borough Market og Portobello Road, der London viser sin mangfoldige og kreative side med mat, musikk og handel.»
--            -> «Camden Market, Borough Market og Portobello Road, der London viser sin kreative side med mat, musikk og handel.»
--
-- ### Málaga
--   420f22ad tittel:  «Katedralen og den historiske bykjernen» -> «Katedralen»
--   420f22ad tekst:   «Renessansekatedralen «La Manquita» med det ene tårnet, omgitt av gågater, plasser og noen av Andalucías beste tapasbarer.»
--            -> «Renessansekatedralen «La Manquita» med det ene tårnet, omgitt av gågater, plasser og gode tapasbarer.»
--   e5b6bf8b tekst:   «Kunstnerens hjemby viser et bredt utvalg av Picassos verk i et palass fra 1500-tallet, få kvartaler fra huset der han ble født.»
--            -> «Kunstnerens hjemby viser et bredt utvalg av Picassos verk i et palass fra 1500-tallet, nær huset der han ble født.»
--   b9983a34 tekst:   «Den hvite byen på kanten av kløften El Tajo, med den spektakulære broen Puente Nuevo og en av Spanias eldste tyrefekterarenaer.»
--            -> «Den hvite byen på kanten av kløften El Tajo, med broen Puente Nuevo og en av Spanias eldste tyrefekterarenaer.»
--   5d8e3204 tittel:  «Havnepromenaden og strendene» -> «Havnepromenaden»
--
-- ### Marrakech
--   bd3ca4cc tittel:  «Medinaen og Jemaa el-Fna» -> «Medinaen»
--   bd3ca4cc tekst:   «Den gamle bydelen med trange souker, verksteder og palasser – og torget Jemaa el-Fna som våkner til liv med matboder og folkeliv når kvelden kommer.»
--            -> «Den gamle bydelen med trange souker og palasser – og torget Jemaa el-Fna som våkner til liv når kvelden kommer.»
--   109b931f tekst:   «Steinørken like utenfor byen, populær for middag og solnedgang over Atlasfjellene – en helt annen stemning enn den travle medinaen.»
--            -> «Steinørken like utenfor byen, populær for middag og solnedgang over Atlasfjellene – en helt annen stemning.»
--   464835ac tekst:   «Kystby et par timers kjøretur unna, med en hvitkalket medina, fiskehavn og frisk havbris – en rolig kontrast til Marrakechs tempo.»
--            -> «Kystby et par timer unna, med hvitkalket medina, fiskehavn og frisk havbris – en rolig kontrast til Marrakech.»
--   6cad03f9 tekst:   «Frodig botanisk hage i intense blåtoner, anlagt av maleren Jacques Majorelle og senere eid av Yves Saint Laurent – en grønn pause fra bylivet.»
--            -> «Frodig botanisk hage i intense blåtoner, anlagt av Jacques Majorelle og senere eid av Yves Saint Laurent.»
--
-- ### München
--   4922b6b4 tittel:  «Marienplatz og gamlebyen» -> «Marienplatz»
--   7cb0b3df tittel:  «Hofbräuhaus og Viktualienmarkt» -> «Hofbräuhaus»
--   7cb0b3df tekst:   «Verdens mest kjente ølhall med blåsemusikk og lange bord, og det tradisjonelle matmarkedet med bayerske spesialiteter.»
--            -> «Verdens mest kjente ølhall med blåsemusikk og lange bord, og matmarkedet Viktualienmarkt med bayerske spesialiteter.»
--   9cf68864 tittel:  «Allianz Arena og FC Bayern» -> «Allianz Arena»
--   2c08a05f tittel:  «Deutsches Museum og BMW Welt» -> «Deutsches Museum»
--   2c08a05f tekst:   «Verdens største teknikkmuseum på øya i Isar, og BMWs museum og utstillingsbygg ved Olympiaparken.»
--            -> «Verdens største teknikkmuseum på øya i Isar, og BMWs museum og utstillingsbygg ved Olympiaparken.»
--
-- ### Napoli
--   dbf9a65f tittel:  «Gamlebyen og Spaccanapoli» -> «Spaccanapoli»
--   dbf9a65f tekst:   «Den lange, rette gaten som deler gamlebyen, med kirker, verksteder, pizzeriaer og julekrybbeverkstedene i Via San Gregorio Armeno.»
--            -> «Den lange, rette gaten gjennom gamlebyen, med kirker, verksteder, pizzeriaer og julekrybbeverkstedene.»
--   ac33e88b tittel:  «Det arkeologiske nasjonalmuseet» -> «Arkeologisk museum»
--   ac33e88b tekst:   «Et av verdens viktigste museer for antikken, med mosaikker, fresker og skulpturer fra Pompeii og Herculaneum.»
--            -> «Et av verdens viktigste museer for antikken, med mosaikker, fresker og skulpturer fra Pompeii og Herculaneum.»
--
-- ### New York
--   d09ae055 tekst:   «Byens grønne lunge på 3,4 kvadratkilometer, med Bethesda Terrace, Strawberry Fields og robåter på innsjøen midt mellom skyskraperne.»
--            -> «Byens grønne lunge med Bethesda Terrace, Strawberry Fields og robåter på innsjøen midt mellom skyskraperne.»
--   69528389 tittel:  «Frihetsgudinnen og Ellis Island» -> «Frihetsgudinnen»
--   69528389 tekst:   «Båtturen ut til statuen og immigrasjonsmuseet på Ellis Island, der tolv millioner innvandrere, mange nordmenn, kom til Amerika.»
--            -> «Båtturen ut til statuen og Ellis Island, der tolv millioner innvandrere, mange nordmenn, kom til Amerika.»
--   42700954 tittel:  «9/11 Memorial og One World Observatory» -> «9/11 Memorial»
--   42700954 tekst:   «Minnestedet med de to bassengene der tvillingtårnene sto, museet og utsikten fra toppen av One World Trade Center.»
--            -> «Minnestedet med de to bassengene der tvillingtårnene sto, museet og utsikten fra One World Observatory.»
--   dabb2338 tittel:  «Times Square og Broadway» -> «Times Square»
--   2213af20 tittel:  «Brooklyn Bridge og DUMBO» -> «Brooklyn Bridge»
--   5adcb1e3 tittel:  «High Line, Chelsea Market og Hudson Yards» -> «High Line»
--   5adcb1e3 tekst:   «Den hevede parken på den gamle jernbanen gjennom Chelsea, matmarkedet i den gamle kjeksfabrikken og Vessel og Edge i Hudson Yards.»
--            -> «Den hevede parken på den gamle jernbanen gjennom Chelsea, med Chelsea Market og Hudson Yards ved enden.»
--
-- ### Nice
--   dbbdd012 tittel:  «Gamlebyen og Cours Saleya» -> «Gamlebyen»
--   49fcd960 tekst:   «Parken på klippen mellom gamlebyen og havnen, med vannfall og det klassiske utsiktsbildet over Englebukten og de røde takene.»
--            -> «Parken på klippen mellom gamlebyen og havnen, med det klassiske utsiktsbildet over Englebukten.»
--   3c4c4847 tekst:   «Fyrstedømmet med palasset, katedralen der Grace Kelly er begravet, det berømte casinoet og havnen med luksusyachtene, en halvtime fra Nice.»
--            -> «Fyrstedømmet med palasset, katedralen der Grace Kelly er begravet, casinoet og havnen med luksusyachtene.»
--   933a83c6 tekst:   «Antibes med Picasso-museet i slottet og den gamle havnen, og Cannes med Croisette, filmfestivalpalasset og gamlebyen Le Suquet.»
--            -> «Antibes med Picasso-museet og den gamle havnen, og Cannes med Croisette og gamlebyen Le Suquet.»
--   8e82a10c tittel:  «Matisse- og Chagall-museene» -> «Matisse og Chagall»
--
-- ### Paris
--   7ea084ed tekst:   «Byens ikoniske landemerke fra 1889, med utsikt over hele Paris fra plattformene, spesielt vakkert når tårnet lyser om kvelden.»
--            -> «Byens ikoniske landemerke fra 1889, med utsikt over hele Paris – spesielt vakkert når tårnet lyser om kvelden.»
--   ba41912c tekst:   «Verdens mest besøkte museum, med Mona Lisa, Venus fra Milo og tusenvis av verk fra antikken til 1800-tallet under glasspyramiden.»
--            -> «Verdens mest besøkte museum, med Mona Lisa, Venus fra Milo og tusenvis av verk under glasspyramiden.»
--   7d1d1b69 tittel:  «Notre-Dame og Île de la Cité» -> «Notre-Dame»
--   d6f03356 tittel:  «Montmartre og Sacré-Cœur» -> «Montmartre»
--   85c1ad8d tittel:  «Le Marais og Latinerkvarteret» -> «Le Marais»
--
-- ### Pineda de Mar
--   68e1c2c8 tittel:  «Stranden og strandpromenaden» -> «Stranden»
--   0df5589a tekst:   «Direkte tog langs kysten tar gruppen til Barcelona på under en time, med Sagrada Família, gamlebyen og La Rambla innen rekkevidde for en dagstur.»
--            -> «Direkte tog langs kysten tar gruppen til Barcelona på under en time – Sagrada Família, gamlebyen og La Rambla.»
--   d541f83e tekst:   «Middelalderbyen med den fargerike husrekken langs elven Onyar, katedralen og det godt bevarte jødiske kvarteret, en times reise unna.»
--            -> «Middelalderbyen med fargerike hus langs elven Onyar, katedralen og det jødiske kvarteret, en times reise unna.»
--   181c5edd tittel:  «Costa Brava og Tossa de Mar» -> «Costa Brava»
--   6c4b4d0e tittel:  «Bykjernen og det ukentlige markedet» -> «Bykjernen og markedet»
--   6c4b4d0e tekst:   «Pinedas eget sentrum med Sant Joan-kirken, plasser, lokale restauranter og det tradisjonelle ukemarkedet med varer fra distriktet.»
--            -> «Pinedas sentrum med Sant Joan-kirken, lokale restauranter og det tradisjonelle ukemarkedet med varer fra distriktet.»
--
-- ### Porto
--   41a573fa tittel:  «Portvinskjellerne i Vila Nova de Gaia» -> «Portvinskjellerne»
--   41a573fa tekst:   «På motsatt elvebredd ligger de tradisjonelle kjellerne der portvinen lagres, med omvisning, smaking og utsikt tilbake mot Porto.»
--            -> «På motsatt elvebredd ligger kjellerne der portvinen lagres, med omvisning, smaking og utsikt tilbake mot Porto.»
--   1a0e6655 tittel:  «Livraria Lello og Clérigos-tårnet» -> «Livraria Lello»
--   1a0e6655 tekst:   «Den praktfulle bokhandelen fra 1906 og barokktårnet med utsikt over hele byen, midt i Portos sentrum.»
--            -> «Den praktfulle bokhandelen fra 1906 og Clérigos-tårnet med utsikt over hele byen, midt i Portos sentrum.»
--   3ff0db79 tekst:   «Portugals religiøse hovedstad med kirken Bom Jesus, og nasjonens fødeby Guimarães med borg og middelaldergater, begge en kort tur fra Porto.»
--            -> «Portugals religiøse hovedstad med kirken Bom Jesus, og nasjonens fødeby Guimarães med borg og middelaldergater.»
--   17f49ad2 tittel:  «Foz do Douro og Matosinhos» -> «Foz do Douro»
--   17f49ad2 tekst:   «Der elven møter Atlanterhavet, med promenade, strender og fyret i Foz, og fiskebyen Matosinhos med Portugals beste grillede sjømat.»
--            -> «Der elven møter Atlanterhavet, med promenade, strender og fyret i Foz, og fiskebyen Matosinhos med grillet sjømat.»
--
-- ### Praha
--   65c85276 tittel:  «Praha-borgen og St. Vitus-katedralen» -> «Praha-borgen»
--   65c85276 tekst:   «Verdens største sammenhengende borgkompleks over byen, med katedralen, Gullgaten og utsikt over hele Praha.»
--            -> «Verdens største sammenhengende borgkompleks, med St. Vitus-katedralen, Gullgaten og utsikt over hele Praha.»
--   c4146f12 tittel:  «Gamlebyplassen og det astronomiske uret» -> «Gamlebyplassen»
--   c4146f12 tekst:   «Byens hjerte med Týn-kirkens tårn, Jan Hus-monumentet og rådhusets astronomiske ur fra 1410 som spiller hver hele time.»
--            -> «Byens hjerte med Týn-kirkens tårn, Jan Hus-monumentet og det astronomiske uret fra 1410 som spiller hver hele time.»
--   09eaf4cb tittel:  «Det jødiske kvarteret Josefov» -> «Josefov»
--
-- ### Riga
--   6b435ebd tittel:  «Gamlebyen og Svarthodenes hus» -> «Gamlebyen»
--   6b435ebd tekst:   «Hansabyen ved Daugava med det gjenreiste Svarthodenes hus, Rådhusplassen, Tre brødre og smale gater fra middelalderen.»
--            -> «Hansabyen ved Daugava med det gjenreiste Svarthodenes hus, Rådhusplassen, Tre brødre og smale middelaldergater.»
--   b4c05836 tittel:  «Domkirken og Peterskirken» -> «Domkirken»
--
-- ### Roma
--   6a097635 tittel:  «Colosseum og Forum Romanum» -> «Colosseum»
--   6a097635 tekst:   «Antikkens Roma i konsentrert form: verdens største amfiteater og ruinene av byens politiske og religiøse sentrum.»
--            -> «Antikkens Roma i konsentrert form: verdens største amfiteater og ruinene av Forum Romanum.»
--   6262a653 tittel:  «Peterskirken og Petersplassen» -> «Peterskirken»
--   d0bbe878 tittel:  «Vatikanmuseene og Det sixtinske kapell» -> «Vatikanmuseene»
--   27c26100 tittel:  «Katakombene langs Via Appia» -> «Katakombene»
--   2002c315 tittel:  «Pantheon og Piazza Navona» -> «Pantheon»
--   2002c315 tekst:   «Antikkens best bevarte byggverk og Romas vakreste barokkplass ligger få minutters gange fra hverandre i den historiske bykjernen.»
--            -> «Antikkens best bevarte byggverk og Romas vakreste barokkplass, Piazza Navona, få minutters gange fra hverandre.»
--   edf7dd85 tittel:  «Fontana di Trevi og Spansketrappen» -> «Fontana di Trevi»
--
-- ### Salzburg
--   4227af52 tittel:  «Festningen Hohensalzburg» -> «Hohensalzburg»
--   7aaf314e tittel:  «Gamlebyen og Getreidegasse» -> «Gamlebyen»
--   be444d73 tittel:  «Mozarts fødehus og konsert» -> «Mozarts fødehus»
--   7fde86f1 tittel:  «Mirabell-hagen og Sound of Music» -> «Mirabell-hagen»
--   3f19b76d tittel:  «Hallstatt og Salzkammergut» -> «Hallstatt»
--   3f19b76d tekst:   «Den lille landsbyen mellom fjellet og innsjøen, en av Østerrikes mest fotograferte, og innsjølandskapet rundt Wolfgangsee og St. Gilgen.»
--            -> «Den lille landsbyen mellom fjellet og innsjøen, en av Østerrikes mest fotograferte, og innsjølandskapet rundt.»
--   23df2567 tittel:  «Berchtesgaden og Königssee» -> «Königssee»
--
-- ### Sevilla
--   768a4d8a tekst:   «Verdens største gotiske katedral med graven til Columbus, og det tidligere minaretet Giralda med ramper opp til utsikten over byen.»
--            -> «Verdens største gotiske katedral med graven til Columbus, og tårnet Giralda med utsikt over byen.»
--   cc2d0c54 tekst:   «Det kongelige palasset med mudéjar-arkitektur, gårdsrom og hager, Europas eldste palass fortsatt i bruk, kjent fra Game of Thrones.»
--            -> «Det kongelige palasset med mudéjar-arkitektur, gårdsrom og hager – Europas eldste palass fortsatt i bruk.»
--   36ee54fe tittel:  «Plaza de España og María Luisa-parken» -> «Plaza de España»
--   36ee54fe tekst:   «Den halvsirkelformede praktplassen fra 1929 med kanaler, broer og flisbenker for hver spansk provins, i byens grønne park.»
--            -> «Den halvsirkelformede praktplassen fra 1929 med kanaler, broer og flisbenker for hver spansk provins.»
--   6ba60689 tekst:   «Bydelen på andre siden av elven, flamencoens og keramikkens hjem, med tapasbarer langs Calle Betis og forestillinger om kvelden.»
--            -> «Bydelen på andre siden av elven, flamencoens hjem, med tapasbarer langs Calle Betis og forestillinger om kvelden.»
--   8fde0f14 tittel:  «Ronda og de hvite landsbyene» -> «Ronda»
--
-- ### Sicilia
--   3b99452c tekst:   «Antikkens greske storby med det store teateret og grotten Dionysos-øret, og øya Ortigia med barokkatedralen bygget rundt et gresk tempel.»
--            -> «Antikkens greske storby med det store teateret, og øya Ortigia med barokkatedralen bygget rundt et gresk tempel.»
--   bdece807 tekst:   «Sicilias hovedstad med arabisk-normanniske kirker, livlige markeder og katedralen i Monreale med gullmosaikker over hele interiøret.»
--            -> «Sicilias hovedstad med arabisk-normanniske kirker og livlige markeder, og katedralen i Monreale med gullmosaikker.»
--   6ba12761 tittel:  «Barokkbyene Noto og Ragusa» -> «Noto og Ragusa»
--   6ba12761 tekst:   «Byene som ble gjenreist i honninggul barokk etter jordskjelvet i 1693, med palasser, kirker og brede trapper på UNESCOs liste.»
--            -> «Byene som ble gjenreist i honninggul barokk etter jordskjelvet i 1693, med palasser og kirker på UNESCOs liste.»
--
-- ### Stockholm
--   fda3a3ab tittel:  «Södermalm og Fotografiska» -> «Södermalm»
--
-- ### Tallinn
--   88e1a4b5 tittel:  «Gamlebyen og Rådhusplassen» -> «Gamlebyen»
--   699b5870 tekst:   «Domhøyden over gamlebyen, med Alexander Nevskij-katedralen, Domkirken, parlamentet og utsiktsplattformene over de røde takene.»
--            -> «Domhøyden over gamlebyen, med Alexander Nevskij-katedralen, parlamentet og utsikt over de røde takene.»
--   c0cb1705 tittel:  «Lennusadam sjøflyhavnen» -> «Lennusadam»
--
-- ### Valencia
--   e849acc2 tittel:  «Gamlebyen, katedralen og La Lonja» -> «Gamlebyen»
--   e849acc2 tekst:   «Katedralen med Den hellige gral og Miguelete-tårnet, silkebørsen La Lonja fra 1400-tallet og plassene i den historiske bykjernen.»
--            -> «Katedralen med Den hellige gral og Miguelete-tårnet, silkebørsen La Lonja fra 1400-tallet og plassene rundt.»
--   15f09768 tittel:  «Ciudad de las Artes y las Ciencias» -> «Kunst- og vitenskapsbyen»
--   88709b0c tekst:   «Den gamle elvebunnen som ble ni kilometer park gjennom byen, med Gulliver-parken, broer og sykkelstier fra Bioparc til havet.»
--            -> «Den gamle elvebunnen som ble ni kilometer park gjennom byen, med sykkelstier fra Bioparc til havet.»
--
-- ### Vilnius
--   2067a4cd tittel:  «Gamlebyen og Katedralplassen» -> «Gamlebyen»
--   62d3ce76 tekst:   «Den selverklærte republikken på andre siden av elven Vilnia, med egen grunnlov, kunstnere, kafeer og en humoristisk frihetsånd.»
--            -> «Den selverklærte republikken på andre siden av elven Vilnia, med egen grunnlov, kunstnere og kafeer.»
--   b63e1c70 tittel:  «Morgenporten og Pilies-gaten» -> «Morgenporten»
--   b63e1c70 tekst:   «Den eneste bevarte byporten med det hellige Maria-ikonet, og hovedgaten gjennom gamlebyen med marked, kafeer og ravbutikker.»
--            -> «Den eneste bevarte byporten med Maria-ikonet, og hovedgaten gjennom gamlebyen med marked, kafeer og ravbutikker.»
--   16603a79 tittel:  «Okkupasjons- og frihetskampmuseet» -> «KGB-museet»
--   16603a79 tekst:   «Det tidligere KGB-hovedkvarteret med cellene og henrettelsesrommet bevart, om okkupasjonene og veien til frihet i 1991.»
--            -> «Det tidligere KGB-hovedkvarteret med cellene bevart, om okkupasjonene og veien til frihet i 1991.»
--
-- ### York
--   04932460 tittel:  «The Shambles og gamlebyen» -> «The Shambles»
--   8287fc83 tittel:  «North York Moors og Whitby» -> «North York Moors»
--   6f613bac tekst:   «Ruinene av et av Englands største cistercienserklostre, i en vakker dal med parkanlegg som står på UNESCOs verdensarvliste.»
--            -> «Ruinene av et av Englands største cistercienserklostre, i en vakker dal på UNESCOs verdensarvliste.»

-- Kjørt som tre batcher av formen:
-- update reisemaal_hoydepunkter as h set navn = coalesce(v.navn, h.navn), korttekst = coalesce(v.tekst, h.korttekst)
--   from (values ('<id>', <ny tittel|NULL>, <ny tekst|NULL>), ...) as v(id, navn, tekst) where h.id = v.id::uuid;

update reisemaal_hoydepunkter as h set navn = coalesce(v.navn, h.navn), korttekst = coalesce(v.tekst, h.korttekst)
from (values
('b784eef7-0685-4b95-801e-a852b7ecb678', $q$Royal Deeside$q$, NULL),
('96c3cff9-729e-459c-921a-97438186c8d9', $q$Crathes og Fyvie$q$, $q$Aberdeenshire har flere slott enn noen annen del av Skottland – Crathes med de malte takene og eventyrlige Fyvie.$q$),
('7c7df3d1-a57e-440f-a56d-4e8ee99521b5', $q$Speyside$q$, $q$Verdens tetteste samling av whiskydestillerier, med omvisning og smaking hos Glenfiddich eller Macallan.$q$),
('c9058f26-6081-49cb-96e7-3ed16f98fe2a', NULL, $q$Middelalderbydelen med St Machar-katedralen, King's College fra 1495 og brosteinsgater rundt universitetet.$q$),
('41a2c243-2423-4634-b046-7aec81b889a4', $q$Kanalbåt$q$, $q$Byens 1600-tallskanaler sett fra vannet, med kjøpmannshus, broer og husbåter – den klassiske introduksjonen.$q$),
('e4d71fa6-515b-43cb-a3bf-abf581e0810d', $q$Jordaan$q$, $q$Den gamle arbeiderbydelen med smale gater, kafeer og markeder, og de ni små handlegatene mellom kanalene.$q$),
('13fd893b-a2da-46f5-8728-481a67efc93e', $q$Keukenhof$q$, $q$Verdens største blomsterpark med syv millioner løker i blomst fra mars til mai, omgitt av tulipanmarker.$q$),
('ca8ccc2e-f729-4510-b6b3-a3e74ab96dcb', $q$Explanada de España$q$, $q$Den berømte promenaden med seks millioner marmorfliser i bølgemønster under palmene, med bystranden rett ved.$q$),
('57a8d7d0-49b5-4620-9fc5-834e0f3d4f38', $q$Mercado Central$q$, $q$Matmarkedet fra 1921 med lokale produkter, og Rambla med kafeer, butikker og byliv fra sentrum til havnen.$q$),
('3f78ab78-ff8d-45ab-9c0e-8f1c1ade9306', NULL, $q$Byen med Europas største palmehage – over 200 000 palmer på UNESCOs liste – og basilikaen med Elche-mysteriet.$q$),
('c393dd9b-eac7-43ca-b6b3-c1cbd1972ee2', NULL, $q$Antikkens torg der Sokrates diskuterte med athenerne, og Areopagos-høyden der Paulus ifølge Apostlenes gjerninger talte.$q$),
('6b11d7f9-8168-471c-a956-c5602bc6c978', NULL, $q$Dagstur til ruinene av antikkens Korint, byen Paulus bodde i og skrev til, og den imponerende Korintkanalen.$q$),
('a31a6967-e12d-425d-bf99-ece814a65656', $q$Rismarkene$q$, $q$De berømte terrasserte rismarkene i Tegallalang og Jatiluwih, sistnevnte på UNESCOs liste for subak-vanningen.$q$),
('6771ca51-00c5-4564-810e-892003de4e59', $q$Snorkling$q$, $q$Korallrev og det japanske skipsvraket ved Amed, eller båttur til Nusa Penida med Kelingking-stranden og mantarokker.$q$),
('4d0bef05-9ef8-45d2-aa1c-f4f399b8b02b', $q$Balinesisk landsby$q$, $q$Besøk i en tradisjonell landsby som Penglipuran, med tempelseremoni, ofringer og innblikk i hverdagslivet.$q$),
('aa6be267-f940-40b0-874c-aac9194fc162', $q$Det gotiske kvarteret$q$, $q$Barcelonas middelalderkjerne med smale gater, romerske murer, katedralen og plasser der historien ligger tett.$q$),
('4e75939d-1575-43bb-8154-535badde2cf1', NULL, $q$Gaudís ufullendte basilika med skoglignende søyler og lys gjennom fargerike glassmalerier – et av verdens mest særegne kirkebygg.$q$),
('7c4dcc3e-b17a-462c-bb00-6eb0f564d455', $q$Camp Nou$q$, NULL),
('f7515470-e820-4a2d-aeec-1996eb98f2b3', $q$Brandenburger Tor$q$, $q$Byens symbol ved Pariser Platz, og Riksdagen med glasskuppelen og utsikt over Berlin (forhåndsbestilling).$q$),
('f487496d-a761-4942-b150-694c2394b05f', $q$Berlinmuren$q$, $q$Minnestedet ved Bernauer Straße der Muren står bevart med dødsstripen, vakttårnet og dokumentasjonssenteret.$q$),
('23232763-0863-42d2-b2ec-a05e6a18e947', $q$Checkpoint Charlie$q$, $q$Den berømte grenseovergangen mellom øst og vest, med Mauermuseum og DDR-museet om hverdagen i Øst-Berlin.$q$),
('1d8775e4-6d05-4517-971c-b33fdd6f44b6', $q$Holocaust-minnesmerket$q$, $q$Stelefeltet ved Brandenburger Tor, og Topographie des Terrors der Gestapo og SS hadde sine hovedkvarterer.$q$),
('fa4f8329-0677-4a81-bd9c-8fa2c635a148', $q$East Side Gallery$q$, $q$Den lengste bevarte delen av Muren, malt av kunstnere fra hele verden, og den mangfoldige bydelen Kreuzberg.$q$),
('e128e3e3-2dfe-4c0b-b412-757deb80f07a', NULL, $q$Frederik den stores Sanssouci-slott og parker, og Cecilienhof der Potsdam-konferansen ble holdt i 1945.$q$),
('6f9806d3-7ca3-478c-80fc-3be1be325302', NULL, $q$Frank Gehrys titanbygg ved elven Nervión, som forvandlet Bilbao og huser moderne kunst i verdensklasse.$q$),
('bf5cae79-06fb-47a0-90e3-4ebc980a7239', $q$Casco Viejo$q$, $q$Bilbaos gamleby med de syv gatene, Santiago-katedralen og Ribera-markedet, og den moderniserte elvefronten.$q$),
('3007ada3-b956-4e4b-aae7-fdc91465d192', $q$La Concha$q$, $q$En av Europas vakreste bystrender i den skjellformede bukten, og utsiktspunktet Monte Igueldo med tivoli fra 1912.$q$),
('0502458b-4ec5-41af-98cb-b6860e219302', $q$Pintxos i gamlebyen$q$, $q$Parte Vieja under Monte Urgull, med barer på hvert hjørne der pintxos-kulturen er småretter i verdensklasse.$q$),
('5a373fe2-78c6-424c-9ff4-c940ec3f211f', $q$Getaria$q$, NULL),
('31c88ed1-a414-4d30-b093-57ecf08b2f54', $q$Punta Rata$q$, $q$Brelas mest kjente strand, kåret til en av Europas vakreste, med furutrær ned til vannet og steinen Kamen Brela ute i sjøen.$q$),
('ffc69815-1eaf-492b-8758-a65aad1ee6b2', $q$Strandpromenaden$q$, NULL),
('f9816cc9-a28f-4c2b-801a-107da1280fbd', $q$Split$q$, $q$Dalmatias hovedstad en time unna, der Diokletians palass fortsatt er en levende bydel med gater, kirker og kafeer.$q$),
('dc05b973-59ac-4ee3-89d3-71b513704794', NULL, $q$Utflukt til Bosnia-Hercegovina, til den gjenoppbygde osmanske broen Stari Most og den gamle bydelen ved Neretva.$q$),
('963b4ecb-ccc2-4d77-af08-8dfe50a0e87f', NULL, $q$Byens storslåtte hovedplass med rådhuset og de gylne laugshusene fra 1600-tallet, vakkert opplyst om kvelden.$q$),
('428b902b-1706-4f87-a5bd-bb40e36f4535', $q$Europaparlamentet$q$, $q$Besøk i parlamentet og Parlamentarium, der EU-samarbeidet forklares, midt i kvarteret der europeisk politikk formes.$q$),
('f77368d2-7416-43a8-8d55-bc65dbc4ac5e', NULL, $q$Symbolet fra verdensutstillingen i 1958 – ni stålkuler 102 meter over bakken, med utsikt over Brussel.$q$),
('ed4c73bf-b0f0-4adc-aecc-9ef5969ee16f', $q$Tegneseriemuseet$q$, $q$Tintin og Smurfene i Victor Hortas jugendbygning, og Hortas egne hus i Saint-Gilles som viser Brussels jugendstil.$q$),
('15cf5c19-f61d-41aa-8bdc-5912189d640d', $q$Sentiero Azzurro$q$, NULL),
('9ed3c71c-a2e2-40e1-8e94-54228f5f5427', $q$Båttur langs kysten$q$, $q$Fra sjøen ser man landsbyene slik de var ment å ses, gjerne videre til Portovenere med kirken på klippen.$q$),
('ebe355a1-3313-4a1e-9c4d-c42394275a57', NULL, $q$Gaten fra slottet til Holyrood gjennom middelalderbyen, med St Giles-katedralen og de smale closes.$q$),
('08fd2ba6-9654-49ad-8303-21da103782af', $q$Holyrood Palace$q$, $q$Kongefamiliens skotske residens ved foten av Royal Mile, og vulkanen Arthur's Seat med utsikt over hele byen.$q$),
('b922c337-21cf-4773-93e6-df921767c2ce', $q$National Museum$q$, $q$Skottlands historie fra geologi og vikinger til Dolly the Sheep, i et av Storbritannias beste museer – gratis.$q$),
('afac8911-692e-4848-9694-1a7006ae7004', $q$Loch Lomond$q$, NULL),
('fc51e768-8d88-4165-9442-71bed7a1ea17', NULL, $q$Den historiske byen på halvøya i sørenden av sjøen, med Scaligero-borgen ved vannet og termalbad.$q$),
('1ec3f24c-0e19-4fcf-a5b3-4fba482f2095', $q$Malcesine$q$, NULL),
('58f4231a-ad25-4ba8-9e77-4c9461b61be1', NULL, $q$Romeo og Julies by med den romerske arenaen, Piazza delle Erbe og et av Italias best bevarte sentrum.$q$),
('cad08148-ed9d-459d-acfe-17762387dd19', $q$Solidaritetssenteret$q$, $q$Museet ved verftsporten der Solidaritet ble født i 1980, om veien til kommunismens fall i Europa.$q$),
('28b507f6-51bc-45c0-b103-683a46d0fcaa', $q$Andre verdenskrig$q$, $q$Et av Europas største og mest moderne historiemuseer, om krigen sett fra Polen og fra menneskene som opplevde den.$q$),
('41e63698-d57f-45df-afae-d408f7e96d61', $q$Senatsplassen$q$, $q$Byens monumentale hjerte, med den hvite Domkirken på toppen av trappene og Engels klassisistiske bygninger rundt.$q$),
('3d22f4e8-c88c-4240-8208-374ec8f8e632', $q$Kauppatori$q$, NULL),
('cf2894f9-512b-47bc-95ac-ed50c23b0f8b', NULL, $q$Saunakulturen står på UNESCOs liste, og offentlige saunaer som Löyly ved sjøen gir gruppen en ekte finsk opplevelse.$q$),
('517fbbcc-c6f5-4273-8f4f-1461ca356d79', NULL, $q$Det bysantinske rikets store kirke fra 500-tallet, senere moské, med den enorme kuppelen og mosaikkene.$q$),
('c7f25fe3-4ddc-4844-808d-22489516329a', $q$Den blå moské$q$, $q$Istanbuls historiske hjerte, med Den blå moskeens seks minareter, Hippodromen og Topkapi-palasset i gangavstand.$q$),
('5e6cd296-c024-40ba-9153-522194923a67', $q$Den store basaren$q$, $q$Et av verdens eldste overbygde markeder, og en seilas på Bosporos mellom Europa og Asia forbi palasser og moskeer.$q$),
('0c82de46-babd-4140-8f09-df2ecc7ec817', $q$Ballongflukt$q$, NULL)
) as v(id, navn, tekst) where h.id = v.id::uuid;
update reisemaal_hoydepunkter as h set navn = coalesce(v.navn, h.navn), korttekst = coalesce(v.tekst, h.korttekst)
from (values
('e029928e-c346-407b-bf1c-77d607724334', NULL, $q$Klosteranlegg og kirker hugget inn i fjellet, med bysantinske fresker fra tidlig kristen tid i Kappadokia.$q$),
('1a736576-d076-4adf-a7f3-7570687affe6', NULL, $q$Derinkuyu og Kaymaklı, byer i mange etasjer under jorden der kristne søkte tilflukt, med kirker og staller i fjellet.$q$),
('8b2005cd-11e0-41a7-b92f-3e571f75275b', $q$Pyramidene i Giza$q$, $q$Verdens mest kjente oldtidsminner, der pyramidene og Sfinksen har stått på platået utenfor Kairo i over 4 500 år.$q$),
('2582adbd-58bf-4d6a-adde-1e738b2cd9db', NULL, $q$Opplev verdens største arkeologiske museum og skattene fra faraoenes Egypt, inkludert Tutankhamons gravskatt.$q$),
('1ef9b590-ca86-4646-9c6f-bb53a49e7a49', NULL, $q$Opplev noen av Kairos eldste kirker og sporene etter Egypts lange kristne historie.$q$),
('8ce9c58d-fd1e-48a7-9172-14dda2f790bf', $q$St. Simon-klosteret$q$, $q$En enorm kirke hugget inn i Mokattam-fjellet – et sterkt møte med levende kristen tro i dagens Egypt.$q$),
('c35ec4b9-f716-48fd-aa6a-585b998771d5', $q$Historiske Kairo$q$, $q$Saladins citadell med Muhammad Ali-moskeen, og den travle basaren Khan el-Khalili med verksteder, krydder og kaffehus.$q$),
('3663ecef-1e24-47fb-8c1d-0e010002f677', NULL, $q$Et imponerende tempelanlegg med monumentale søyler og nesten 2 000 års historie.$q$),
('fc3718c7-72d5-4e30-84fe-5c228d943b01', NULL, $q$Utforsk faraoenes berømte gravkamre på vestbredden av Nilen, der også Tutankhamons grav ble funnet.$q$),
('840a946c-c3ac-408d-86bb-dff9868094c5', $q$Amalienborg$q$, $q$Kongefamiliens residens med vaktskifte klokken tolv, og spaserturen langs havnen til Den lille havfrue.$q$),
('672718f3-c8bf-4851-8309-a7592a9a8b91', $q$Rosenborg slott$q$, $q$Christian IVs renessanseslott med kronjuvelene i kjelleren, omgitt av byens eldste og mest populære park.$q$),
('418a1436-0bef-484d-b046-eb7ab9556fe9', $q$Christianshavn$q$, $q$Kanalbydelen med Vor Frelsers Kirkes spiraltårn, husbåter og kafeer, og fristaden Christiania rett ved.$q$),
('e5a199b1-3d16-437b-a462-5d7de4135430', NULL, $q$Den historiske jødiske bydelen, med viktig kulturhistorie, sjarmerende gater, kafeer og en særegen atmosfære.$q$),
('625d3df9-e4a8-4ae4-a0c4-20bc708db1a8', $q$Saltgruvene$q$, $q$Et fascinerende underjordisk landskap med gruveganger, kamre, skulpturer og det imponerende St. Kinga-kapellet.$q$),
('3bb11008-21db-48fb-8153-961a1f398f44', $q$Alfama$q$, $q$Lisboas eldste bydel med smale trapper, fado fra åpne vinduer og borgen São Jorge på toppen med utsikt over Tejo.$q$),
('b7796011-5a33-4830-81cb-6daa4ee3d157', $q$Trikk 28 og Baixa$q$, $q$Den gule trikken gjennom de gamle bydelene, og handlegatene og kafeene i Baixa og Chiado.$q$),
('29716477-a39d-443e-8f65-fa47252bb588', $q$Time Out Market$q$, $q$Byens store matmarked med Lisboas beste kokker under ett tak, og den kreative fabrikkbydelen LX Factory.$q$),
('3c942a71-849c-4215-a664-094c0a266b24', NULL, $q$Den restaurerte havnen med røde teglsteinsmagasiner, museer og restauranter, med utsikt over Mersey.$q$),
('78f8e1a8-5768-42df-afc3-6fb3b7aa6444', $q$The Beatles Story$q$, $q$Museet om verdens mest kjente band ved havnen, og Cavern Club der det hele begynte – fortsatt livemusikk hver dag.$q$),
('be1c911b-5e52-435c-9412-bacb4272d3b7', NULL, $q$Liverpool Cathedral, en av verdens største anglikanske kirker, og den moderne katolske katedralen i hver sin ende av Hope Street.$q$),
('8a1af495-658c-4fc7-b5c0-5225299ef8c9', $q$Museum of Liverpool$q$, $q$Byens egen historie fra havn og utvandring til fotball og musikk, i det moderne museet ved The Three Graces.$q$),
('65852b61-641d-4a53-af7f-7a9ec939dc4c', $q$Stranden$q$, NULL),
('8de368ca-e7ab-4f6e-9a15-1e942d08f4c0', $q$Camí de Ronda$q$, $q$Sti langs klippene til rolige viker som Cala Boadella, med furuskog, turkist vann og utsikt over Costa Brava.$q$),
('96bdb28b-21a7-46a4-b201-2a56067e9a63', $q$Westminster$q$, NULL),
('3bbf0693-d684-4c6c-9b67-b4c4fefc3351', $q$Tower of London$q$, NULL),
('0cdf3bff-320c-4084-890c-8d3c338e9c76', NULL, $q$Et av verdens største museer, med Rosettasteinen og Parthenon-skulpturene – gratis inngang.$q$),
('9b35d3cf-31f0-402d-83cc-a48430f83d39', $q$St Paul's Cathedral$q$, $q$Christopher Wrens katedral med kuppelen over City, der romersk, middelaldersk og moderne London møtes.$q$),
('c2b934ff-30a7-4bb3-af1d-7b97223536f9', NULL, $q$Camden Market, Borough Market og Portobello Road, der London viser sin kreative side med mat, musikk og handel.$q$),
('420f22ad-77ff-4de6-9095-29bc59dc41bf', $q$Katedralen$q$, $q$Renessansekatedralen «La Manquita» med det ene tårnet, omgitt av gågater, plasser og gode tapasbarer.$q$),
('e5b6bf8b-74cf-4f2b-9531-e152da9577cf', NULL, $q$Kunstnerens hjemby viser et bredt utvalg av Picassos verk i et palass fra 1500-tallet, nær huset der han ble født.$q$),
('b9983a34-bfca-42a3-ac89-786f40fd43cf', NULL, $q$Den hvite byen på kanten av kløften El Tajo, med broen Puente Nuevo og en av Spanias eldste tyrefekterarenaer.$q$),
('5d8e3204-cc6b-4576-a196-3838984dee49', $q$Havnepromenaden$q$, NULL),
('bd3ca4cc-91cf-41f8-801e-d77707b21fbb', $q$Medinaen$q$, $q$Den gamle bydelen med trange souker og palasser – og torget Jemaa el-Fna som våkner til liv når kvelden kommer.$q$),
('109b931f-f7b2-4782-bcb6-e221741647fe', NULL, $q$Steinørken like utenfor byen, populær for middag og solnedgang over Atlasfjellene – en helt annen stemning.$q$),
('464835ac-86d5-4721-b530-77b78c9171fc', NULL, $q$Kystby et par timer unna, med hvitkalket medina, fiskehavn og frisk havbris – en rolig kontrast til Marrakech.$q$),
('6cad03f9-08b0-4f0b-a31b-5a1848ba64e9', NULL, $q$Frodig botanisk hage i intense blåtoner, anlagt av Jacques Majorelle og senere eid av Yves Saint Laurent.$q$),
('4922b6b4-896b-4ad7-a7cd-1f2d9fe7dd47', $q$Marienplatz$q$, NULL),
('7cb0b3df-a02f-4a51-9512-91ca96c9df33', $q$Hofbräuhaus$q$, $q$Verdens mest kjente ølhall med blåsemusikk og lange bord, og matmarkedet Viktualienmarkt med bayerske spesialiteter.$q$),
('9cf68864-4def-400a-8130-58b97db59cb5', $q$Allianz Arena$q$, NULL),
('2c08a05f-7314-4901-9112-ed6e382466e6', $q$Deutsches Museum$q$, $q$Verdens største teknikkmuseum på øya i Isar, og BMWs museum og utstillingsbygg ved Olympiaparken.$q$),
('dbf9a65f-c742-4602-82a8-adf4c89e0bd7', $q$Spaccanapoli$q$, $q$Den lange, rette gaten gjennom gamlebyen, med kirker, verksteder, pizzeriaer og julekrybbeverkstedene.$q$),
('ac33e88b-7803-46a1-a441-08f29afa408d', $q$Arkeologisk museum$q$, $q$Et av verdens viktigste museer for antikken, med mosaikker, fresker og skulpturer fra Pompeii og Herculaneum.$q$),
('d09ae055-647e-4046-89ed-8cb07511a5ff', NULL, $q$Byens grønne lunge med Bethesda Terrace, Strawberry Fields og robåter på innsjøen midt mellom skyskraperne.$q$),
('69528389-993f-4ae1-81ff-c63a11ce2ff7', $q$Frihetsgudinnen$q$, $q$Båtturen ut til statuen og Ellis Island, der tolv millioner innvandrere, mange nordmenn, kom til Amerika.$q$),
('42700954-39f9-4b67-b70b-f02e440003eb', $q$9/11 Memorial$q$, $q$Minnestedet med de to bassengene der tvillingtårnene sto, museet og utsikten fra One World Observatory.$q$),
('dabb2338-f94d-43c5-a607-d9820642ff1a', $q$Times Square$q$, NULL),
('2213af20-f851-4488-822d-5666a701e112', $q$Brooklyn Bridge$q$, NULL),
('5adcb1e3-e78e-45a4-99b2-c1e3017d10bd', $q$High Line$q$, $q$Den hevede parken på den gamle jernbanen gjennom Chelsea, med Chelsea Market og Hudson Yards ved enden.$q$),
('dbbdd012-6405-4667-9d25-c6820f45c540', $q$Gamlebyen$q$, NULL),
('49fcd960-adce-4e1c-a692-b258ccb74bd1', NULL, $q$Parken på klippen mellom gamlebyen og havnen, med det klassiske utsiktsbildet over Englebukten.$q$),
('3c4c4847-5da7-46c7-b8a0-1c98da15f3a3', NULL, $q$Fyrstedømmet med palasset, katedralen der Grace Kelly er begravet, casinoet og havnen med luksusyachtene.$q$),
('933a83c6-97e1-49bb-af78-7bfae677452f', NULL, $q$Antibes med Picasso-museet og den gamle havnen, og Cannes med Croisette og gamlebyen Le Suquet.$q$),
('8e82a10c-69f8-40bb-93e6-2116319e8a27', $q$Matisse og Chagall$q$, NULL),
('7ea084ed-22ff-4866-b1c4-21412f3a6a94', NULL, $q$Byens ikoniske landemerke fra 1889, med utsikt over hele Paris – spesielt vakkert når tårnet lyser om kvelden.$q$),
('ba41912c-f6d3-477f-88ef-bd61a0a875dd', NULL, $q$Verdens mest besøkte museum, med Mona Lisa, Venus fra Milo og tusenvis av verk under glasspyramiden.$q$)
) as v(id, navn, tekst) where h.id = v.id::uuid;
update reisemaal_hoydepunkter as h set navn = coalesce(v.navn, h.navn), korttekst = coalesce(v.tekst, h.korttekst)
from (values
('7d1d1b69-4711-4ddb-bad0-3126ce1282b3', $q$Notre-Dame$q$, NULL),
('d6f03356-5f21-41bd-950c-4aaf7db35fd2', $q$Montmartre$q$, NULL),
('85c1ad8d-bb88-4aba-9598-9e3227c40088', $q$Le Marais$q$, NULL),
('68e1c2c8-2f27-42a7-80f5-db9d3d51fd40', $q$Stranden$q$, NULL),
('0df5589a-852d-4b9f-8a55-776da3598419', NULL, $q$Direkte tog langs kysten tar gruppen til Barcelona på under en time – Sagrada Família, gamlebyen og La Rambla.$q$),
('d541f83e-eae5-4cfb-bdd6-d3ce9ebccae0', NULL, $q$Middelalderbyen med fargerike hus langs elven Onyar, katedralen og det jødiske kvarteret, en times reise unna.$q$),
('181c5edd-ccb2-45e5-9c9b-f9cb5c99ac18', $q$Costa Brava$q$, NULL),
('6c4b4d0e-f199-43f7-b0b9-42f2d0731e76', $q$Bykjernen og markedet$q$, $q$Pinedas sentrum med Sant Joan-kirken, lokale restauranter og det tradisjonelle ukemarkedet med varer fra distriktet.$q$),
('41a573fa-69c4-4034-80c7-667c033b39c0', $q$Portvinskjellerne$q$, $q$På motsatt elvebredd ligger kjellerne der portvinen lagres, med omvisning, smaking og utsikt tilbake mot Porto.$q$),
('1a0e6655-0679-44fe-a72e-24cd969859f0', $q$Livraria Lello$q$, $q$Den praktfulle bokhandelen fra 1906 og Clérigos-tårnet med utsikt over hele byen, midt i Portos sentrum.$q$),
('3ff0db79-2cbd-40ab-98d7-b2a4ae798a35', NULL, $q$Portugals religiøse hovedstad med kirken Bom Jesus, og nasjonens fødeby Guimarães med borg og middelaldergater.$q$),
('17f49ad2-fa7f-4fa1-8835-64c4f144b52c', $q$Foz do Douro$q$, $q$Der elven møter Atlanterhavet, med promenade, strender og fyret i Foz, og fiskebyen Matosinhos med grillet sjømat.$q$),
('65c85276-3942-4448-91f2-a8a7197d249d', $q$Praha-borgen$q$, $q$Verdens største sammenhengende borgkompleks, med St. Vitus-katedralen, Gullgaten og utsikt over hele Praha.$q$),
('c4146f12-4c51-4f72-8893-8b3144054106', $q$Gamlebyplassen$q$, $q$Byens hjerte med Týn-kirkens tårn, Jan Hus-monumentet og det astronomiske uret fra 1410 som spiller hver hele time.$q$),
('09eaf4cb-fcff-45b9-a26b-b4bef00aa9c3', $q$Josefov$q$, NULL),
('6b435ebd-a947-4aae-b120-59261d30ee44', $q$Gamlebyen$q$, $q$Hansabyen ved Daugava med det gjenreiste Svarthodenes hus, Rådhusplassen, Tre brødre og smale middelaldergater.$q$),
('b4c05836-ba32-438d-b28d-496bfd660ccd', $q$Domkirken$q$, NULL),
('6a097635-6e54-468d-9931-fea62183f377', $q$Colosseum$q$, $q$Antikkens Roma i konsentrert form: verdens største amfiteater og ruinene av Forum Romanum.$q$),
('6262a653-7e4c-4ea3-b23d-fd364d5eeb2a', $q$Peterskirken$q$, NULL),
('d0bbe878-2d65-4428-9765-fd8620c696c4', $q$Vatikanmuseene$q$, NULL),
('27c26100-c7a1-4ea7-b70f-6e690a1e84a7', $q$Katakombene$q$, NULL),
('2002c315-82aa-4613-b28f-7aa39cac6b1c', $q$Pantheon$q$, $q$Antikkens best bevarte byggverk og Romas vakreste barokkplass, Piazza Navona, få minutters gange fra hverandre.$q$),
('edf7dd85-e857-499a-87ec-22cccf9330e5', $q$Fontana di Trevi$q$, NULL),
('4227af52-b391-4981-a220-cf6d49bf4f21', $q$Hohensalzburg$q$, NULL),
('7aaf314e-7226-4a0b-b745-c30d1d3246f7', $q$Gamlebyen$q$, NULL),
('be444d73-6e4a-454d-923a-633f48115ab8', $q$Mozarts fødehus$q$, NULL),
('7fde86f1-1242-4dfa-b10e-707f452e1188', $q$Mirabell-hagen$q$, NULL),
('3f19b76d-d617-4c10-b08d-7a25044a7a57', $q$Hallstatt$q$, $q$Den lille landsbyen mellom fjellet og innsjøen, en av Østerrikes mest fotograferte, og innsjølandskapet rundt.$q$),
('23df2567-6eb3-4ded-8965-bbe3fdcdc848', $q$Königssee$q$, NULL),
('768a4d8a-f466-4bdf-b564-fbdeef647f33', NULL, $q$Verdens største gotiske katedral med graven til Columbus, og tårnet Giralda med utsikt over byen.$q$),
('cc2d0c54-b4c7-48b9-8d6b-2deea3a943e9', NULL, $q$Det kongelige palasset med mudéjar-arkitektur, gårdsrom og hager – Europas eldste palass fortsatt i bruk.$q$),
('36ee54fe-8453-46ae-ba62-1321ba4b936b', $q$Plaza de España$q$, $q$Den halvsirkelformede praktplassen fra 1929 med kanaler, broer og flisbenker for hver spansk provins.$q$),
('6ba60689-8c25-413a-828d-f7e9f27df1be', NULL, $q$Bydelen på andre siden av elven, flamencoens hjem, med tapasbarer langs Calle Betis og forestillinger om kvelden.$q$),
('8fde0f14-6563-4140-ba5a-a1a92cff1af7', $q$Ronda$q$, NULL),
('3b99452c-8b76-490f-ae95-6184e9e45160', NULL, $q$Antikkens greske storby med det store teateret, og øya Ortigia med barokkatedralen bygget rundt et gresk tempel.$q$),
('bdece807-d6f7-4411-8cf5-1827b1292d94', NULL, $q$Sicilias hovedstad med arabisk-normanniske kirker og livlige markeder, og katedralen i Monreale med gullmosaikker.$q$),
('6ba12761-fef8-4374-8507-30b1672318ac', $q$Noto og Ragusa$q$, $q$Byene som ble gjenreist i honninggul barokk etter jordskjelvet i 1693, med palasser og kirker på UNESCOs liste.$q$),
('fda3a3ab-00ce-40d7-bc32-b1fdfa85d40e', $q$Södermalm$q$, NULL),
('88e1a4b5-b413-446b-a413-c6c970996ac5', $q$Gamlebyen$q$, NULL),
('699b5870-ee96-4ada-bbe9-2580f19e06a8', NULL, $q$Domhøyden over gamlebyen, med Alexander Nevskij-katedralen, parlamentet og utsikt over de røde takene.$q$),
('c0cb1705-4e53-4716-a3fb-96aa02fe87a1', $q$Lennusadam$q$, NULL),
('e849acc2-727f-4d26-a55e-e1b0428c0d79', $q$Gamlebyen$q$, $q$Katedralen med Den hellige gral og Miguelete-tårnet, silkebørsen La Lonja fra 1400-tallet og plassene rundt.$q$),
('15f09768-b8a6-4d8d-81aa-28d674139474', $q$Kunst- og vitenskapsbyen$q$, NULL),
('88709b0c-4c2a-49ae-89cd-89890016d24e', NULL, $q$Den gamle elvebunnen som ble ni kilometer park gjennom byen, med sykkelstier fra Bioparc til havet.$q$),
('2067a4cd-ab87-48e7-ad68-7f3f8545e969', $q$Gamlebyen$q$, NULL),
('62d3ce76-adaa-4daa-ab19-ed3968cd014f', NULL, $q$Den selverklærte republikken på andre siden av elven Vilnia, med egen grunnlov, kunstnere og kafeer.$q$),
('b63e1c70-a904-4a36-98e9-b3fa828112a8', $q$Morgenporten$q$, $q$Den eneste bevarte byporten med Maria-ikonet, og hovedgaten gjennom gamlebyen med marked, kafeer og ravbutikker.$q$),
('16603a79-78ab-4faf-8570-be547a019889', $q$KGB-museet$q$, $q$Det tidligere KGB-hovedkvarteret med cellene bevart, om okkupasjonene og veien til frihet i 1991.$q$),
('04932460-d0d8-499d-868d-2d7bbe4b0f8d', $q$The Shambles$q$, NULL),
('8287fc83-11d1-4385-a14e-883f1b899502', $q$North York Moors$q$, NULL),
('6f613bac-2c4c-42f1-8e60-d6f1dba853f6', NULL, $q$Ruinene av et av Englands største cistercienserklostre, i en vakker dal på UNESCOs verdensarvliste.$q$)
) as v(id, navn, tekst) where h.id = v.id::uuid;
