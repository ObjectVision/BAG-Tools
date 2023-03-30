This page describes how to use the Geocode.dms script to [[geocode|GeoCode]] addresses.

## steps

1. Make sure you generated and adres.fss subfolder with the [[BAG20 MakeSnapshot]] script.

2. Configure the **snapshot date**. Open the _BAG.dms_ script file (in the cfg/Geocode subfolder of the [download](https://github.com/ObjectVision/BAG-Tools) in a text editor. Adjust the configuration of the item: *BAG/impl/SnapshotDir*

<pre>
parameter&lt;string&gt; SnapshotDir := '%SourceDataDir%/BAG20/snapshots.ext/<I>20220701</I>';
</pre>

with the you date made the snapshot for with the MakeSnapshot tool of, using the format _yyyymmdd_.

3. Configure the **source file** with the addresses to be geocoded. Open the _bron.dms_ file (in the cfg/Geocode subfolder of your download) in a text editor. Configure the item *bron/BestandsNaam*:

<pre>
parameter&lt;string&gt; BestandsNaam := '%SourceDataDir%/adres/to_be_geocoded.csv';
</pre>

to the path and filename of your source file to be geocoded.

The source file needs to be a .csv text file with a header describing the address fields (see 4). The default expected delimiter for the csv
file is the semicolon (;) , a comma(,) can also be used, in that case configure ';' for the item: *bron/TableChopper/VeldScheidingsTeken.* in the same _bron.dms_ file.

4. Adjust the **address field names** if necessary. By default the Geocode tool assumes the following names for the address fields:

- **straat**: for straatnames (straatnaam)
- **huisnr**: for house numbers (huisnummer)
- **huisnr_toev**: for the combination of letter (huisletter) and addition (toevoeging)
- **plaats**: for place (woonplaats)
- **postcode**: for zipcode (postcode)

We advice to adjust the header of your source .csv file to use these names for the address fields. See special cases 1 if you want/need to adjust the names of these fields in the code. 

Save the changes you made in the configuration/source files.

5. Double click the item: _export/bestand_ to **geocode the addresses** and make the result file.

This will start the geocoding process and result in your source file extended with the XY coordinates and a set or meta information attributes.

The result is stored in the file: _%LocalDataProjDir%_/resultaat.csv (default C:/LocalData/BAG/Geocode/resultaat.csv), see 
[Folders-and-Placeholders](https://github.com/ObjectVision/GeoDMS/wiki/Folders-and-Placeholders).

This [[page|How to interpret the GeoCode results]] describes how to interpret the geocoding results.

## special cases

### 1. adjust address field names in code

If you need to adjust the address fields in the code, find the following configuration lines in _bron.dms_ file (in the cfg/Geocode subfolder of your download)

<pre>
container postcode_org := Templates/uniformeer_string(TableChopper/Domein, substr(Data/<B><I>postcode</B></I>, 0, 6));
...
container straatnaam   :=
   Templates/uniformeer_string_straatnaam(TableChopper/Domein, <B><I>string(TableChopper/straatnaam)</B></I>));
   //Templates/uniformeer_string_straatnaam(TableChopper/Domein, adres_splitsen/straatnaam);

container huisnummer     :=
   Templates/uniformeer_string(TableChopper/Domein, string(TableChopper/<B><I>huisnummer)</B></I>));
   //Templates/uniformeer_string_straatnaam(TableChopper/Domein, adres_splitsen/huisnummer</B></I>);

container huistoevoeging :=  Templates/uniformeer_string(TableChopper/Domein, string(TableChopper/<B><I>huistoev)</B></I>));
   //Templates/uniformeer_string(TableChopper/Domein, TableChopper/data/HUISLETTER);
   //Templates/uniformeer_string(TableChopper/Domein, adres_splitsen/huistoevoeging);

container woonplaatsnaam := Templates/uniformeer_string(TableChopper/Domein, <B><I>string(TableChopper/woonplaats)</B></I>);
</pre>

In these configuration rules, you can define which address fields names are used in your source file. Adjust the bold italic values with the names of the address fields in your source file.

### 2. missing address fields

The geocode tool assumes the address fields are present in your source file. 
If e.g. your sourcefile does not contain a huisletter/toevoeging field, adjust the code:

<pre>
container huistoevoeging := Templates/uniformeer_string(TableChopper/Domein, TableChopper/data/toev);

to

container huistoevoeging
{
   attribute&lt;string&gt; resultaat (TableChopper/Domein) := const('', TableChopper/Domein);
}
</pre>

The const function results in an array with empty strings for the domain unit of the source file.

### 3. streetnames, housenumbers, houseletters and additions in one field

In some source files streetnames/numbers and additions are combined in one field.

With the tool you can split up such a composite field into it's components (for a small number of complex addresses this might not always result in correct values).

The code to split up such a composite field is already available in bron.dms, but default in comment.

To split up an address field with the name adres into it's street/housenumber/toevoeging, comment the current expression of the
containers: _straatnaam_, _huisnummer_ and/or _huistoevoeging _in _bron.dms_ and uncomment the by default commented expressions for these containers.

If the name of your composite field is not adres, we advice to adjust this in the header of your source file. 
If you can not adjust this, you can also edit the code line:

<pre>
container adres_splitsen
{
  ...
  attribute&lt;string&gt; adres (TableChopper/Domein):= <B>TableChopper/Data/adres</B>;
}
</pre>

and adjust the bold label adres into the name of your composite field.

## troubleshooting

If updating the item: *Export/bestand* results in an error, check if:

1. your %SourceDataDir%/BAG/snapshots.ext/date folder contains an adres.fss subfolder (result of the [MakeSnapshot](MakeSnapshot "wikilink") process).
2. the item *TeGeocoderen/bron/TableChopper/BestandsNaam* refers to your source file.
3. your source file is a valid csv file with a comma or semicolon delimiter. This delimiter need to be specified for the item:
_TeGeocoderen/bron/TableChopper/VeldScheidingsTeken_
4. your source address field names correspond with the names used in the code. If you open item: TeGeocoderen/bron you should see no red items.