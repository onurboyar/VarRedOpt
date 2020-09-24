#' @title Function to apply Importance Sampling Algorithm.
#'
#' @description Given matrix input with d dimension, this function applies Importance Sampling algorithm and it chooses the best value of the mean value of the importance density automatically. Performs better in rare event simulation. sim.IS checks the input size and returns elements accordingly. If the input value is a list of one element it only updates the simulated value with importance weight and returns that value. If the input value has a dimension bigger than 1, weight values are added separately as another input of the list.
#
#'
#' @param zm A matrix with dimension d and length n.
#' @param use_pilot_study TRUE if user wants to choose muis parameter automatically.
#' @param muis mean parameter of the importance density.
#' @param sis standard deviation parameter of the importance density.
#' @param q.is q function that sim.IS function gets target vectors to apply variance reduction.
#' @param ... ellipsis parameter. different parameters can be passed depending on the problem.
#' @return Weighted simulated values or weights and simulated values are added to input list depending on the initial input size.
#'
#' @examples  sim.outer(n=1e3, d=3, q.outer = sim.IS,
#' q.is = myq_asian, K=100, ti=(1:3/12), r=0.03, sigma=0.3, S0=100)
#' @export sim.IS
#' @export

sim.IS <- function(zm, use_pilot_study=TRUE, muis=1, sis=1,q.is,...){
  # calculates is density and finds weights
  # returns calculated weights in a list

  # Returns:
  # ... q.is returns simulation results. it stores 4 elements.
  # ... sim.IS adds new elements to results and returns it.

  n <- nrow(zm)
  d <- dim(zm)[2]

  if(use_pilot_study==TRUE){
    #####pilot study starts
    muis_candidates = seq(1.01, 1.2, by = 0.01)
    best_std_error = Inf
    best_muis_value = 1
    for(muis in muis_candidates){
      set.seed(1)
      n_pilot=1e4
      zm_pilot <- matrix(rnorm(n_pilot*d, muis, sis),nrow=n_pilot,ncol=d)
      results <- q.is(zm_pilot,...)
      y <- results[[1]]
      w <- dnorm(zm_pilot[,1]) / dnorm(zm_pilot[,1], muis, sis)
      if(d>1){
        for(i in 2:d){
          w <- w * dnorm(zm_pilot[,i]) / dnorm(zm_pilot[,i], muis, sis)
        }
      }
      std_error <- 1.96*sqrt(var(y*w)/n_pilot)
      if(std_error < best_std_error){
        best_std_error = std_error
        best_muis_value = muis
      }
    }
    ##### pilot study ends
  }
  set.seed(1)
  zm <- matrix(rnorm(n*d, best_muis_value, sis),nrow=n,ncol=d)
  results <- q.is(zm,...)
  ###
  ###
  y <- results[[1]]

  w <- dnorm(zm[,1]) / dnorm(zm[,1], best_muis_value, sis)
  if(d>1){
    for(i in 2:d){
      w <- w * dnorm(zm[,i]) / dnorm(zm[,i], best_muis_value, sis)
    }
  }
  # results list is already length of 4. it has y, last_price, E_z, prodSt.
  # by using IS, we change y and we add new values to the list starting from
  # index 5df_
  results[[1]] <- y*w
  #
  if(length(results)==1){return(results)}
  #
  # add IS weight
  length_results = length(results)
  results[[length_results+1]] <- w
  results[[length_results+2]] <- y
  return(results)
}
