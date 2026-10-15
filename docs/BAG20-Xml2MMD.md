The [[BAG]] 2.0 can be downloaded (monthly update) from the [Kadaster BAG 2.0 download page](https://www.kadaster.nl/-/kosteloze-download-bag-2.0-extract).

The download consists of a zip file with more than 6.000 xml files. Xml files are used as exchange formats but less suitable for processing.

Therefore the Xml2MMD tool (until 2026 called BAG20_Xml2FSS, after the storage format it wrote then) is used to convert these xml files to one [MMD](https://github.com/ObjectVision/GeoDMS/wiki/MMD) storage per BAG object type (GeoDMS native fast primary data format, the successor to [FSS](https://github.com/ObjectVision/GeoDMS/wiki/FSS)). The stores hold every voorkomen of every object: the full history of the BAG, from which [[BAG20 MakeSnapshot]] derives the state at a date.

## MMD data structure

The BAG is a historical database with one or multiple voorkomens (mutations) per object. Xml2MMD stores this historical information in one MMD store per BAG object type: `ligplaats.mmd`, `standplaats.mmd`, `pand.mmd`, `vbo.mmd`, `nummeraanduiding.mmd`, `openbareruimte.mmd` and `woonplaats.mmd`. Each store describes itself: its dictionary declares every attribute and the code tables it uses, so a reader declares nothing but an empty storage holder and the coordinate unit (see [[BAG20 MakeSnapshot]] for an example).

The stores are compact:

- identificaties are stored as `uint64`, not as text. A BAG identificatie is a fixed number of digits (16 for the object types, 4 for a woonplaats), so the text form is recovered by padding the number with zeros on the left: `right('0000000000000000' + string(identificatie), 16)`;
- the status of a voorkomen is a code, `meta/status_rel`, into a label table `status` that travels in the store. The same holds for the `typeAdresseerbaarObject` of a nummeraanduiding and the `type` of an openbare ruimte. The code lists are in `cfg/Classifications.dms`; a value in the extract that is not in the list stops the conversion, so that a new value from Kadaster is noticed and added;
- the registration timestamps of a voorkomen, `TIJDSTIPREGISTRATIE` and `EINDREGISTRATIE`, are stored as the date, `yyyymmdd` as `int32`, like `BEGINDATUM` and `EINDDATUM`; 0 means absent;
- the geometry is in millimetres, as `ipoint` in the unit `/geometries/rdc_mm`. The BAG delivers three decimals, so this is lossless, and it takes half the space of `dpoint`. A reader converts it back to metres with `geometry[/geometries/rdc]`. A coordinate further than 2.147 km from the origin does not fit; such a pand gets an empty polygon and such a vbo no point (data errors far outside the country, 108 of each in the extract of 2026-10-08), and `overzicht.txt` counts them;
- the pand polygons are simplified with a tolerance of 0.1 m (Douglas-Peucker, the parameter `pand_simplify_tolerantie`): points that lie within 0.1 m of the line between their neighbours are dropped. A rectangular pand is unchanged; a pand with a curved facade of hundreds of points loses most of them; a polygon smaller than the tolerance, which the simplification would reduce to nothing, keeps its original shape. On the extract of 2026-10-08 this removed 14% of the points and changed the area of 116.660 of the 24.7 million voorkomens by more than 1 m², mostly in very large or erroneous geometries;
- a verblijfsobject always has a point geometry: its own point from the BAG, or, for the few thousand vbo's that the BAG delivers with a polygon instead, a point inside that polygon (`centroid_or_mid`). The polygons themselves are kept in the sub-table `vbo/polygon`;
- the relations of a vbo to its panden (`vbo/gerelateerdPand`) and its nevenadressen (`vbo/nevenadres`) carry `vbo_rel`, the row of the vbo voorkomen they belong to, next to the `pand_id` or `nummeraanduiding_id`.

As the number of gebruiksdoelen of a VBO in the BAG is limited, the relation between VBO and gebruiksdoel is implemented as a set of boolean attributes for each VBO indicating if this VBO has this gebruiksdoel or not. This makes it easier to work with the gebruiksdoelen. The same data structure is also used in the [[BAG20 MakeSnapshot]].

## how to use this script

1. Download the .zip from <https://www.kadaster.nl/-/kosteloze-download-bag-2.0-extract>. Extract the zip file to zip files for each BAG object type. DO ONLY EXTRACT THE *LIG*, *NUM*, *OPR*, *PND*, *STA*, *VBO*, *WPL* ZIP FILES !
2. Extract the xml files from the zip files per BAG object type to a local folder, with naming convention: _%SourceDataDir%_/BAG/_date_/NGR:
     - The _%SourceDataDir%_ is a [placeholder](https://github.com/ObjectVision/GeoDMS/wiki/Folders-and-Placeholders) for the SourceData folder on your local disk. By default the path: C:/SourceData is used. You can choose another path for your SourceData, but then you have to configure this new path in the [GeoDMS GUI](https://github.com/ObjectVision/GeoDMS/wiki/GeoDMS-GUI), menu option: Tools > Options > Advanced Tab > SourceDataDir control. The BAG folder itself can be set with the overridable setting `BAG_DIR` (default `%SourceDataDir%/BAG`), on the command line as the environment variable `GEODMS_Overridable_BAG_DIR`.
     - Use for the _date_ placeholder the date of your download with as format: _yyyymmdd_.
     - The subfoldername NGR stands for: Nationaal GeoRegister.
3. Make sure all zip files are extracted (your NGR subfolder need to have more than 6.000 xml files).
4. Open the Xml2MMD.dms file from the [[BAG Toolkit|Home]] scripts (in the cfg subfolder of your chosen project folder) in a text editor, configure the date of your download for the parameter _date_ (_yyyymmdd_) in the container _Parameters_ and save your file:
<pre>
parameter&lt;string&gt; date     := '<I>20261008</I>';
</pre>
5. Run `bat\RunXml2MMD.bat`, or open the Xml2MMD.dms in the GeoDMS GUI and update, one after the other, the items _MaakTussenstores_ and _MaakMMDBestanden_. The first step parses the pand, vbo and nummeraanduiding files per file set of 50 files into intermediate stores in _%LocalDataProjDir%/Temp/date_; the second step reads those back, merges them into one store per object type and converts the other object types. Reopen the configuration between the two steps: the second step reads the intermediate stores when the configuration is loaded. The two steps are separate because a process that does both keeps every file set in memory until the merged store is written (75 GB measured against 35 GB).
6. The resulting MMD storages become folders in your _%SourceDataDir%/BAG/date/mmd_ folder. The intermediate stores in _%LocalDataProjDir%/Temp/date_ can be deleted afterwards; if they are kept, a later run of the first step for the same date does nothing.

## polygon engine (GEO_ENGINE)

The pand geometries are dissolved per pand with a polygon union. Which family of polygon operators does that is set by **GEO_ENGINE**, a `ConfigSettings/Overridable` setting of the configuration:

- `geos` (default): the [geos_](https://github.com/ObjectVision/GeoDMS/wiki/Geos) operators, which need valid polygons and repair them first;
- `dms` (GeoDMS 20.20.0 or later): the [dms_](https://github.com/ObjectVision/GeoDMS/wiki/dms-polygon-operators) operators, GeoDMS's own sweep, which read every ring under the even-odd rule and so need no repair of rings stored the wrong way round.

Like every overridable setting it is given on the command line through an environment variable, `GEODMS_Overridable_GEO_ENGINE=dms`, or in the GeoDMS GUI under Tools > Options. The batch file `bat/RunXml2MMD.bat` takes it as an argument: `RunXml2MMD.bat GEO_ENGINE=dms`. The batch file runs each of the two steps in a GeoDmsRun process under a memory budget, `MEM_BUDGET_MB=8000` by default (GeoDmsRun's `/SB<MB>`): GeoDMS processes the file sets of an object type side by side up to that budget and releases each file set's memory once its intermediate store is written. The peak memory runs above the budget, because the budget estimates the work in flight rather than measuring it. `PER_FILESET=1` runs every file set in a process of its own, for a hard bound of one file set, and then one process for the second step. The simplification of the pand geometries is a boost geometry operation under both engines. The configuration itself requires GeoDMS 20.23.1 or later: its root container carries the IntegrityCheck `GeoDMSVersion() >= 20.23`, so an older GeoDMS refuses it before anything is read.

## requirements/licensing/download

- See [[BAG Toolkit|Home]]

## troubleshooting

If updating item: _MaakTussenstores_ or _MaakMMDBestanden_ results in an error, check:

1. if you have unzipped the earlier mentioned zip files, your NGR subfolder should contain more than 6.000 xml files.
2. if your _%SourceDataDir%_ placeholder refers to the actual physical path containing the subfolder (BAG/_date_/NGR) with the xml files. If this is not the case, configure the path for your _%SourceDataDir%_ in the GeoDMS GUI: menu option: Tools > Options > Advanced Tab > SourceDataDir control.
3. if _MaakMMDBestanden_ cannot find the intermediate stores: run _MaakTussenstores_ first, and reopen the configuration afterwards.
4. if the conversion stops on an IntegrityCheck of a store: the extract contains a status or type that is not in `cfg/Classifications.dms`; add it to the list.

Ignore the error(s) and reload the configuration file.

## result

The result of this script is a collection of MMD storages (folders) for each BAG object type, which can be used to make snapshots from the BAG. Use the [[BAG20 MakeSnapshot]] tool for this purpose, or read the stores directly for an analysis over the history of the BAG.

In the resulting mmd folder also meta information is stored in a file called: _overzicht.txt_. This files describes the number of xml files processed and the number of voorkomens for each BAG object type. The information can be used as an indicator to check if all data is used in the MMD storages.
