#' Determine if a vector of names match the greplargs
#'
#' @export
#' @param x a vector of names
#' @param greplargs NULL, vector or list
#' @return logical vector
grepl_it <- function(x, greplargs = NULL){
   ix <- rep(FALSE, length(x))
   if (is.null(greplargs)) return(!ix)
   if (!is.list(greplargs[[1]])) greplargs <- list(greplargs)

   for (g in greplargs){
         ix <- ix | grepl(g[['pattern']], x, fixed = g[['fixed']])
   }
   ix
}

#' Test if an object inherits from XML::XMLAbstractNode
#'
#' @export
#' @param x object to test
#' @param classname character, the class name to test against, by default 'XMLAbstractNode'
#' @return logical
is_xmlNode <- function(x, classname = 'xml_node'){
   inherits(x, classname)
}

#' Convert XML::xmlNode to character
#'
#' @export
#' @param x xmlNode
#' @return character
xmlString <- function(x){
   gsub("\n","", XML::toString.XMLNode(x))
}

#' A wrapper around \code{xml2::xml_children()} where the children are optionally named
#'
#' @export
#' @param x an xml_node object
#' @param named logical if TRUE then name the children using \code{xml2::xml_name()}
#' @return
xml_kids <- function(x, named = TRUE){
    k <- xml2::xml_children(x)
    if ((length(k) > 0) && named) names(k) <- sapply(k, xml2::xml_name)
    k
}

#' Determine dataset type -  'direct' or 'collection'
#'
#' Determined by presence of urlPath attribute for now
#'
#' @export
#' @param x xml_node object
#' @return character - either 'direct' or 'collection'
dataset_type <- function(x){
    if (!is_xmlNode(x) || (xml2::xml_name(x) != 'dataset')){
        stop("input must be xml_node of name 'dataset'")
    }
    dd <- x %>% xml2::xml_find_first("dataset")
    if (length(dd) == 0) 'direct' else 'collection'
}

#' Retrieve a catalog
#'
#' @export
#' @param uri the URI of the catalog
#' @param ... further arguments for parse_node
#' @return ThreddsNodeRefClass or subclass or NULL
get_catalog <- function(uri, ...){

   x <- httr::GET(uri)
   if (httr::status_code(x) == 200){
      node <- parse_node(x, ...)
   } else {
      node <- NULL
   }
   return(node)
}

#' Convert a node to an object inheriting from ThreddsNodeRefClass
#'
#' @export
#' @param x XML::xmlNode or an httr::response object
#' @param url character, optional url if a catalog or direct dataset
#' @param verbose logical, by default FALSE
#' @param encoding character, by default UTF-8
#' @return ThreddsNodeRefClass object or subclass
parse_node <- function(x, url = NULL, verbose = FALSE, encoding = 'UTF-8'){

   # given an 'dataset' xml::xml_node determine if the node is a collection or
   # direct (to data) and return the appropriate data type
   # parse_dataset <- function(x, verbose = FALSE){
   #
   #    if ('dataset' %in% names(XML::xmlChildren(x))){ # was 'access'
   #       r <- DatasetRefClass$new(x, verbose = verbose)
   #    } else {
   #       r <- DatasetsRefClass$new(x, verbose = verbose)
   #    }
   #    return(r)
   # }
    parse_dataset <- function(x, verbose = FALSE){
        typ <- dataset_type(x)
        if (typ == 'direct') {
            r <- DatasetRefClass$new(x, verbose = verbose)
        } else {
            r <- DatasetCollectionRefClass$new(x, verbose = verbose)
        }
        r
    }

    if (inherits(x, 'response')){
       if (x$status == 200){
          if (is.null(url)) url <- x$url
          x <- httr::content(x, type = 'text/xml', encoding = 'UTF-8')
          #node <- XML::xmlRoot(XML::xmlTreeParse(cnt))
       } else {
          cat("response status ==",httr::status_code(x), "\n")
          cat("response url = ", x$url, "\n")
          print(httr::content(x))
          return(NULL)
       }
    }

   if (!is_xmlNode(x)) stop("assign_node: node must be xml2::xml_node")

   nm <- xml2::xml_name(x)[1]
   x <- xml2::xml_ns_strip(x)
   n <- switch(nm,
       'catalog' = TopCatalogRefClass$new(x, verbose = verbose),
       'catalogRef' = CatalogRefClass$new(x, verbose = verbose),
       'service' = ServiceRefClassr$new(x, verbose = verbose),
       'dataset' = parse_dataset(x, verbose = verbose),
       ThreddsNodeRefClass$new(x, verbose = verbose))

   if (!is.null(url)) n$url <- url

   return(n)
}

