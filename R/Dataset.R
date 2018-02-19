
# A dataset element represents a named, logical set of data at a level of
# granularity appropriate for presentation to a user. A dataset is direct if it
# contains at least one dataset access method, otherwise it is just a container
# for nested datasets, called a collection dataset. The name of the dataset
# element should be a human readable name that will be displayed to users.
# Multiple access methods specify different services for accessing the same
# dataset.



#' A direct Dataset representation that subclasses from ThreddsNodeRefClass
#'
#' @family Thredds
#' @include DatasetCollection.R Thredds.R
#' @field dataSize numeric size in bytes
#' @field date character
#' @field urlPath character relative URL, use url or get_url() instead
#' @export
DatasetRefClass <- setRefClass("DatasetRefClass",
   contains = 'ThreddsNodeRefClass',

   fields = list(
      name = 'character',
      ID = 'character',
      dataSize = 'numeric',
      date = 'character',
      serviceName = 'character',
      urlPath = 'character'
      ),

   methods = list(
      initialize = function(x, ...){
         callSuper(x, ...)
         if (!is_xmlNode(.self$node)){
            .self$dataSize <- as.numeric(NA)
            .self$date <- as.character(NA)
            .self$serviceName <- as.character(NA)
            .self$urlPath <- as.character(NA)
         } else {
            .self$node <- x
            .self$dataSize <- .self$get_dataSize(formatted = FALSE)
            .self$date <- .self$get_date()
            acc <- .self$get_access()
            for (n in names(acc)) if(n %in% names(acc)) .self[[n]] <- acc[[n]]
            #nm <- names(XML::xmlChildren(.self$node))
            #if ('dataSize' %in% nm)
            #   .self$dataSize <- as.numeric(XML::xmlValue(.self$node[['dataSize']]))
            #
            #if ('date' %in% nm)
            #   .self$date <- XML::xmlValue(.self$node[['date']])
            #
            #if ('access' %in% nm){
            #   atts <- XML::xmlAttrs(.self$node[['access']])
            #   natts <- names(atts)
            #   nm <- c("serviceName", "urlPath")
            #   for (n in nm) {
            #      if (n %in% natts) .self[[n]] <- atts[[n]]
            #   }
            #} # access?
         } # is_xmlNode?
      },

      show = function(prefix = ""){
         "show the contents"
         #callSuper(prefix = prefix)
         if (is_xmlNode(.self$node)){
            cat(prefix, "Reference Class: ", methods::classLabel(class(.self)), "\n", sep = "")
            cat(prefix, "  verbose_mode: ", .self$verbose_mode, "\n", sep = "")
            cat(prefix, "  name:", .self$name, "\n", sep = " ")
            cat(prefix, "  ID:", .self$ID, "\n", sep = " ")
            cat(prefix, "  url:", .self$get_url(), "\n", sep = " ")
            cat(prefix, "  dataSize:", .self$get_dataSize(formatted = TRUE), "\n", sep = " ")
            cat(prefix, "  date:", .self$date, "\n", sep = " ")
            cat(prefix, "  serviceName:", .self$serviceName, "\n", sep = " ")

         }
      }
   )
)


#' Retrieve the access information
#'
#' @name DatasetRefClass_get_access
#' @return character vector of serviceName and urlPath
NULL
DatasetRefClass$methods(
    get_access = function(){
        r <- c(name = NA_character_, ID = NA_character_, serviceName = NA_character_, urlPath = NA_character_)
        acc <- .self$node %>%
            xml2::xml_find_first('.//access')
        if (length(acc) > 0){
            atts <- acc %>% xml2::xml_attrs()
            for (n in names(r)) {
                if (n %in% names(atts)) r[[n]] <- atts[[n]]
            }
        } else {
            atts <- xml2::xml_attrs(.self$node)
            for (n in names(r)) {
                if (n %in% names(atts)) r[[n]] <- atts[[n]]
            }
        }
    r
    })

#' Retrieve the dataSize element formatted
#'
#' @name DatsetRefClass_get_dataSize
#' @param formatted logical, if TRUE return 'size (units)' else return numeric size
#' @return character string or numeric (possible NA or empty)
NULL
DatasetRefClass$methods(
    get_dataSize = function(formatted = FALSE){

        # <dataSize units="Mbytes">57.02</dataSize>
        ds <- .self$node %>%
                xml2::xml_find_first('dataSize')
        if (length(ds) == 0) {
            if (formatted) return(NA_character_) else return(NA_real_)
        }
        if (formatted){
            if (length(ds) > 0){
                r <- sprintf("%s %s", xml2::xml_text(ds), xml2::xml_attrs(ds)[['units']])
            } else {
                r <- NA_character_
            }
        } else {
            if (length(ds) > 0){
                r <- xml2::xml_double(ds)
            } else {
                r <- NA_real_
            }
        }
        return(r)
    })



#' Retrieve the data-modified element
#'
#' @name DatsetRefClass_get_date
#' @return character string (possible NA or empty)
NULL
DatasetRefClass$methods(
    get_date = function(){
        # <date type="modified">2018-02-12T16:40:24Z</date>
        ds <- .self$node %>%
                xml2::xml_find_first('date')
        if (length(ds) > 0){
            r <- ds %>% xml2::xml_text()
            #r <- if ("modified" %in% names(r)) r[['modified']] else NA_character_
        } else {
            r <- NA_character_
        }
        return(r)
    })

#' Overrides the GET method of the superclass.  GET is not permitted
#'
#' @name DatasetRefClass_GET
#' @return NULL
NULL
DatasetRefClass$methods(
   GET = function(){
      cat("DatasetRefClass$GET is not permitted. Try ncdf4::nc_open(ref$url)\n")
   })


#' Retrieve the URL for a non-collection dataset
#'
#' @name DatasetRefClass_get_url
#' @return character
NULL
DatasetRefClass$methods(
   get_url = function(){
      .self$urlPath
   })
