% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/Datasets.R
\docType{class}
\name{DatasetsRefClass-class}
\alias{DatasetsRefClass}
\alias{DatasetsRefClass-class}
\title{A Dataset collection that subclasses from ThreddsNodeRefClass}
\description{
A Dataset collection that subclasses from ThreddsNodeRefClass
}
\section{Fields}{

\describe{
\item{\code{name}}{character
field ID character - seems to be a relative path}
}}
\section{Methods}{

\describe{
\item{\code{initialize(x, verbose = FALSE, n_tries = 3)}}{x may be url or XML::xmlNode}

\item{\code{show(prefix = "")}}{show the content of the class}
}}
\seealso{
Other Thredds: \code{\link{DatasetRefClass-class}},
  \code{\link{ServiceRefClass-class}},
  \code{\link{ThreddsNodeRefClass-class}},
  \code{\link{ThreddsNodeRefClass_GET}},
  \code{\link{ThreddsNodeRefClass_get_url}},
  \code{\link{ThreddsNodeRefClass_unames}}
}

