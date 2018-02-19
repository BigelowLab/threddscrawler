# [THREDDS](https://www.unidata.ucar.edu/software/thredds/current/tds/catalog/InvCatalogSpec.html) organization at NCEI
for NAMANL and NAM218


Copious notes below, but here is the nutshell

```
topuri = 'https://www.ncei.noaa.gov/thredds/catalog/namanl/catalog.xml'

X <- TopCatalogRefClass$new(topuri, verbose = TRUE)

# get monthly catalog
month_cc <- X$get_catalogRefs()
# month_cc[1]
# $`201802`
# Reference Class: "CatalogRefClass"
#   verbose_mode: TRUE
#   url: https://www.ncei.noaa.gov/thredds/catalog/namanl/201802/catalog.xml
#   children:

month_c <- month_cc[[1]]$get_catalog()
# month_c
# Reference Class: "TopCatalogRef"
#   verbose_mode: TRUE
#   url: https://www.ncei.noaa.gov/thredds/catalog/namanl/201802/catalog.xml
#   children: service dataset



day_cc <- month_c$get_catalogs()
# day_cc[[1]]
# Reference Class: "CatalogRefClass"
#   verbose_mode: TRUE
#   url: https://www.ncei.noaa.gov/thredds/catalog/namanl/201802/20180211/catalog.xml
#   children:

day_c <- day_cc[[1]]$get_catalog()
# day_c
# Reference Class: "TopCatalogRef"
#   verbose_mode: TRUE
#   url: https://www.ncei.noaa.gov/thredds/catalog/namanl/201802/20180211/catalog.xml
#   children: service dataset

day_dd = day_c$get_datasets()
# day_dd[[1]]
# Reference Class: "DatasetRefClass"
#   verbose_mode: TRUE
#    name: namanl_218_20180211_0000_006.grb2
#    ID: namanl/201802/20180211/namanl_218_20180211_0000_006.grb2
#    url: https://www.ncei.noaa.gov/thredds/catalog/namanl/201802/20180211/namanl_218_20180211_0000_006.grb2
#    dataSize: 57.02 Mbytes
#    date: 2018-02-12T16:40:24Z
#    serviceName: NA
```

### [catalog](https://www.unidata.ucar.edu/software/thredds/current/tds/catalog/InvCatalogSpec.html#catalog)

*The catalog element is the top-level element. It may contain zero or more service
elements, followed by zero or more datasetRoot elements, followed by zero or more
property elements, followed by one or more dataset elements.*


[NAMANL Example](https://www.ncei.noaa.gov/thredds/catalog/namanl/catalog.xml)

```
<catalog version="1.0.1">
<service name="ALL" serviceType="Compound" base="">...</service>
<dataset name="NAM Grid 218 - Analysis Only file units" ID="namanl">
  <metadata inherited="true">...</metadata>
  <catalogRef xlink:href="201802/catalog.xml" xlink:title="201802" ID="namanl/201802" name=""/>
  <catalogRef xlink:href="201801/catalog.xml" xlink:title="201801" ID="namanl/201801" name=""/>
  <catalogRef xlink:href="201712/catalog.xml" xlink:title="201712" ID="namanl/201712" name=""/>
  <catalogRef xlink:href="201711/catalog.xml" xlink:title="201711" ID="namanl/201711" name=""/>
    ...
  <catalogRef xlink:href="200403/catalog.xml" xlink:title="200403" ID="namanl/200403" name=""/>
</dataset>
</catalog>
```

Representation in R using threddscrawler

```r
topuri = 'https://www.ncei.noaa.gov/thredds/catalog/namanl/catalog.xml'
X <- TopCatalogRefClass$new(topuri, verbose = TRUE)
X
# Reference Class: "TopCatalogRef"
#   verbose_mode: TRUE
#   url: https://www.ncei.noaa.gov/thredds/catalog/namanl/catalog.xml
#   children: service dataset
```


### [catalogRef](https://www.unidata.ucar.edu/software/thredds/current/tds/catalog/InvCatalogSpec.html#catalogRef)


*A catalogRef element refers to another THREDDS catalog that logically is a nested
dataset inside this parent catalog. This is used to separately maintain catalogs
and to break up large catalogs. THREDDS clients should not read the referenced
catalog until the user explicitly requests it, so that very large dataset
collections can be represented with catalogRef elements without large delays in
presenting them to the user.*

NAMANL Example from catalog listed above
```
<catalogRef xlink:href="201802/catalog.xml" xlink:title="201802" ID="namanl/201802" name=""/>
```

Representation in R using threddscrawler.  Note a CatalogRef has no children - it's
attribute href is combined with it's parent url to create a new url.  We can request
the (top) catalog it references, which does have children (service and dataset)

```r
cc <- X$get_catalogs()
cc[[1]]
# Reference Class: "CatalogRefClass"
#   verbose_mode: TRUE
#   url: https://www.ncei.noaa.gov/thredds/catalog/namanl/201802/catalog.xml
#   children:

x = cc[[1]]$get_catalog()
x
# Reference Class: "TopCatalogRef"
#   verbose_mode: TRUE
#   url: https://www.ncei.noaa.gov/thredds/catalog/namanl/201802/catalog.xml
#   children: service dataset
```

### [dataset](https://www.unidata.ucar.edu/software/thredds/current/tds/catalog/InvCatalogSpec.html#dataset)

[Example](https://www.ncei.noaa.gov/thredds/catalog/namanl/201802/20180208/catalog.xml)

*A dataset element represents a named, logical set of data at a level of
granularity appropriate for presentation to a user. A dataset is direct if it
contains at least one dataset access method, otherwise it is just a container
for nested datasets, called a collection dataset.*


*A direct dataset has an access URL and a service type like FTP, DODS, ADDE, etc.
that allows a THREDDS-enabled application to directly access its data, using the
specified service's protocol. It is represented simply by a <dataset> element.*

Attributes:
  + `name`  required
  + `ID`    optional unique


### [collections](https://www.unidata.ucar.edu/software/thredds/current/tds/catalog/InvCatalogSpec.html#collection)

*A collection dataset is represented by a <dataset> with nested <dataset> elements.*
