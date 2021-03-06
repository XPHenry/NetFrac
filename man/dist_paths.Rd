\name{dist_paths}
\alias{dist_paths}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{Shortest path distances
%%  ~~function to do ... ~~
}
\description{Takes as input the network as well as the species communities to be compared and gives as output the pairwise distance matrix between species communities. The use of the NetFrac function is recommended if the global distances (between all pair of communities) are needed.

%%  ~~ A concise (1-5 lines) description of what the function does. ~~
}
\usage{
dist_paths(x, col1, col2, distance = "paths", paths = "single", info = NULL, type = "graph", maxcores = 1)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{x}{The igraph object to be analyzed
%%     ~~Describe \code{x} here~~
}
  \item{col1}{Community one
%%     ~~Describe \code{col1} here~~
}
  \item{col2}{Community two
%%     ~~Describe \code{col2} here~~
}
  \item{distance}{Distances that are implemented in NetFrac. See also the \link{NetFrac} function
%%     ~~Describe \code{distance} here~~
}
  \item{paths}{Take into account all possible shortest paths or only one
%%     ~~Describe \code{paths} here~~
}
  \item{info}{Information about the tree if the input is a tree
%%     ~~Describe \code{info} here~~
}
  \item{type}{Tree or network
%%     ~~Describe \code{type} here~~
}
  \item{maxcores}{Number of parallel cores to be used for calculation (one by default)
%%     ~~Describe \code{maxcores} here~~
}
}
\details{
%%  ~~ If necessary, more details than the description above ~~
}
\value{
%%  ~Describe the value returned
%%  If it is a LIST, use
%%  \item{comp1 }{Description of 'comp1'}
%%  \item{comp2 }{Description of 'comp2'}
%% ...
}
\references{
%% ~put references to the literature/web site here ~
}
\author{
%%  ~~who you are~~
}
\note{
%%  ~~further notes~~
}

%% ~Make other sections like Warning with \section{Warning }{....} ~

\seealso{\code{\link{NetFrac}}
%% ~~objects to See Also as \code{\link{help}}, ~~~
}
\examples{

}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ ~kwd1 }% use one of  RShowDoc("KEYWORDS")
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
