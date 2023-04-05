[[images/BAG_pand_vbo_w500.png]]

*BAG panden (blauwe vlakken) en verblijfsobjecten (groene puntlokaties)*

## inhoud

De BAG is de registratie waarin gemeentelijke basisgegevens over alle gebouwen en adressen in Nederland zijn verzameld.

De BAG kent de volgende objectklassen, waarvoor gegevens worden bijgehouden:

- **woonplaats**: is een door het bevoegde gemeentelijke orgaan als zodanig aangewezen en van een naam voorzien gedeelte van het grondgebied van de gemeente.
- **openbare ruimte**: een door het bevoegde gemeentelijke orgaan als zodanig aangewezen en van een naam voorziene buitenruimte die binnen één woonplaats is gelegen.
- **nummeraanduiding**: een door het bevoegde gemeentelijke orgaan als zodanig toegekende aanduiding van een verblijfsobject, standplaats of ligplaats.
- **pand**: de kleinste bij de totstandkoming functioneel en bouwkundig-constructief zelfstandige eenheid die direct en duurzaam met de aarde is verbonden en betreedbaar en afsluitbaar is.
- **ligplaats**: is een door het bevoegde gemeentelijke orgaan als zodanig aangewezen plaats in het water al dan niet aangevuld met een op de oever aanwezig terrein of een gedeelte daarvan, die bestemd is voor het permanent afmeren van een voor woon-, bedrijfsmatige of recreatieve doeleinden geschikt vaartuig.
- **standplaats**: is een door het bevoegde gemeentelijke orgaan als zodanig aangewezen terrein of gedeelte daarvan dat bestemd is voor het permanent plaatsen van een niet direct en niet duurzaam met de aarde verbonden en voor woon-, bedrijfsmatige, of recreatieve doeleinden geschikte ruimte.
- **verblijfsobject**: is de kleinste binnen één of meer panden gelegen en voor woon-, bedrijfsmatige, of recreatieve doeleinden geschikte eenheid van gebruik die ontsloten wordt via een eigen afsluitbare toegang vanaf de openbare weg, een erf of een gedeelde verkeersruimte, onderwerp kan zijn van goederenrechtelijke rechtshandelingen en in functioneel opzicht zelfstandig is.

Een adres is een combinatie van woonplaats, openbare ruimte (straatnaam) en nummeraanduiding. Elk verblijfsobject, ligplaats en standplaats heeft (of krijgt) een adres.

## versie

De BAG is begonnen met een versie 1.0. Vanaf 2020 wordt gewerkt met de [BAG 2.0](https://www.kadaster.nl/zakelijk/producten/adressen-en-gebouwen/bag-2.0-extract) en versie 1.0 wordt uitgefaseerd. De toolkits die we beschikbaar stellen is voor de 2.0 versie.

## uitvoering

Het [Kadaster](https://www.kadaster.nl) beheert de Landelijke Voorziening voor de BAG (BAGLV). Gemeenten leveren hier hun gegevens aan.

## toolkit

De BAG kan worden gedownload als verzameling XML bestanden. De omvang van de data, alsmede het feit dat het om een database gaat met historie,  maakt het werken met de BAG niet eenvoudig.

Wij stellen graag onze [BAG Toolkit](Home) beschikbaar, bijvoorbeeld om snapshots met afgeleide attributen te maken of om adressen te geocoderen.

## voorbeelden

- Een [voorbeeld configuratie](https://github.com/ObjectVision/GeoDMS/wiki/BAG-relate-attributes-and-make-grids-example) is beschikbaar, inclusief data, waarmee relaties gemaakt worden tussen BAG objecten (denk aan de vbo oppervlakte per pand) en waarmee grid kaarten gemaakt kunnen worden.
- Met behulp van [OSM](wikipedia:OpenStreetMap "wikilink") en de BAG zijn de afstanden berekend over de weg van ieder pand uit de BAG naar de dichtsbijzijnde basisschool. De resultaten zijn beschikbaar gesteld aan [EduGIS](http://www.edugis.nl).
- Met behulp van [OSM](wikipedia:OpenStreetMap "wikilink") en de BAG is een reisweerstandentabel berekend op pc4 niveau, die o.a. gebruikt is voor het [VPRO programma Nederland van Boven](https://www.vpro.nl/programmas/nederland-van-boven.html#/mobility/0:63/0:255:0/0:255:0/@8/52.198/6.168?mode=auto&zip=1082).

## verwijzingen

- [Basisregistratie BAG](https://www.digitaleoverheid.nl/overzicht-van-alle-onderwerpen/stelsel-van-basisregistraties/10-basisregistraties/bag)
- [Kadaster over BAG](https://bag.basisregistraties.overheid.nl)
- [De BAG in 5 minuten](https://www.youtube.com/watch?v=m_YmHUqAROo)