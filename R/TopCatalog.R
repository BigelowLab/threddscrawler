# http://www.unidata.ucar.edu/software/thredds/current/tds/catalog/InvCatalogSpec.html#catalog
# The catalog element is the top-level element. It may contain zero or more
# service elements, followed by zero or more datasetroot elements, followed by
# zero or more property elements, followed by one or more dataset elements. The
# base is used to resolve any reletive URLs in the catalog such as catalogRefs,
# services, etc. It is usually the URL of the catalog document itself. Optionally
# the catalog may have a display name. The expires element tells clients when
# this catalog should be reread, so they can cache the catalog information. The
# value of the version attribute indicates the version of the InvCatalog
# specification to which the catalog conforms. The version attribute is optional,
# but should be used to document which version of the schema was used.

#' An catalog representation that sublcasses from ThreddsNodeRefClass
#'
#' @family Thredds TopCatalog
#' @include Thredds.R
#' @export
TopCatalogRefClass <- setRefClass("TopCatalogRef",
   contains = 'ThreddsNodeRefClass',
   methods = list(
      show = function(prefix = ""){
         "show the content of the class"
         cat(prefix, "Reference Class: ", methods::classLabel(class(.self)), "\n", sep = "")
         cat(prefix, "  verbose_mode: ", .self$verbose_mode, "\n", sep = "")
         cat(prefix, "  url: ", .self$url, "\n", sep = "")
         cn <- .self$children_names()
         if ('dataset' %in% cn){
            cc <- .self$get_collections()
            if (length(cc) > 0) {
                if (length(cc) == 1) {
                    cn <- gsub("dataset", "dataset-collection", cn, fixed = TRUE)
                } else {
                    cn <- gsub('dataset',
                        sprintf("dataset-collection (%i)", length(cc)), cn)
                }
            }
         }
         cat(prefix, "  children: ", paste(cn, collapse = " "), "\n", sep = "")
      }
      )
   )


#' Get a list of CatalogRef Children
#'
#' @family TopCatalog
#' @name TopCatalogRefClass_get_catalogRefs
#' @return a list of CatalogRefClass, possibly empty
NULL
TopCatalogRefClass$methods(
    get_catalogRefs = function(){
    x <-  lapply(.self$node %>% xml2::xml_find_all('.//catalogRef'),
        function(x){
            n <- parse_node(xml2::xml_ns_strip(x), verbose = .self$verbose_mode)
            #n$url <- gsub("catalog.xml", n$href, .self$url)
            n$url <- file.path(dirname(.self$url), n$href)
            return(n)
        })
     if (length(x) > 0) names(x) <- sapply(x, '[[', 'name')
      return(x)
   })



#' Get a list of CatalogRef Children
#'
#' @family TopCatalog
#' @name TopCatalogRefClass_get_catalogs
#' @return a list of CatalogRefClass, possibly NULL
NULL
TopCatalogRefClass$methods(
    get_catalogs = function(){
      return(.self$get_catalogRefs())
   })


#' Get a list of dataset collections
#'
#' There are two types of datasets... direct and collections and the thing that
#' distinguishes between them is if it contains other datasets.
#'
#' @param TopCatalogRefClass_get_collections
#' @return list of zero of more DatasetsRefClass
NULL
TopCatalogRefClass$methods(
    get_collections = function(){
        x <-  lapply(.self$node %>% xml2::xml_find_all('dataset'),
            function(x){
                n <- parse_node(xml2::xml_ns_strip(x), verbose = .self$verbose_mode)
                #n$url <- gsub("catalog.xml", n$href, .self$url)
                return(n)
            })
        x
    })
#' Get a list of Dataset Children
#'
#' @family TopCatalog
#' @name TopCatalogRefClass_get_datasets
#' @return a list of DatasetRefClass, possibly NULL
NULL
TopCatalogRefClass$methods(
    get_datasets = function(){

        x <- lapply(.self$get_collections(),
            function(x){
                xx <- x$get_datasets()
                if (length(xx) > 0){
                    xx <- lapply(xx,
                        function(x) {
                            x$urlPath <- file.path(dirname(.self$url), basename(x$get_url()))
                            x
                        })
                }
            })
        x <- unlist(x)
        return(x)
   })

#' Retrieve the services as a data frame
