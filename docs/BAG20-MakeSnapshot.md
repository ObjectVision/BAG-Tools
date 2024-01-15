After processing the [[BAG (Dutch)|BAG]] data to [FSS](https://github.com/ObjectVision/GeoDMS/wiki/FSS) format with the [[BAG20 Xml2FSS]], you can start making snapshots. 

The BAG20 Xml2FSS is part of the [[BAG Toolkit|Home]]

A snapshot is defined as a **state of the BAG at a specific date**, in which the identifiers of each BAG object can be used as primary keys.

Snapshots can also made for: 
- the whole of the Netherlands, or a specific geographic extent
- all or a selection of states per BAG object type.
- with or without 'stange values' (probably data errors)

Snapshots can be made in the following formats:
- [FSS](https://github.com/ObjectVision/GeoDMS/wiki/FSS): advised if the resulting data is used in other GeoDMS projects.
- [GeoPackage](https://github.com/ObjectVision/GeoDMS/wiki/Geopackage): advised if the resulting data is used to work with also in other tools like QGIS. [[GeoParaat]] is an example of snapshots made available in GeoPackage format.  

## date selection

To select the snapshot of the BAG for a specific date, we use the following selection criteria:
- The snapshot date must be **the same or later than the BEGINDATUM** field of each BAG object
- The snapshot date must be **before the EINDDATUM** of each BAG object field or the EINDDATUM field is empty.

Due to errors in the BAG the identifiers in the resulting entities of this selection process are still not always unique. Therefore we use a [unique](https://github.com/ObjectVision/GeoDMS/wiki/Unique) function (group by) on these identifiers to force this condition.

## derived entities and attributes

In a full snapshot the following additional information is calculated and added to the snapshot result:

1. **[[woonpand_type]]**: This attribute is added for each pand in the BAG. Based on the geometry of neighboring _panden_ and the number of related residential verblijfsobjecten, a type is derived.
2. **adres**: a new table, based on the _nummeraanduidingen_ with all address fields and a point geometry for each address. These geometries are mainly derived from the verblijfsobject point geometries, for ligplaatsen/standplaatsen and verblijfsobjecten with polygon geometries, the centroid is used.

Optional, if the height information parameter is set to True (see [[How to use the MakeSnapshot Script]]), two additional attributes are added for each pand in the snapshot:

1. AHN_hoogte: an uint16 attribute with the height of the pand in cm, based on the 70th percentile of all AHN 3 observations in the pand polygon.
2. AHN_inwinjaar: an uint16 attribute with the year the used AHN 3 observations for the pand were collected. For panden with a bouwjaar later than the the inwinjaar, we advice not to use the AHN_hoogte.

## how to use the script

- [[How to use the MakeSnapshot Script]]

## requirements/licensing/download

- See [[BAG Toolkit|Home]]

## troubleshooting

If updating item: MaakVolledigeSnapshot or MaakAdressenTabe results in an error, check if:

1. your _%SourceDataDir%_/BAG20/_date_/FSS folder contains FSS folders for each BAG object type (don't forget step 6 of the [[BAG20 Xml2FSS]] process).
2. your _%SourceDataDir%_/PHN folder contains a PHN_<I>date</I>.fss folder with 7 files, see also [requirements](https://github.com/ObjectVision/BAG-Tools/wiki#requirements).

After solving, ignore the error(s) and reload the configuration file.

## result

Based on the chosen item, you will get a full snapshot of all BAG object types with additional attributes /entities or only an address table for a specific date and optionally extent and states.

Both date and extent become subfoldernames of the resulting FSS files. The address table can be used for geocoding, for instance with [[this script|GeoCode]].
 
The full snapshot can also be used for many applications that need a snapshot of the BAG.

In the resulting snapshot folder also meta information is stored in a file called: *overzicht.txt*.
This file describes the number of objects selected for each BAG object type and some possible errors/strange values.