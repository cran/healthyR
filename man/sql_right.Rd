% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/sql_string_split.R
\name{sql_right}
\alias{sql_right}
\title{Use SQL RIGHT type functions}
\usage{
sql_right(.text, .num_char)
}
\arguments{
\item{.text}{A piece of text/string to be manipulated}

\item{.num_char}{How many characters do you want to grab}
}
\description{
Perform an SQL RIGHT type function
}
\details{
\itemize{
\item You must supply data that you want to manipulate.
}
}
\examples{

sql_right("this is some more text", 3)

}
