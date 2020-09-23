#' @title Euclidean Distance
#'
#' @description Function to calculate euclidean distance between two vectors.
#
#'
#' @param zm Input matrix of set of vectors.
#' @param point Coordinates of the point to calculate distance to the input.
#'
#' @return Sum of the euclidean distance from point to set of vectors.
#'
#' @examples sim.outer(n=1e3, d=3, q.outer=myq_euclidean, point=c(1,1,1))
#'
#' @export myq_euclidean
#' @export

myq_euclidean <- function(zm,point=c(1,2,1)){
  # returns Euclidean distance of iid N(0,1) vector to "point"
  d <- length(point)
  sumDist2 <- 0
  for(i in 1:d) sumDist2 <- sumDist2 + (point[i]-zm[,i])^2

  returning_list = list(sqrt(sqrt(sumDist2)))
  return(returning_list)
}
