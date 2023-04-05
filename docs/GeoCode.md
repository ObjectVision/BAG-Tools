The GeoCode tool is part of the [[BAG Toolkit|Home]]

The tool is used to add point geometry information ([RD coordinates](https://nl.wikipedia.org/wiki/Rijksdriehoeksco%C3%B6rdinaten)) from the [[BAG]] to administrative addresses. There are many (on line) geocode services, our the tool is useful to:
- process csv files with (large numbers of) addresses
- get meta information on the address fields used for each geocoding.

The tool is developed in cooperation with the [Spinlab department of the VU](https://spinlab.vu.nl/), see also: [GeoDMS BAG-Geocoder](https://spinlab.vu.nl/support/tools/geodms-bag-geocoder).

## replacements

The geocode tool aims to match administrative addresses in a source file to addresses of the BAG on all or a subset of address fields. The tool starts with two preparatory steps:

1. First irrelevant characters preventing exact matches are removed, for example spaces in zip codes or single quotes in street names. Special characters like ë or á or replaced by their base characters (e and a). This is done both in the BAG addresses and in the addresses of the source file.
2. Next it replaces parts of the addresses in the source file, in order to get an exact match on addresses like _dorpstr._ and _dorpstraat_ or _1e Jan Steenstraat_ versus _eerste Jan Steenstraat_.

## geocoding process

The actual geocoding is a step wise process of confronting source addresses towards BAG addresses. In the default configuration the first confrontation is on all address fields.

For the source addresses with an exact match, the resulting XY and meta information is added. If there is no exact match, the process continues with the next geocode level, in which one or more address fields or skipped from the matching condition.

In the default configuration this process continues towards the level where there is only a match with the woonplaats. See for all levels the Geocode.dms configuration file item: *niveau/volgorde*.

Confronting source addresses towards the BAG on a subset of the address fields means confronting towards an aggregation of BAG addresses.

A match on only PC6 for instance means matching against around 450.000 PC6 records, aggregated from more than 9.000.000 addresses.

The count of the number of BAG addresses and the variance in X and Y direction are added as meta data for each source file record to the results.

## using script and interpreting results

- [[How to use the geocode script]]
- [[How to interpret the geocode results]]

## requirements/licensing/download

- See [[BAG Toolkit|Home]]