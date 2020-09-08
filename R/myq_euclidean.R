#' @title Block Scholes for Geometric Asian Call Option
#'
#' @description Function to calculate expected value of Geometric Asian Call Option via Block Scholes formula.
#
#'
#' @param K Strike price.
#' @param T Time to maturity.
#' @param d Dimension of input z matrix.
#' @param ti Vector of control points.
#' @param r Interest rate
#' @param sigma
#' @param S0 Initial value.
#'
#' @return q.is returns simulation results. it stores 4 elements sim.IS adds new elements to results and returns it.
#'
#' @examples  simulate.outer(zm, q.outer = sim.IS, q.is = myq_asian, K=100, ti=(1:3/12), r=0.03, sigma=0.3, S0=100)
#'

myq_euclidean <- function(zm,point=c(1,2,1)){
  # returns Euclidean distance of iid N(0,1) vector to "point"
  d <- length(point)
  sumDist2 <- 0
  for(i in 1:d) sumDist2 <- sumDist2 + (point[i]-zm[,i])^2

  returning_list = list(sqrt(sqrt(sumDist2)))
  return(returning_list)
}
