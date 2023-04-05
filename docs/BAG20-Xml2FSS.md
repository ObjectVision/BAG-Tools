The [[BAG]] 2.0 can be downloaded (monthly update) from the [Kadaster BAG 2.0 download page](https://www.kadaster.nl/-/kosteloze-download-bag-2.0-extract).

The download consists of a zip file with more than 3.000 xml files. Xml files are used as exchange formats but less suitable for processing.

Therefore the BAG20_Xml2FSS tool is used to convert these xml files to a [FSS](https://github.com/ObjectVision/GeoDMS/wiki/FSS) storage (GeoDMS native fast primary data format).

## FSS data structure

The BAG is a historical database with one or multiple mutations per object. The BAG20 Xml2FSS tool stores this historical information in a
FSS storage per BAG object type.

The data structure used is similar to the BAG, with one major exception. As the number of gebruiksdoelen of a VBO in the BAG is limited, the relation between VBO and gebruiksdoel is implemented as a set of boolean attributes for each VBO indicating if this VBO has this gebruiksdoel or not. This makes it easier to work with the gebruiksdoelen. The same data structure is also used in the [[BAG20 MakeSnapshot]].

## how to use this script

1. Download the .zip from <https://www.kadaster.nl/-/kosteloze-download-bag-2.0-extract>. Extract the zip file to zip files for each BAG object type. DO ONLY EXTRACT THE *LIG*, *NUM*, *OPR*, *PND*, *STA*, *VBO*, *WPL* ZIP FILES !
2. Extract the xml files from the zip files per BAG object type to a local folder, with naming convention: _%SourceDataDir%_/BAG20/_date_/NGR:
     - The _%SourceDataDir%_ is a [placeholder](https://github.com/ObjectVision/GeoDMS/wiki/Folders-and-Placeholders) for the SourceData folder on your local disk. By default the path: C:/SourceData is used. You can choose another path for your SourceData, but then you have to configure this new path in the [GeoDMS GUI](https://github.com/ObjectVision/GeoDMS/wiki/GeoDMS-GUI), menu option: Tools > Otions > Advanced Tab > SourceDataDir control.
     - Use for the _date_ placeholder the date of your download with as format: _yyyymmdd_.
     - The subfoldername NGR stands for: Nationaal GeoRegister.
3. Make sure all zip files are extracted (your NGR subfolder need to have more than 3.000 xml files).
4. Open the BAG20_Xml2FSS.dms file from the [[BAG Toolkit|Home]] scripts (in the cfg subfolder of your chosen project folder) in a text editor, configure the date of your download for the parameter _date_ (_yyyymmdd_) and save your file:
<pre>
// te configureren
parameter&lt;string&gt; date     := '<I>20230113</I>';
//
</pre>
5. Open the BAG20_Xml2FSS.dms in the GeoDMS and update the item: _MaakFSSBestanden_, e.g. by double clicking on this item in the TreeView. This can take some time.
6. The resulting FSS storages become folders in your _%SourceDataDir%/BAG20/date/FSS.new_ folder. Rename this FSS.new subfolder to FSS.

## requirements/licensing/download

- See [[BAG Toolkit|Home]]

## troubleshooting

If updating item: _MaakFSSBestanden_ results in an error, check:

1. if you have unzipped the earlier mentioned zip files, your NGR subfolder should contain more than 3.000 xml files.
2. if your _%SourceDataDir%_ placeholder refers to the actual physical path containing the subfolder (BAG20/_date_/NGR) with the xml files. If this is not the case, configure the path for your _%SourceDataDir%_ in the GeoDMS GUI: menu option: Tools > Otions > Advanced Tab > SourceDataDir control.

Ignore the error(s) and reload the configuration file.

## result

The result of this script is a collection of FSS storages (folders) for each BAG object type, which can be used to make snapshots from the BAG. Use the [[BAG20 MakeSnapshot]] tool for this purpose.

In the resulting FSS folder also meta information is stored in a file called: _overzicht.txt_. This files describes the number of xml files
processed and the number of objects for each BAG object type. The information can be used as an indicator to check if all data is used in the FSS files.