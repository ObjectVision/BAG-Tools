# BAG Toolkit

GeoDMS configurations to turn the Dutch [BAG](https://www.kadaster.nl/zakelijk/registraties/basisregistraties/bag) (Basisregistratie Adressen en Gebouwen) into data you can model with.

The BAG is the national register of buildings and addresses: every pand, verblijfsobject, ligplaats, standplaats, nummeraanduiding, openbare ruimte and woonplaats in the Netherlands, with its geometry, status and full history. Kadaster publishes it monthly as a free extract of more than 3.000 XML/GML files. That format is fine for exchange and poor for analysis: it holds every mutation an object ever had, references between objects are identifier strings, and nothing in it is a table.

This toolkit converts the extract into [MMD](https://github.com/ObjectVision/GeoDMS/wiki/MMD) stores, the native format of [GeoDMS](https://github.com/ObjectVision/GeoDMS), reduces them to the state of the BAG at a chosen date, derives attributes the register does not contain, and geocodes address files against it.

## the tools

```
BAG 2.0 XML extract  ─►  BAG20_Xml2MMD  ─►  one store per object type,     ─►  BAG20_MakeSnaphot  ─►  bag.mmd: the BAG at one date,
                                             full history                                            relations, classifications,
                                                                                                     woonpand type, addresses, heights
                                                        │
                                                        └─────►  Geocode  ─►  your address file with RD coordinates and BAG attributes
```

- **BAG20_Xml2MMD** (`cfg/BAG20_Xml2MMD.dms`) parses the extract into an MMD store per object type, geometry in RD metres, with all voorkomens. Pand and verblijfsobject are delivered in many files and are stored per file set. `bat/RunXml2MMD.bat` runs it from the command line in one process under a memory budget, so file sets are processed side by side as far as memory allows. Until 2026 this tool was called Xml2FSS.
- **BAG20_MakeSnaphot** (`cfg/BAG20_MakeSnaphot.dms`) selects the voorkomen of every object that is valid on a given date, optionally within a geographic extent, with a status selection and without probable data errors, and writes one store, `bag.mmd`. In it the references between object types are real relations (`vbo/pand_rel`, `vbo/nummeraanduiding_rel`, ...), statuses are codes into classification tables that carry the labels, every nummeraanduiding has a point geometry with its street and place name, and every pand has a [woonpand type](https://github.com/ObjectVision/BAG-Tools/wiki/Woonpand-typering) (vrijstaand, twee onder 1 kap, hoekwoning, tussenwoning, meergezinspand). Building heights from the PHN are optional. A GeoPackage export is available for use outside GeoDMS.
- **Geocode** (`cfg/Geocode.dms`) matches the addresses in a csv file against the BAG in a decision tree of sixteen levels, from a full match on postcode, street, number, addition and place down to the place alone, and reports for every record the level reached, the number and spread of the BAG addresses behind the coordinate, the CBS buurt, wijk and gemeente, and the BAG attributes of the matched object. Developed with the [Spinlab of the VU Amsterdam](https://spinlab.vu.nl/).
- **BAG20_ReadAndProcessSnaphot** (`cfg/BAG20_ReadAndProcessSnaphot.dms`) is an example project that opens `bag.mmd` and relates verblijfsobjecten, panden and addresses, as a starting point for your own.

## requirements

- [GeoDMS 20.20.0](https://github.com/ObjectVision/GeoDMS/releases) or later. Xml2MMD refuses an older version, and the snapshot store needs 20.20.0 to be read back. The visualisation styles of the ligplaats and standplaats tables are written into the snapshot by 20.21.0 or later.
- 16 GB of RAM or more; the BAG is large. With 16 GB the conversion and the snapshot each take roughly half an hour to an hour. More memory lets `RunXml2MMD.bat` run file sets in parallel.
- 40 GB of disk space or more.
- The BAG 2.0 extract, from the [Kadaster download page](https://www.kadaster.nl/-/kosteloze-download-bag-2.0-extract).
- For heights: the [PHN](https://www.geodms.nl/downloads/PHN/PHN_20230101.fss.zip) (Pand Hoogte Nederland, derived from the AHN).

## quick start

1. Unzip the LIG, NUM, OPR, PND, STA, VBO and WPL zip files of the extract into `%SourceDataDir%/BAG/<yyyymmdd>/NGR`. `%SourceDataDir%` is a GeoDMS placeholder, `C:/SourceData` by default.
2. Set `date` in `cfg/BAG20_Xml2MMD.dms` to that date and run `bat\RunXml2MMD.bat`, or open the configuration in the GeoDMS GUI and double click `MaakMMDBestanden`. The stores appear in `%SourceDataDir%/BAG/<yyyymmdd>/mmd`.
3. Set `BAG_Date` and `Snapshot_Date_Input` in `cfg/BAG20_MakeSnaphot.dms`, open it in the GUI, pick one of the examples under `snapshots` and double click its `MaakVolledigeSnapshot`. The snapshot appears in `%SourceDataDir%/BAG/snapshots.ext/<yyyymmdd>.new/bag.mmd`.
4. Read it from your own project with an empty storage holder; the store describes itself. Only the coordinate unit and the two date units are yours to declare, under exactly these names:

```
container geometries { unit<dpoint> rdc : SpatialReference = "EPSG:28992"; }
container eenheden   { unit<int16> jaar; unit<int32> datum; }

container bag : StorageName = "%SourceDataDir%/BAG/snapshots.ext/20260101/bag.mmd", StorageReadOnly = "True"
{
}

attribute<string> pand_id (bag/vbo) := bag/pand/identificatie[bag/vbo/pand_rel];
```

The polygon operations can run on either of two engines, `geos` (default) or GeoDMS's own `dms` sweep, chosen with the overridable setting `GEO_ENGINE`; both give the same stores.

## documentation

The [wiki](https://github.com/ObjectVision/BAG-Tools/wiki) describes each tool, its options and its results:
[Xml2MMD](https://github.com/ObjectVision/BAG-Tools/wiki/BAG20-Xml2MMD),
[MakeSnapshot](https://github.com/ObjectVision/BAG-Tools/wiki/BAG20-MakeSnapshot) and [how to use it](https://github.com/ObjectVision/BAG-Tools/wiki/How-to-use-the-MakeSnapshot-Script),
[GeoCode](https://github.com/ObjectVision/BAG-Tools/wiki/GeoCode) with [how to use it](https://github.com/ObjectVision/BAG-Tools/wiki/How-to-use-the-geocode-script) and [how to read its results](https://github.com/ObjectVision/BAG-Tools/wiki/How-to-interpret-the-GeoCode-results),
and the [woonpand typering](https://github.com/ObjectVision/BAG-Tools/wiki/Woonpand-typering).

Questions and problems go in the [issues](https://github.com/ObjectVision/BAG-Tools/issues).

## license

The BAG Toolkit is available under the [GNU GPL version 3](http://www.gnu.org/licenses/gpl-3.0.html). It is developed and maintained by [Object Vision](https://www.objectvision.nl).
