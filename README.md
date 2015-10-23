#### THREDDS Crawler


#### Requirements

[R >= 3.0](http://cran.r-project.org)

[httr](http://cran.r-project.org/web/packages/httr/index.html)

[XML](http://cran.r-project.org/web/packages/XML/index.html)

#### Installation

It is easy to install with [devtools](https://cran.r-project.org/web/packages/devtools/index.html)

```R
library(devtools)
install_github("btupper/threddscrawler")
```

#### Classes

`TopCatalogRefClass` for catalogs that are containers of `CatalogRefClass` pointers.  This is like a listing of files and subdirectories in a directory, but here the files and subdirectories are all `CatalogRefClass` pointers. 

`CatalogRefClass` is a pointer to `TopCatalogRefClass`  
 
THREDDS `dataset` comes in two flavors: collections of datasets and direct datasets.  I split these into  `DatasetsRefClass` (collections) and `DatasetRefClass` (direct); the latter has an 'access' child node the former does not.  A collection is a listing of one or more datasets (either direct or catalogs).  A direct dataset is a pointer to an actual resource like a NetCDF file.

#### Example from NERACOOS

[NERACOOS](http://www.neracoos.org) exposes data using a THREDDS server.  This is an exampel that draws upon the [MUR SST](https://podaac.jpl.nasa.gov/dataset/JPL-L4UHfnd-GLOB-MUR) data subset prepared in 2015.

We start by examining the [catalog](http://www.neracoos.org/thredds/catalog/GMRI/SST/TESTS/NASA_MUR_SST/catalog.html)  Note that programmatically we access the companion [XML file](http://www.neracoos.org/thredds/catalog/GMRI/SST/TESTS/NASA_MUR_SST/catalog.xml)


We'll crawl these pages in succession...

[Top](http://www.neracoos.org/thredds/catalog/GMRI/SST/TESTS/NASA_MUR_SST/catalog.html]

[NorthEastShelf](http://www.neracoos.org/thredds/catalog/GMRI/SST/TESTS/NASA_MUR_SST/NorthEastShelf/catalog.html)

[DailyFiles](http://www.neracoos.org/thredds/catalog/GMRI/SST/TESTS/NASA_MUR_SST/NorthEastShelf/DailyFiles/catalog.hml)

[2010](http://www.neracoos.org/thredds/catalog/GMRI/SST/TESTS/NASA_MUR_SST/NorthEastShelf/DailyFiles/2010/catalog.html)




```R
library(threddscrawler)

# start by getting the TopCatalog - picture TopCatalog as web page that list one or more catalogs.
Top <- get_catalog('http://www.neracoos.org/thredds/catalog/GMRI/SST/TESTS/NASA_MUR_SST/catalog.xml')
Top
# Reference Class: "TopCatalogRef"
#   verbose_mode: FALSE
#   url: http://www.neracoos.org/thredds/catalog/GMRI/SST/TESTS/NASA_MUR_SST/catalog.xml
#   children: service dataset
#   catalogs: NorthEastShelf GulfOfMaine

# now get the catalogs embedded in the page.  Note that these point to other TopCatalogs.
A <- Top$get_catalogs()
A
$NorthEastShelf
# Reference Class: "CatalogRefClass"
#   verbose_mode: FALSE
#   url: http://www.neracoos.org/thredds/catalog/GMRI/SST/TESTS/NASA_MUR_SST/NorthEastShelf/catalog.xml
#   children: 
#   name:NorthEastShelf
#   href:NorthEastShelf/catalog.xml
#   title:NorthEastShelf
#   type:
#   ID:GMRI_TESTS/NASA_MUR_SST/NorthEastShelf
# 
# $GulfOfMaine
# Reference Class: "CatalogRefClass"
#   verbose_mode: FALSE
#   url: http://www.neracoos.org/thredds/catalog/GMRI/SST/TESTS/NASA_MUR_SST/GulfOfMaine/catalog.xml
#   children: 
#   name:GulfOfMaine
#   href:GulfOfMaine/catalog.xml
#   title:GulfOfMaine
#   type:
#   ID:GMRI_TESTS/NASA_MUR_SST/GulfOfMaine
  
# now we get the catalogs in the NorthEastShelf   
NES <- A[['NorthEastShelf']]$get_catalog()
NES
# Reference Class: "TopCatalogRef"
#   verbose_mode: FALSE
#   url: http://www.neracoos.org/thredds/catalog/GMRI/SST/TESTS/NASA_MUR_SST/NorthEastShelf/catalog.xml
#   children: service dataset
#   catalogs: MonthlyMeans MonthlyFiles DailyFiles AggregatedMeans
  
# let's get the catalogs.  I won't show them, but we'll get the TopCatalog for the 'DailyFiles'
B <- NES$get_catalogs()

DAYS <- B[['DailyFiles']]$get_catalog()

# now 
C <- DAYS$get_catalogs()

Y2010 <- C[['2010']]$get_catalog()
```

Now we are at "the bottom" of the search path and we find only a collection of datasets.  Instead of requesting subsequent catalogs we can now request datasets.  

```R
days <- Y2010$get_datasets()
head(days, n = 2)
# $`20101231-JPL-L4UHfnd-GLOB-v01-fv04-MUR_subset.nc`
# Reference Class: "DatasetsRefClass"
#   verbose_mode: FALSE
#   url: http://www.neracoos.org/thredds/catalog/GMRI/SST/TESTS/NASA_MUR_SST/NorthEastShelf/DailyFiles/2010/20101231-JPL-L4UHfnd-GLOB-v01-fv04-MUR_subset.nc
#   children: dataSize date
#   datasets: NA
# 
# $`20101230-JPL-L4UHfnd-GLOB-v01-fv04-MUR_subset.nc`
# Reference Class: "DatasetsRefClass"
#   verbose_mode: FALSE
#   url: http://www.neracoos.org/thredds/catalog/GMRI/SST/TESTS/NASA_MUR_SST/NorthEastShelf/DailyFiles/2010/20101230-JPL-L4UHfnd-GLOB-v01-fv04-MUR_subset.nc
#   children: dataSize date
#   datasets: NA
```

Note that the 'datasets' attribute is NA - that tells us that have a real data source, not a catalog of data sources.
