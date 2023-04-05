Based on the geometry of neighboring _panden_ and the number of related residential verblijfsobjecten, a type is derived, called the woonpand_type. 

An example can be viewed at a [residential web mapping application](https://kl.wzwkaart.nl/app/map/1?zoom=10&center=104873,488856&layerIds=11003,31000,21002).

The woonpand_type is calculated in the [[BAG20 MakeSnapshot]] process.

## types

The resulting housing types (woonpand types) are:

- **detached**: building with one residential object with a residential function and no adjacent buildings with a residential function.
- **semi-detached house**: building with one accommodation object with a residential function and one adjoining building with a residential function, which only adjoins 1 building with a residential function.
- **corner house**: building with one accommodation object with a residential function and one adjoining building with a residential function, which adjoins several buildings with a residential function.
- **terraced house**: building with one residential object with a residential function and at least two adjoining buildings with a residential function.
- **multi-family building**: several accommodation units with a residential function are situated in the building.

A selection of buildings has been made that contain at least one accommodation object.

## calculation method

The calculation of the housing type (woonpand type) is based on:
- the geometry of the panden and how they border to other panden
- the number of verblijfsobjecten in the panden.

The calculation method can be found in the [afleidingen.dms](https://github.com/ObjectVision/BAG-Tools/blob/main/cfg/BAG20_MakeSnaphot/MakeSnapshot/afleidingen.dms) script file.