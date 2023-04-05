# BAG Toolkit

[[images/300px-WZWKaartKennemerland.png]]

The [[BAG]] Toolkit is used to model with the BAG. The current version of the toolkit works with the BAG 2.0 format. 

The BAG is a rich dataset which can be used in many applications, but its exchange format ([xml](https://nl.wikipedia.org/wiki/Extensible_Markup_Language)/[gml](https://nl.wikipedia.org/wiki/Geography_Markup_Language)) is not very convenient for calculations and selections.

With the BAG Toolkit you can make the data available in a suitable format for modelling, calculate snapshots, derive entities/attributes and use the BAG addresses for [geocoding](https://en.wikipedia.org/wiki/Address_geocoding).

The following extra attributes are or can be calculated:
- [[residential type (woningtype)|woonpand_type]], see for example [residential type layer in a residential services webmap application](https://kl.wzwkaart.nl/app/map/1?zoom=10&center=104873,488856&layerIds=11003,31000,21002)
- altitude

The snapshot process also generates an address table, with [RD-coordinates](https://nl.wikipedia.org/wiki/Rijksdriehoeksco%C3%B6rdinaten).

## components

The BAG Toolkit consists of three tools:

1. [[BAG20 Xml2FSS]] -> To make the BAG available in a format suitable for modelling.
2. [[BAG20 MakeSnapshot]] -> To make a snapshot of the BAG at a specific date. 
3. [[GeoCode]] -> To geocode addresses with meta information on how the results are derived. This tool we developed with the [Spinlab department of the VU](https://spinlab.vu.nl/).

### additional
- The toolkits also contains a script called: _BAG20_ReadAndProcessSnaphot.dms_, as an example on how to read the results of a snapshot and process it for different applications. This configuration is documented [here](https://github.com/ObjectVision/GeoDMS/wiki/BAG-relate-attributes-and-make-grids-example).
- In the _/bat_ subfolder the _RunMultipleMakeSnapshots.bat_ shows an example how to make a set of snapshots for different dates with a batch file. 

## requirements

- [GeoDMS version 8.8.1](https://github.com/ObjectVision/GeoDMS/releases) or later
- Internal ram: 16 GB or more (as the BAG is a large dataset)
- Hard disk space: 40 GB or more
- Access rights to your LocalDataDir (default: C:\LocalData) and SourceDataDir (default: C:\SourceData). If not adjust these [placeholders](https://github.com/ObjectVision/GeoDMS/wiki/Folders-and-Placeholders) with the [GeoDMS GUI](https://github.com/ObjectVision/GeoDMS/wiki/GeoDMS-GUI): menu option > Tools > Options > Advanced tab.
- For height information in snapshot, download the [**PHN**](https://www.geodms.nl/downloads/PHN/PHN_20230101.fss.zip) and unzip it in your _%SourceDataDir%_/PHN folder. PHN stands for: Pand Hoogte Nederland, based on the [AHN4](https://www.ahn.nl/ahn-4).

## license

The BAG Toolkit is available under [GNU-GPL version 3 license](http://www.gnu.org/licenses/gpl-3.0.html).

## download

The BAG Toolkit scrips can be downloaded [here](https://github.com/ObjectVision/BAG-Tools). Activate the green Code tool, use the url to make a GIT clone or just download the code as zip file and unzip this file in a project folder like: _D:\prj\BAGTools_. 

## see also

- Since 2020, BAG snapshots in [Geopackage format](https://github.com/ObjectVision/GeoDMS/wiki/Geopackage) are also available via [Geoparaat](http://geoparaat.nl).
- This [configuration example (with data)](https://github.com/ObjectVision/GeoDMS/wiki/BAG-relate-attributes-and-make-grids-example) show how a BAG snapshot can be used to relate attributes (e.g. to calculate the vbo surface or the address range for each pand) or how to make grid maps with the BAG.
