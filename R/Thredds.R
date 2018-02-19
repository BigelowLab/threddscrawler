# thredds

#' An base representation that  other nodes subclass from
#'
#' @family Thredds
#' @field url character - possibly wrong but usually right!
#' @field node xml2::xml_node
#' @export
ThreddsNodeRefClass <- setRefClass("ThreddsNodeRefClass",

   fields = list(
      url = 'character',
      node = "ANY",
      handle = "ANY",
      verbose_mode = "logical",
      tries = 'numeric'),

   methods = list(
      initialize = function(x, verbose = FALSE, n_tries = 3){
         "x may be url or xml2::xml_node"
        .self$verbose_mode <- verbose
        .self$tries <- n_tries
         if (!missing(x)){
            if (is_xmlNode(x)) {                       # xml_node?
               .self$node <- xml2::xml_ns_strip(x)
               .self$url <- 'none'
            } else if (is.character(x)) {              # URL?
               .self$handle <- httr::handle(x)
               .self$url <- x
               x <- .self$GET(x)
               if (is.null(x)){
                  .self$node <- NULL
               } else if (x$status == 200){
                  .self$node <- xml2::xml_ns_strip(httr::content(x))
               } else {
                  httr::stop_for_status(x,
                    task = sprintf('Unable to initalize: %s', x))
               }
            }
         }
      },

      show = function(prefix = ""){
         "show the content of the class"
         cat(prefix, "Reference Class: ", methods::classLabel(class(.self)), "\n", sep = "")
         cat(prefix, "  verbose_mode: ", .self$verbose_mode, "\n", sep = "")
         cat(prefix, "  url: ", .self$url, "\n", sep = "")
         if (is_xmlNode(.self$node)) {
            cat(prefix, "  children: ", paste(.self$children_names(), collapse = " "), "\n", sep = "")
         }
      })

   )

#' Retrieve the url of this node (mostly gets an override by subclasses?)
#'
#' @family Thredds
#' @name ThreddsNodeRefClass_get_url
#' @return character url (possibly invalid)
NULL
ThreddsNodeRefClass$methods(
   get_url = function(){
      .self$url
   })


#' View with local browser if possible
#'
#' @name ThreddsNodeRefClass_BROWSE
NULL
ThreddsNodeRefClass$methods(
    BROWSE = function(){
    uri <- .self$get_url()
    if (interactive() && nchar(uri) > 0){
        httr::BROWSE(uri)
    }
})

#' Retrieve a node of the contents at this nodes URL
#'
#' This methods wraps \code{httr::GET()}
#'
#' @family Thredds
#' @name ThreddsNodeRefClass_GET
#' @param URL url of the resource to retrieve
#' @return httr response
NULL
ThreddsNodeRefClass$methods(
   GET = function(URL){
      if (missing(URL)) URL = .self$get_url()
      if (.self$verbose_mode) cat("GET", URL, "\n")
      i <- 1
      r <- NULL
      while(i <= .self$tries){
         #r <- try(httr::GET(.self$url, handle = httr::handle(.self$url)))
         r <- try(httr::GET(URL))
         if (inherits(r, "try-error")){
            if (.self$verbose_mode) {
               cat(sprintf("*** GET failed after attempt %i\n", i))
               if (i < .self$tries) {
                  cat("  will try again\n")
               } else {
                  cat("  exhausted permitted tries, returning NULL\n")
               }
            }
            r <- NULL
            i <- i + 1
         } else {
            if (i > 1) cat(sprintf("  whew!  attempt %i successful\n", i))
            #r <- parse_node(r, verbose = .self$verbose_mode)
            break
         }
      }
      return(r)
   })

#' Retrieve a vector of unique child names
#'
#' @family Thredds
#' @name ThreddsNodeRefClass_children_names
#' @return a vector of unique children names
NULL
ThreddsNodeRefClass$methods(
   children_names = function(){
      x <- if (is_xmlNode(.self$node)) unique(names(xml_kids(.self$node))) else ""
      return(x)
   })

#' Write XML the contents to file or character vector
#'
#' @name ThreddsNodeRefClass_write_xml
#' @param filename the name of the file to write to
#' @param ... further arguments for xml2::write_xml
NULL
ThreddsNodeRefClass$methods(
    write_xml = function(filename = paste0(methods::classLabel(class(.self)), '.xml'), ...) {
        if (is_xmlNode(.self$node)) {
            xml2::write_xml(.self$node, filename, ...)
        } else {
            warning("there is not XML data to write")
        }
    })



