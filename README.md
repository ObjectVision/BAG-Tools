# BAG Toolkit

GeoDMS configurations to turn the Dutch [BAG](https://www.kadaster.nl/zakelijk/registraties/basisregistraties/bag) (Basisregistratie Adressen en Gebouwen) into data you can model with.

The BAG is the national register of buildings and addresses: every pand, verblijfsobject, ligplaats, standplaats, nummeraanduiding, openbare ruimte and woonplaats in the Netherlands, with its geometry, status and full history. Kadaster publishes it monthly as a free extract of more than 6.000 XML/GML files. That format is fine for exchange and poor for analysis: it holds every mutation an object ever had, references between objects are identifier strings, and nothing in it is a table.

This toolkit converts the extract into [MMD](https://github.com/ObjectVision/GeoDMS/wiki/MMD) stores, the native format of [GeoDMS](https://github.com/ObjectVision/GeoDMS): one compact store per object type with the full history of the BAG. From those it derives the state of the BAG at a chosen date, with attributes the register does not contain, and it geocodes address files against it.

## the tools

```
BAG 2.0 XML extract  ─►  Xml2MMD   ─►  one store per object type,  ─►  MakeSnapshot  ─►  bag.mmd: the BAG at one date,
                                        full history, compact                            relations, classifications,
                                                   │                                     woonpand type, addresses, heights
                                                   └─────►  Geocode  ─►  your address file with RD coordinates and BAG attributes
```

- **Xml2MMD** (`cfg/Xml2MMD.dms`) parses the extract into one MMD store per object type with all voorkomens: `pand.mmd`, `vbo.mmd`, `nummeraanduiding.mmd`, `ligplaats.mmd`, `standplaats.mmd`, `openbareruimte.mmd` and `woonplaats.mmd`. The stores are the full table of the BAG, compact enough to read directly: identificaties as `uint64`, statuses and types as codes with their label tables in the store, registration timestamps as dates, geometry in millimetres (`ipoint`, lossless, half the size of `dpoint`), pand polygons simplified with a tolerance of 0.1 m (a polygon smaller than that keeps its shape), and every verblijfsobject with a point. Pand, verblijfsobject and nummeraanduiding are delivered in thousands of files; Xml2MMD parses them per file set of 50 into intermediate stores and merges those, so the file sets are a detail of the conversion and not of the result. `bat/RunXml2MMD.bat` runs it from the command line. Until 2026 this tool was called Xml2FSS.
- **MakeSnapshot** (`cfg/MakeSnapshot.dms`) selects the voorkomen of every object that is valid on a given date, optionally within a geographic extent, with a status selection and without probable data errors, and writes one store, `bag.mmd`. In it the references between object types are real relations (`vbo/pand_rel`, `vbo/nummeraanduiding_rel`, ...), statuses and types are codes into classification tables that carry the labels, the geometry is in metres, every nummeraanduiding has a point geometry with its street and place name, and every pand has a [woonpand type](https://github.com/ObjectVision/BAG-Tools/wiki/Woonpand-typering) (vrijstaand, twee onder 1 kap, hoekwoning, tussenwoning, meergezinspand). Building heights from the PHN are optional. A GeoPackage export is available for use outside GeoDMS.
- **Geocode** (`cfg/Geocode.dms`) matches the addresses in a csv file against the BAG in a decision tree of sixteen levels, from a full match on postcode, street, number, addition and place down to the place alone, and reports for every record the level reached, the number and spread of the BAG addresses behind the coordinate, the CBS buurt, wijk and gemeente, and the BAG attributes of the matched object. It reads the stores of Xml2MMD and selects the voorkomens valid on its own date. Developed with the [Spinlab of the VU Amsterdam](https://spinlab.vu.nl/).

The code lists the tools share (the statuses per object type, the gebruiksdoelen, the types of nummeraanduiding and openbare ruimte) are in `cfg/Classifications.dms`. A value in an extract that is not in a list stops Xml2MMD, so a new value from Kadaster is noticed and added instead of silently lost.

## requirements

- [GeoDMS 20.23.1](https://github.com/ObjectVision/GeoDMS/releases) or later; each configuration refuses an older version. GeoDMS 20.23.0 changed the reading of an XML attribute that an element lacks (null instead of an empty string), which the parser relies on.
- 16 GB of RAM or more; the BAG is large. The conversion runs in two steps; the first parses one file set of 50 files at a time per process and releases it once its intermediate store is written, the second merges the intermediate stores memory-mapped. Measured on a server with 32 logical processors and 128 GB (extract of 2026-10-08, GeoDMS 20.23.1, `bat/RunXml2MMD.bat` with its default budget of 8000 MB): the first step took 31 minutes with a peak of 2.2 GB committed, the second 35 seconds with 1.6 GB. The previous version took 28 minutes with a peak of 35 GB, and a version that merged the file sets in the process that parsed them 18 minutes with 75 GB, which is why the steps are separate. A snapshot of the whole country took 77 seconds with a peak of 11 GB on the same server, with the woonpand typing and parallel processing on; the previous version took 164 seconds on the same stores.
- About 110 GB of disk space during the conversion: the unpacked XML of the extract is about 90 GB (6.474 files for 2026-10-08), the intermediate stores 9 GB and the final stores 8 GB (the stores of the previous format took 24 GB). The XML and the intermediate stores can be deleted once the stores are written; a snapshot of the whole country takes a few GB.
- The BAG 2.0 extract, from the [Kadaster download page](https://www.kadaster.nl/-/kosteloze-download-bag-2.0-extract).
- For heights: the [PHN](https://www.geodms.nl/downloads/PHN/PHN_20230101.fss.zip) (Pand Hoogte Nederland, derived from the AHN).

## quick start

1. Unzip the LIG, NUM, OPR, PND, STA, VBO and WPL zip files of the extract into `%SourceDataDir%/BAG/<yyyymmdd>/NGR`. `%SourceDataDir%` is a GeoDMS placeholder, `C:/SourceData` by default; the BAG folder itself is the overridable setting `BAG_DIR` of every configuration, on the command line the environment variable `GEODMS_Overridable_BAG_DIR`.
2. Set `date` in `cfg/Xml2MMD.dms` to that date and run `bat\RunXml2MMD.bat`. In the GeoDMS GUI: double click `Step1_Make_Temp_Files`, reopen the configuration, then double click `Step2_Make_MMD_Files`. The stores appear in `%SourceDataDir%/BAG/<yyyymmdd>/mmd`, the intermediate stores in `%LocalDataProjDir%/Temp/<yyyymmdd>`.
3. Set `BAG_Date` and `Snapshot_Date_Input` in `cfg/MakeSnapshot.dms`, open it in the GUI, pick one of the examples under `snapshots` and double click its `MaakVolledigeSnapshot`. The snapshot appears in `%SourceDataDir%/BAG/snapshots.ext/<yyyymmdd>.new/bag.mmd`.
4. Read a store from your own project with an empty storage holder; the store describes itself. Only the coordinate units and the two date units are yours to declare, under exactly these names:

```
container Geography
{
	unit<dpoint> rdc    : SpatialReference = "EPSG:28992";                                        // the snapshot: metres
	unit<ipoint> rdc_mm := gridset(rdc, point_yx(0.001d, 0.001d), point_yx(0d, 0d), ipoint);      // the stores of Xml2MMD: millimetres
}
container eenheden   { unit<int16> jaar; unit<int32> datum; }

container bag : StorageName = "%SourceDataDir%/BAG/snapshots.ext/20261001/bag.mmd", StorageReadOnly = "True"
{
}
attribute<uint64> pand_id (bag/vbo) := bag/pand/identificatie[bag/vbo/pand_rel];
attribute<string> pand_id_tekst (bag/vbo) := right('0000000000000000' + string(pand_id), 16);   // the identificatie as the BAG writes it

unit<uint32> alle_panden : StorageName = "%SourceDataDir%/BAG/20261008/mmd/pand.mmd", StorageReadOnly = "True"
{
}
attribute<Geography/rdc> geometry_m (alle_panden, polygon) := alle_panden/geometry[Geography/rdc];
attribute<string>         status     (alle_panden)          := alle_panden/status/Label[alle_panden/meta/status_rel];
```

The polygon operations can run on either of two engines, `geos` (default) or GeoDMS's own `dms` sweep, chosen with the overridable setting `GEO_ENGINE`; both give the same stores, except for the woonpand type of a few panden. To count neighbours, `dms` inflates every pand with an octagon around the 0.2 m circle that `geos` uses, which finds every neighbour pair of `geos` plus about 0.2% that lie 0.40 to 0.43 m apart. The woonpand typing, a buffer and a neighbour count per rectangle of a 13 by 7 grid over the country, is where the engines differ most.

Keep the parallel processing options 1, 2 and 3 of the GeoDMS Local machine Options on. With them off, a snapshot runs on one core and takes two to two and a half times as long. In the GUI such a run looks hung ([#7](https://github.com/ObjectVision/BAG-Tools/issues/7)), and up to GeoDMS 20.23 GeoDmsRun also holds back its progress messages until the item is finished; since GeoDMS 20.24.0 GeoDmsRun writes them to its log while the run goes on ([GeoDMS#1303](https://github.com/ObjectVision/GeoDMS/issues/1303)).

## what changed in October 2026

The stores of Xml2MMD and the snapshot of MakeSnapshot changed format. Readers of the previous format need to know:

- identificaties are `uint64` instead of strings, in the stores and in the snapshot; a relation such as `vbo/pand_rel` is unchanged;
- the status of a voorkomen is a code, `meta/status_rel`, into the label table `status` in the store (in the snapshot `status_pand` and so on); `typeAdresseerbaarObject` and the `type` of an openbare ruimte are codes too, with the tables `typeAdresseerbaarObject` and `type` (in the snapshot `type_openbareruimte`);
- `TIJDSTIPREGISTRATIE` and `EINDREGISTRATIE` are dates, `yyyymmdd`, no longer timestamps as text;
- the geometry of the stores is in millimetres, `/Geography/rdc_mm`, and the pand polygons are simplified with a tolerance of 0.1 m; the snapshot stays in metres;
- a verblijfsobject that the BAG delivers with a polygon has a point inside that polygon (`centroid_or_mid`); the snapshot used the centroid, which could lie outside a concave polygon;
- a coordinate further than 2.147 km from the origin does not fit in millimetres as `int32`; such a pand gets an empty polygon and such a vbo no point (108 pand voorkomens and 108 vbo voorkomens in the extract of 2026-10-08, data errors far outside the country, which a snapshot drops anyway); `overzicht.txt` counts them;
- pand, vbo and nummeraanduiding are one store each; the file sets `fs_<n>.mmd` and `nr_stores.csv` are gone;
- the snapshot chooses, per object, the voorkomen with the highest voorkomenidentificatie among those valid on the date, for every attribute; it used to take the last one in file order for some attributes.

On the extract of 2026-10-08 the new stores hold the same voorkomens, statuses, dates, relations and attributes as the previous format (checked voorkomen by voorkomen), and a snapshot for 2026-10-01 has the same 11.3 million panden, 9.6 million vbo's and 10.1 million nummeraanduidingen with the same chosen voorkomens, statuses, dates and relations. The differences are the simplified pand polygons (14% fewer points; 116.660 of the 24.7 million pand voorkomens in the stores and 37.914 of the panden in the snapshot change area by more than 1 m², at most 37 m² for a real pand), 194 panden whose woonpand type changes with it, and the point of 11 vbo's with a polygon, which moves up to 11 m to a point inside the polygon.

## documentation

The [wiki](https://github.com/ObjectVision/BAG-Tools/wiki) describes each tool, its options and its results:
[Xml2MMD](https://github.com/ObjectVision/BAG-Tools/wiki/BAG20-Xml2MMD),
[MakeSnapshot](https://github.com/ObjectVision/BAG-Tools/wiki/BAG20-MakeSnapshot) and [how to use it](https://github.com/ObjectVision/BAG-Tools/wiki/How-to-use-the-MakeSnapshot-Script),
[GeoCode](https://github.com/ObjectVision/BAG-Tools/wiki/GeoCode) with [how to use it](https://github.com/ObjectVision/BAG-Tools/wiki/How-to-use-the-geocode-script) and [how to read its results](https://github.com/ObjectVision/BAG-Tools/wiki/How-to-interpret-the-GeoCode-results),
and the [woonpand typering](https://github.com/ObjectVision/BAG-Tools/wiki/Woonpand-typering).

Questions and problems go in the [issues](https://github.com/ObjectVision/BAG-Tools/issues).

## license

The BAG Toolkit is available under the [GNU GPL version 3](http://www.gnu.org/licenses/gpl-3.0.html). It is developed and maintained by [Object Vision](https://www.objectvision.nl).
