# http://www.unidata.ucar.edu/software/thredds/current/tds/catalog/InvCatalogSpec.html#service
# A service element represents a data access service and allows basic data
# access information to be factored out of dataset and access elements.


#' An Service representation that subclasses from ThreddsNodeRefClass
#'
#' @family Thredds
#' @include Thredds.R
#' @field name character
#' @field serviceType character
#' @field base character base url
#' @export
ServiceRefClass <- setRefClass("ServiceRefClass",
   contains = 'ThreddsNodeRefClass',
   fields = list(
      name = 'character',
      serviceType = 'character',
      base = 'character',
      desc = 'character',
      suffix = 'character'
      ),
   methods = list(
      initialize = function(x, ...){
         callSuper(x, ...)
         if (is_xmlNode(.self$node)){
            atts <- xml2::xml_attrs(.self$node)
            natts <- names(atts)
            lut <- c(
                name = NA_character_,
                serviceType = NA_character_,
                base = NA_character_,
                desc = NA_character_,
                suffix = NA_character_)
            for (n in names(atts)) if(n in names(lut)) .self$field(n, atts[[n]])
         }
      },
      show = function(prefix = ""){
         callSuper(prefix = "")
         cat(prefix, "  name: ", .self$name, "\n", sep = "")
         cat(prefix, "  serviceType: ", .self$serviceType, "\n")
         cat(prefix, "  base: ", .self$base, "\n", sep = "")
         cat(prefix, "  desc: ", .self$desc, "\n", sep = "")
         cat(prefix, "  suffix: ", .self$suffix, "\n", sep = "")
      })
   )


###### Methods above
###### Functions below

#' Given a Service node with Service children retrieve either a list of
#' ServiceRefClass objects or a simplified tibble
#'
#' @param x xml_node of name service with attribute serviceType 'compound'
#' @param form character either ServiceRefClass or tibble (default)
#' @param ... further arguments for \code{parse_node()}
get_services <- function(x, form = c("ServiceRefClass", "tibble")[2], ...){
    a <- xml2::xml_attrs(x)
    if (!all(c(
        xml2::xml_name(x) == 'service',
        'serviceType' %in% names(a),
        a[['serviceType']] == 'Compound'))) {
        stop("input must be 'service' node of 'serviceType'")
    }
    ss <- x %>% xml2::xml_find_all('service')
    if (tolower(form[1]) == 'servicerefclass'){
        x <- lapply(ss, parse_node, ...)
    } else {
        template = c(name = NA_character_,
            serviceType = NA_character_,
            base = NA_character_,
            desc = NA_character_,
            suffix = NA_character_)
        xx <- lapply(ss,
            function(s, temp = NULL) {
                a <- xml2::xml_attrs(s)
                temp[names(a)] <- a
                tibble::as_tibble(as.list(temp))
            }, temp = template)
        x <- dplyr::bind_rows(xx)
    }
    return(x)
}


