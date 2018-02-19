# Catalog.R

# http://www.unidata.ucar.edu/software/thredds/current/tds/catalog/InvCatalogSpec.html#catalogRef
# A catalogRef element refers to another THREDDS catalog that logically is a nested
# dataset inside this parent catalog. This is used to separately maintain catalogs
# and to break up large catalogs. THREDDS clients should not read the referenced
# catalog until the user explicitly requests it, so that very large dataset collections
# can be represented with catalogRef elements without large delays in presenting
# them to the user. The referenced catalog is not textually substituted into the
# containing catalog, but remains a self-contained object. The referenced catalog
# must be a valid THREDDS catalog, but it does not have to match versions with
# the containing catalog.

#' An catalogRef representation that subclasses from ThreddsNodeRefClass
#'
#' @family Catalog
#' @include Thredds.R
#' @field name character
#' @field href character relative link
#' @field title character
#' @field type character
#' @field ID character
#' @export
CatalogRefClass <- setRefClass("CatalogRefClass",
   contains = 'ThreddsNodeRefClass',
   fields = list(
      name = 'character',
      href = 'character',
      title = 'character',
      type = 'character',
      ID = 'character'),
   methods = list(
      initialize = function(x, ...){
         callSuper(x, ...)
         dummy <- c(name = '', href = '', title = '', type = '', ID = '')
         for (n in names(dummy)) .self$field(n, dummy[[n]])
         if (is_xmlNode(x)){
            #atts <- XML::xmlAttrs(.self$node)
            atts <- xml2::xml_attrs(x)
            natts <- names(atts)
            nm <- c("name", "href", "title", "type", "ID")
            for (n in nm) {
               if (n %in% natts) .self[[n]] <- atts[[n]]
            }
            if (!nzchar(.self$name) && nzchar(.self$title)) .self$name <- .self$title
            if (!nzchar(.self$name) && nzchar(.self$href)) .self$name <- dirname(.self$href)
            if (!nzchar(.self$name) && nzchar(.self$ID)) .self$name <- basename(.self$ID)
         }
      },

    show = function(prefix = ""){
         "show the content of the class"
         cat(prefix, "Reference Class: ", methods::classLabel(class(.self)), "\n", sep = "")
         cat(prefix, "  verbose_mode: ", .self$verbose_mode, "\n", sep = "")
         cat(prefix, "  url: ", .self$url, "\n", sep = "")
         s <- sprintf("  name: %s  href: %s  title: %s  type: %s  ID: %s",
                     .self$name, .self$href, .self$title, .self$type, .self$ID)
         cat(prefix, s, "\n", sep = "")
      }
   ) # methods
)


#' Retrieve the top catalog this catalog points to
#'
#' @name CatalogRefClass_get_catalog
#' @return TopCatalogRefClass or NULL
NULL
CatalogRefClass$methods(
   get_catalog = function(){
      #threddscrawler::get_catalog(.self$url)
        x <- .self$GET()
        if (!is.null(x)){
            x <- parse_node(x, verbose = .self$verbose_mode)
        }
        x
   })

#' Retrieve the URL for a non-collection dataset
#'
#' @name CatalogRefClass_get_url
#' @return character
NULL
CatalogRefClass$methods(
   get_url = function(){
      .self$url
      #return(sub("catalog.xml", .self$href, .self$url, fixed = TRUE))
   })
