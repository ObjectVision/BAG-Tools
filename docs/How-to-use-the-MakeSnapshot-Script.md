This page describes how to use the MakeSnapshot.dms script to make a [[BAG20 MakeSnapshot]].

## date configuration

Make sure your _%SourceDataDir%_/BAG/BAG\__date_\_History folder contains an .mmd store for each BAG object type, resulting from [[BAG20 Xml2MMD]].

Then configure the code lines (in the top of the MakeSnapshot.dms scriptfile):

<pre>parameter&lt;string&gt; BAG_Date            := '<I>20261008</I>';
parameter&lt;string&gt; Snapshot_Date_Input := '<I>20261001</I>';</pre>

Adapt the **BAG_Date** to the date for the downloaded BAG source, also configured as date in the [[BAG20 Xml2MMD]] script.
The source MMD stores for making the snapshot will now be read from the StoreDir, configured as:  <BR><I>'%BAG_DIR%/BAG_' + BAG_Date + '_History'</I>;<BR> `BAG_DIR` is an overridable setting with default `%SourceDataDir%/BAG`; if the results of [[BAG20 Xml2MMD]] are saved in another folder, set it on the command line as the environment variable `GEODMS_Overridable_BAG_DIR` or in the GeoDMS GUI under Tools > Options. The snapshot is written next to it, in `BAG_<BAG_Date>_Snapshot_<Snapshot_Date>`.

The **Snapshot_Date_Input** defines for which date the snapshot is made. Always chose a date before the BAG_Date.

For both parameters use the _yyyymmdd_ format. In this example the BAG data was downloaded at the 8th of October 2026 from which a snapshot is made for the 1th of October 2026. 

After opening the MakeSnapshot.dms script in the GeoDMS GUI, the _snapshots_ folder contains a set of examples for generating a snapshot, with different options. A template _Snapshot_T_ is configured for each example with as first parameter always the date for which the snapshot is made.  

The other parameters define the snapshot options, described in the next paragraphs.

## polygon engine (GEO_ENGINE)

The woonpandtypering (vrijstaand, twee onder 1 kap, hoekwoning, tussenwoning) counts the neighbours of a pand by inflating the pand geometries a little and pairing the ones that then overlap. Which family of polygon operators does that is set by **GEO_ENGINE**, a `ConfigSettings/Overridable` setting of the configuration:

- `geos` (default): `geos_buffer_multi_polygon` and `geos_polygon_connectivity`;
- `dms` (GeoDMS 20.20.0 or later): `dms_minkowski_sum` with an octagonal kernel and `dms_polygon_connectivity`, GeoDMS's own sweep, which accepts polygons that are not valid.

It is given on the command line through the environment variable `GEODMS_Overridable_GEO_ENGINE=dms`, or in the GeoDMS GUI under Tools > Options. The default is `geos`. The simplification of the pand geometries stays a geos operation under both settings, since the dms family has no simplify.

## snapshot options configuration

The following options need to be configured for a snapshot.

### geographic selection (second parameter)

If the second parameter is configured to _False_, the snapshot is generated for the whole of the Netherlands. 

To configure a geographic selection, set this second to _True_. 

<details><summary> A geographic selection can be configured in two ways:</summary>

1. Define a rectangle (the default; all vbo's and related objects within the rectangle are selected): set the parameters _X_min_, _X_max_, _Y_min_ and _Y_max_ in the container `geo_selectie/pointset` of `cfg/MakeSnapshot.dms` to the requested extent, in RD metres.

2. Use an ESRI polygon shapefile: replace the declaration of `geo_selectie` in `cfg/MakeSnapshot.dms` by a unit that reads the shapefile, for example:

```
unit<uint32> geo_selectie
:	StorageName     = "%ProjDir%/data/geo_sel.shp"
,	StorageType     = "gdal.vect"
,	StorageReadOnly = "True"
{
	parameter<string>        Label := 'BredaEO';
	attribute<Geography/rdc> geometry (poly);
}
```

In both cases we advice to configure the _Label_ parameter to a clear name of your selected area. This label will become a subfolder in the resulting snapshot folder 
</details>

### status selection (third parameter)

The BAG contains (meta) information on the states of objects. Selections can be made on the states, for instance to exclude buildings still under construction.

If the third parameter is configured as _False_, the snapshot is generated for all states of all objects. To configure a snapshot
 with state selections, set this third parameter to _True_.

The states selections can be viewed and or adapted with the data items: **Classifications/status/_objecttype_/selected**, e.g. _Classifications/status/pand/selected_ to select the states for panden, in `cfg/Classifications.dms`.

The default selection states are derived from the Vesta project (October 2018).

### filter strange values, expected data errors (fourth parameter)

Although the quality of the BAG increases, still data errors do occur. In the snapshot you can choose to filter out 'strange values', probable data errors. This is advised in most cases, unless you want to use the snapshot for solving data errors in the BAG.

Configure this parameter to _True_ to filter the probable data errors and _False_ to keep the probable errors in the snapshot.

<details><summary>The current version of the filtering, filters on tree aspects:</summary>

1. The area of panden should be smaller than 10.0000.000 square meters, such large panden are unlikely and cause problems in deriving the woonpand_type attribute.
2. The length and width of the panden should be smaller than 5000 meters, such panden are also unlikely.
3. The centroid of the panden should be located in the Netherlands.

Other filters can be added. </details>

### height information (fifth parameter)

Information on the height of panden can be added to the snapshot. Configure the fourth argument to _True_ if height information is desired and to _False_ if not so.

The height information is derived from the PHN (Pand Hoogtes Nederland) database, which is derived from the AHN.

See [requirements for PHN](https://github.com/ObjectVision/BAG-Tools/wiki#requirements) before making a snapshot with height information. 

### format (sixth parameter)

The sixth parameter indicates the format of the resulting snapshot. The current version of this scripts supports two options:
1. MMD: generates all resulting data as one .mmd store, `bag.mmd`. This is advised if the resulting data is used in other GeoDMS projects.
2. GPKG: generates one GeoPackage file with tables for all BAG objecttypes, including code tables to limit the data size and make selections easier. The 
GPKG is advised if the resulting snapshot also is used in other software, like QGIS. 

Configure the format parameter to _MMD_ or _GPKG_.  

## generating a snapshot

As mentioned, the _snapshots_ folder contains a set of examples for generating a snapshot. 
Select one of these options, adapt it if necessary or make a copy with your requested options and give it a unique name. 

After selection a snapshot example or configuring your own, open this container in the GeoDMS GUI, e.g. the item: _snapshots/nl_status_sel_with_strangevalues_no_height_mmd_ 

To generate the snapshot double click one of the following items :

- _MaakVolledigeSnapshot_: generates a full snapshot with all objecttypes from the BAG in the configured format (MMD, GPKG).
- _MaakAlleenAdressenTabel_: generates only the addresses table (used for [[geocoding|GeoCode]]) (MMD format only).

Especially the _MaakVolledigeSnapshot_ option can take some time.

## result
The resulting snapshot becomes the folder _%SourceDataDir%_/BAG/BAG\__BAG_Date_\_Snapshot\__Snapshot_Date_, or BAG\__BAG_Date_\_Snapshot\__Snapshot_Date_\__Label_ for a geographic selection, where _Label_ is the label of the selection.
This contains the store `bag.mmd` (and `pandhoogte.mmd` with height information); a GeoPackage export is written next to it as a file with the same name and the extension .gpkg.

