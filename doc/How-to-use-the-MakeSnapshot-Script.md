This page describes how to use the BAG20_MakeSnaphot.dms script to make a [[BAG20 MakeSnapshot]].

## date configuration

Make sure your _%SourceDataDir%_/BAG/_date_/FSS folder contains FSS folders for each BAG object type, resulting from [[BAG20 Xml2FSS]].

Then configure the code lines (in the top of the BAG20_MakeSnapshot.dms scriptfile):

<pre>// te configureren
parameter&lt;string&gt; BAG_Date            := '<I>20230113</I>';
parameter&lt;string&gt; Snapshot_Date_Input := '<I>20230101</I>';
//</pre>

Adapt the **BAG_Date** to the date for the downloaded BAG source, also configured as date in the [[BAG20 Xml2FSS]] script.
The source FSS files for making the snapshot will now be read from the FSSDir, configured as:  <BR><I>'%SourceDataDir%/BAG20/' + BAG_Date + '/fss'</I>;<BR> If the results of [[BAG20 Xml2FSS]] are saved in another folder, adjust also the FSSDir.

The **Snapshot_Date_Input** defines for which date the snapshot is made. Always chose a date before the BAG_Date.

For both parameters use the _yyyymmdd_ format. In this example the BAG data was downloaded at the 13th of January 2023 from which a snapshot is made for the 1th of January 2023. 

After opening the BAG20_MakeSnaphot.dms script in the GeoDMS GUI, the _snapshots_ folder contains a set of examples for generating a snapshot, with different options. A template _MakeSnapshot_ is configured for each example with as first parameter always the date for which the snapshot is made.  

The other parameters define the snapshot options, described in the next paragraphs.

## snapshot options configuration

The following options need to be configured for a snapshot.

### geographic selection (second parameter)

If the second parameter is configured to _False_, the snapshot is generated for the whole of the Netherlands. 

To configure a geographic selection, set this second to _True_. 

<details><summary> A geographic selection can be configured in two ways:</summary>

1. Use an ESRI polygon shapefile: <BR>The easiest way is to replace the file _./data/geo_sel.shp_ in your project folder with the ESRI polygon shapefile you want to use for the selection. If you want to keep this file at another location, you can also adjust the StorageName configured for the _geo_selectie_ item to refer to this location.      

2. Define a rectangle (all vbo's and related objects within the rectangle will be selected): <BR>
By default this ways of selecting is in comments and not active. First uncomment the codeblock starting with _nrofrows = 1_ till the comment: 
_// Voorbeeld voor het lezen van een geo_selectie uit een shape file_ <BR>  
And comment the codeblock starting with <I>:	StorageName     = "%ProjDir%/data/geo_sel.shp"</I> till <I>container typeringen</I>.   

Next set the The _x_min_, _x_max_, _y_min _and _y_max_ parameters for the requested extent in the container: geo_selectie/pointset.
These parameters now describe the selection rectangle to be used.

In both cases we advice to configure the _Label_ parameter to a clear name of your selected area. This label will become a subfolder in the resulting snapshot folder 
</details>

### status selection (third parameter)

The BAG contains (meta) information on the states of objects. Selections can be made on the states, for instance to exclude buildings still under construction.

If the third parameter is configured as _False_, the snapshot is generated for all states of all objects. To configure a snapshot
 with state selections, set this third parameter to _True_.

The states selections can be viewed and or adapted with the data items: **typeringen/status/_objecttype_/selected**, e.g. _typeringen/status/pand/selected_ to select the states for panden.

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
1. FSS: generates all resulting data as a set of FSS folders. This is advised if the resulting data is used in other GeoDMS projects.
2. GPKG: generates one GeoPackage file with tables for all BAG objecttypes, including code tables to limit the data size and make selections easier. The 
GPKG is advised if the resulting snapshot also is used in other software, like QGIS. 

Configure the format parameter to _FSS_ or _GPKG_.  

## generating a snapshot

As mentioned, the _snapshots_ folder contains a set of examples for generating a snapshot. 
Select one of these options, adapt it if necessary or make a copy with your requested options and give it a unique name. 

After selection a snapshot example or configuring your own, open this container in the GeoDMS GUI, e.g. the item: _snapshots/nl_status_sel_with_strangevalues_no_height_fss_ 

To generate the snapshot double click one of the following items :

- _MaakVolledigeSnapshot_: generates a full snapshot with all objecttypes from the BAG in the configured format (FSS, GPKG).
- _MaakAlleenFSSAdressenTabel_: generates only the addresses table (used for [[geocoding|GeoCode]]) (FSS format only).

Especially the _MaakVolledigeSnapshot_ option can take some time.

## result
The resulting snapshot becomes a folder in your _%SourceDataDir%_/BAG/snapshots.ext/_optional_geo_selection_name_/_date_.new folder.
This can contain a set of FSS folders (with .dmsdata files) or the GPKG file.

We advice to rename the resulting folder to a _%SourceDataDir%_/BAG20/snapshots.ext/_optional_geo_selection_name_/_date_ folder 