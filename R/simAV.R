#' @title Function to apply Antithetic Variates Algorithm.
#'
#' @description Given matrix input with d dimension, this function runs simulation two times using positive and negitve signed versions of the input matrix.
#
#'
#' @param zm A matrix with dimension d and length n.
#' @param q.av q function that sim.AV function gets target vectors to apply variance reduction.
#' @param ... ellipsis parameter. different parameters can be passed depending on the problem.
#' @return y target vector with theoretically lower variance with the same expected value as the initial y vector.
#'
#' @examples  sim.outer(n=1e3, d=3, q.outer = sim.AV,
#' q.av = myq_asian, K=100, ti=(1:3/12), r=0.03, sigma=0.3, S0=100)
#' @export sim.AV
#' @export


sim.AV <- function(zm, q.av = myq, ...){
  # Applies antithetic variates
  # q.av is expected to return a list.
  # q.av might include multiple elements, the first one
  # is always the target variable
  y1 <- as.data.frame(q.av(zm,...))[,1]
  y2 <- as.data.frame(q.av(-zm,...))[,1]
  y <- 0.5*(y1 + y2)
  return(y)
}
