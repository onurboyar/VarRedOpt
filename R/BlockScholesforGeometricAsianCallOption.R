#' @title Block Scholes for Geometric Asian Call Option
#'
#' @description Function to calculate expected value of Geometric Asian Call Option via Block Scholes formula.
#
#'
#'
#'
#' @param K Strike price.
#' @param TimeToMat Time to maturity.
#' @param d Dimension of input z matrix.
#' @param ti Vector of control points.
#' @param r Riskfree rate
#' @param sigma Yearly volatility.
#' @param S0 Stock price at start.
#' @param ... ellipsis parameter. different parameters can be passed depending on the problem.
#'
#' @return Expected value of Geometric Average Asian Call Option, vector of control points, interest rate and strike price as a list.
#'
#' @examples  sim.outer(n=1e3, d=3, q.outer = myq_asian, K=100, ti=(1:3/12), r=0.03, sigma=0.3, S0=100)
#' @export BS_Asian_geom
#' @export
#' @importFrom stats dnorm lm pnorm rnorm var

BS_Asian_geom <-function(K=100,TimeToMat,d,ti,r=0.05,sigma=0.1,S0=100,...){
  # Black-Scholes formula for Asian option with geometric average
  # ti ... vector of control points, the last entry is the time to maturity
  # Returns:
  # ... calculated price as y_geometric
  # ... ti value
  # ... r value
  # ... K value
  # ..... stores these values in a list and returns them
  d <- length(ti)
  dt <- c(ti[1],ti[-1]-ti[-d])# this calculates the differences
  mus <- log(S0)+(r-sigma^2/2)/d*sum((d:1)*dt)
  sigmas <- sigma/d*sqrt(sum((d:1)^2*dt))
  y_geometric <- exp(-r*ti[d])*(exp(mus+sigmas^2/2)*pnorm((mus+sigmas^2-log(K))/sigmas)
                                -K*pnorm((mus-log(K))/sigmas))
  return(list(y_geometric, ti, r, K))
}
