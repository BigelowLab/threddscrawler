
# A dataset element represents a named, logical set of data at a level of
# granularity appropriate for presentation to a user. A dataset is direct if it
# contains at least one dataset access method, otherwise it is just a container
# for nested datasets, called a collection dataset. The name of the dataset
# element should be a human readable name that will be displayed to users.
# Multiple access methods specify different services for accessing the same
# dataset.


#' A Dataset collection that subclasses from ThreddsNodeRefClass
#' @family Thredds
#' @include Thredds.R
#' @field name character
#' field ID character - seems to be a relative path
#' @export
DatasetCollectionRefClass <- setRefClass("DatasetCollectionRefClass",
   contains = 'ThreddsNodeRefClass',
   fields = list(
      name = 'character',
      ID = 'character'),
   methods = list(
      initialize = function(x, ...){
         callSuper(x, ...)
         if (is_xmlNode(.self$node)){
            atts <- xml2::xml_attrs(.self$node)
            natts <- names(atts)
            nm <- c("name", "ID")
            for (n in nm) {
               if (n %in% natts) .self[[n]] <- atts[[n]]
            }
            .self$url <- .self$ID
         }
      },

      show = function(prefix = ""){
         "show the contents"
         callSuper(prefix = prefix)
         if (is_xmlNode(.self$node) && inherits(.self, 'DatasetCollectionRefClass')){
            x <- .self$node %>% xml2::xml_find_all(".//catalogRef")
            nm <- if (length(x) > 0)
               sapply(x, function(x) xml2::xml_attrs(x)[['title']]) else
               "NA"
            cat(prefix, "  catalogs: ", paste(nm, collapse = " "), "\n", sep = "")

            x <- .self$node %>% xml2::xml_find_all(".//dataset")
            nm <- if (length(x) > 0)
               sapply(x, function(x) xml2::xml_attrs(x)[['name']]) else
               "NA"
            cat(prefix, "  datasets: ", paste(nm, collapse = " "), "\n", sep = "")

         }
      })
   )

#' Retrieve the URL for a dataset
#'
#' @name DatasetCollectionRefClass_get_url
#' @return character
NULL
DatasetCollectionRefClass$methods(
   get_url = function(){
      .self$name
   })

#' Retrieve one or more catalogs if available
#'
#' @name DatasetCollectionRefClass_get_catalogs
#' @return a list of zero or more CatalogRefClass
NULL
DatasetCollectionRefClass$methods(
    get_catalogs = function(){
    lapply(.self$node %>% xml2::xml_find_all(".//catalogRef"),
        function(x){
            x = parse_node(x, verbose = .self$verbose_mode)
            x$url <- gsub("catalog.xml", x$href, .self$url)
            x
        })
    })

#' Retrieve one or more datasets if available
#'
#' @name DatasetCollectionRefClass_get_datasets
#' @return a list of zero or more DatasetRefClass
NULL
DatasetCollectionRefClass$methods(
    get_datasets = function(){
    lapply(.self$node %>% xml2::xml_find_all(".//dataset"),
            function(x){
            x = parse_node(x, verbose = .self$verbose_mode)
            #x$url <- gsub("catalog.xml", x$href, .self$url)
            x
        })
    })

#' Retrieve the datasets from a dataset collection
#'
#' @name DatasetCollectionRefClass_get_collection
#' @return a list of DatasetRefClass or NULL
NULL
DatasetCollectionRefClass$methods(
    get_collection = function(){
        if (!is_xmlNode(.self$node)) return(NULL)
        #lapply(.self$node[['dataset']]['dataset', all = TRUE], parse_node)
        lapply(.self$node %>% xml2::xml_find_all(".//catalogRef"),
            parse_node, verbose = .self$verbose_mode)
    })
