This page describes how to interpret the results of the Geocode.dms script to [[geocode|GeoCode]] addresses.

## results

The geocoding process will result in at least two files:
- The _resultaat.csv_ file contains the primary information for each source address.
- The _resultaat_meta.csv_ contains meta information per geocode level.

This [[page|How to use the geocode script]] describes how to use the geocode script.

## resultaat.csv

The resulting file: resultaat.csv will contain all the information of your source file with the following extra attributes:
- **niveau_code**: the level at which an exact match against the [[BAG]] was made. In the GeoDMS GUI you can view the levels with their description by double clicking on the item: Geocode > niveau. This will present a table with for each code which address fields are used in the matching (volgorde column). The niveau_code is a quality indicator for the result, a low code means a high quality geocoding result and vice versa. Based on your application you can decide up to which level you find the results acceptable. A value of -1 for this attribute indicates no match could be found for     this source address.
- **X,Y**: the primary result of the geocoding, a X and Y coordinate in [RD](https://nl.wikipedia.org/wiki/Rijksdriehoeksco%C3%B6rdinaten)\]. The attribute agg_type in the table mentioned for niveau_code indicates if X,Y coordinates of the aggregations of the BAG are calculated with the mean (agg_type is 0) or median (agg_type is 1) function.
- **count**: the number of addresses in the BAG used for your matching result. For matchings against all addresses fields in the BAG this number is always 1.
- **var**: the sum of the variances in X and Y direction for the addresses in the BAG used for your matching result. For matchings against all addresses fields in the BAG this variance is always 0. The variance can be used as quality indicator. A low variance of the XY points for the BAG addresses used in your matching indicates a better quality geocoding result.
- **nummeraanduiding_id, bag_postcode, bag_straatnaam, bag_huisnummer, bag_huisletter, bag_toevoeging, bag_woonplaatsnaam**: if the count is 1, the    BAG nummeraanduiding identification as well as the official bag address fields are added to your result file.

## resultaat_meta.csv

This meta file which is stored in the same folder as the resultaat.csv
file describes for each geocode level the:

- **code**: used as niveau_code in resultaat.csv
- **omschrijving**: on which address fields the match is made
- **aantal**: the number of records in your source file matched at this level
- **gemiddeld aantal adressen**: average number of BAG addresses used in the aggregation of this level
- **gemiddelde variantie**: average of the sum of the variance in X and Y direction of the BAG addresses used in the aggregation of this level
- **percentage**: the percentage of the records in your source file matched at this level
- **percentage cumulatief**: the cumulation of the percentages matched up to this level
- **aggregatie type**: the aggregation type how the X and Y coordinates are aggregated for this level