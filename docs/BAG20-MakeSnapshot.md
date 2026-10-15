After processing the [[BAG (Dutch)|BAG]] data to [MMD](https://github.com/ObjectVision/GeoDMS/wiki/MMD) format with [[BAG20 Xml2MMD]], you can start making snapshots. 

MakeSnapshot is part of the [[BAG Toolkit|Home]]

A snapshot is defined as a **state of the BAG at a specific date**, in which the identifiers of each BAG object can be used as primary keys.

Snapshots can also made for: 
- the whole of the Netherlands, or a specific geographic extent
- all or a selection of states per BAG object type.
- with or without 'stange values' (probably data errors)

Snapshots can be made in the following formats:
- [MMD](https://github.com/ObjectVision/GeoDMS/wiki/MMD): advised if the resulting data is used in other GeoDMS projects. The whole snapshot is one store, `bag.mmd`.
- [GeoPackage](https://github.com/ObjectVision/GeoDMS/wiki/Geopackage): advised if the resulting data is used to work with also in other tools like QGIS. [[GeoParaat]] is an example of snapshots made available in GeoPackage format.  

## date selection

To select the snapshot of the BAG for a specific date, we use the following selection criteria:
- The snapshot date must be **the same or later than the BEGINDATUM** field of each voorkomen
- The snapshot date must be **before the EINDDATUM** of each voorkomen or the EINDDATUM field is empty.

Due to errors in the BAG the identifiers in the resulting entities of this selection process are still not always unique. Therefore we use a [unique](https://github.com/ObjectVision/GeoDMS/wiki/Unique) function (group by) on these identifiers to force this condition, and per object the voorkomen with the highest voorkomenidentificatie among the selected ones is the one in the snapshot.

## the snapshot store

In `bag.mmd` the references between object types are relations, not identifier strings: `vbo/pand_rel`, `vbo/nummeraanduiding_rel`, `nummeraanduiding/openbareruimte_rel`, and so on. Identificaties are `uint64`, as in the stores of [[BAG20 Xml2MMD]]. Statuses, the type of a nummeraanduiding, the type of an openbare ruimte and the [[woonpand_type]] are codes into label tables that travel in the store (`status_pand`, `typeAdresseerbaarObject`, `type_openbareruimte`, `type_woonpand`). The registration timestamps are dates, `yyyymmdd`. The geometry is in metres (`dpoint`, the unit `/geometries/rdc`), so a reader can calculate with it directly; a vbo has a point geometry, for a vbo that the BAG delivers with a polygon a point inside that polygon.

## derived entities and attributes

In a full snapshot the following additional information is calculated and added to the snapshot result:

1. **[[woonpand_type]]**: This attribute is added for each pand in the BAG. Based on the geometry of neighboring _panden_ and the number of related residential verblijfsobjecten, a type is derived.
2. **address fields on nummeraanduiding**: every nummeraanduiding gets a point geometry and the street and place name that belong to it. These geometries are mainly derived from the verblijfsobject point geometries, for ligplaatsen and standplaatsen the centroid is used.

Optional, if the height information parameter is set to True (see [[How to use the MakeSnapshot Script]]), a second store `pandhoogte.mmd`, row by row aligned with `bag.mmd/pand`, adds two attributes for each pand in the snapshot:

1. AHN_hoogte: an uint16 attribute with the height of the pand in cm, based on the 70th percentile of all AHN observations in the pand polygon.
2. AHN_inwinjaar: an uint16 attribute with the year the used AHN observations for the pand were collected. For panden with a bouwjaar later than the the inwinjaar, we advice not to use the AHN_hoogte.

## how to use the script

- [[How to use the MakeSnapshot Script]]

## requirements/licensing/download

- See [[BAG Toolkit|Home]]

## troubleshooting

If updating item: MaakVolledigeSnapshot or MaakAlleenAdressenTabel results in an error, check if:

1. your _%SourceDataDir%_/BAG/_date_/mmd folder contains an .mmd store for each BAG object type (don't forget step 6 of the [[BAG20 Xml2MMD]] process).
2. your _%SourceDataDir%_/PHN folder contains a PHN_<I>date</I>.fss folder with 7 files, see also [requirements](https://github.com/ObjectVision/BAG-Tools/wiki#requirements).

After solving, ignore the error(s) and reload the configuration file.

## result

Based on the chosen item, you will get a full snapshot of all BAG object types with additional attributes /entities or only an address table for a specific date and optionally extent and states.

Both date and extent become subfoldernames of the resulting MMD stores. The address table can be used for geocoding, for instance with [[this script|GeoCode]].
 
The full snapshot can also be used for many applications that need a snapshot of the BAG.

In the resulting snapshot folder also meta information is stored in a file called: *overzicht.txt*.
This file describes the number of objects selected for each BAG object type and some possible errors/strange values.
