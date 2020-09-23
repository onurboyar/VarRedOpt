#' @title An Outer Control Variate function for Asian Call Option.
#'
#' @description # Applies geometric average asian call outer control varites algorithm to the simulation. Gets expected value for the control variate using BS_Asian_geom function if IS algorithm is within the framework, the length of the q.ga will be different. Checks if IS algorithm is within the framework and applies IS weight accordingly.
#
#'
#' @param zm A matrix with dimension d and length n.
#' @param q.ga q function that sim.GeometricAvg function gets target vectors to apply variance reduction.
#'
#' @return Updates Y value which stored in list 'results' and returns the list 'results' with updated Y value.
#'
#' @examples  simulate.outer(n=1e3, d=3, q.outer = sim.GeometricAvg,
#' q.ga = myq_asian, K=100, ti=(1:3/12), r=0.03, sigma=0.3, S0=100)
#'


sim.GeometricAvg <- function(zm, q.ga=myq,...){
  # applies geometric average asian call outer control varite to the simulation.
  # gets expected value for the control variate using BS_Asian_geom function
  # if IS algorithm is within the framework, the length of the q.ga will be different.
  # checks if IS algorithm is within the framework and applies IS weight accordingly

  # Returns:
  # ... updates Y value obtained from q.ga which is stored in list 'results'
  # ... returns list 'results' with updated Y value.

  results <- q.ga(zm,...)
  # to check if simulation results are coming through Importance Sampling algorithm.
  # IS algorithm sends a list length of 7.
  if(length(results)==7){
    zm <- results[[5]]
    Y <- results[[7]]

  }
  # if q.ga results are not from Importance Sampling, Y vector will be at
  # first index of the list
  else{
    Y <- results[[1]]
  }
  # initiate control variate matrix and expectation vector for these control variates
  cv.matrix = c()
  expectations = c()

  # for geometric average CV, product of the prices are at the fourth index of the
  # results list
  prodSt <- results[[4]]
  bs_asian_geom_results <- BS_Asian_geom(...)
  ti <- bs_asian_geom_results[[2]]

  d = length(ti)
  # calculate expected value for control variate via bs_asian_geom_results function
  Z<-exp(-bs_asian_geom_results[[3]]*ti[d])*pmax(prodSt^(1/d)-bs_asian_geom_results[[4]],0)

  # fill cv.matrix and expectations vector
  cv.matrix <- cbind(Z, cv.matrix)
  expectations <- c(bs_asian_geom_results[[1]], expectations)

  # create matrix for linear regression
  lm.matrix <- cbind(Y, cv.matrix)

  # fit linear regression model
  model <- lm(lm.matrix[,1]~.,
              data = data.frame(lm.matrix[,-1]))

  # get coefficients of regression model
  coeffs <- model$coefficients[-1]

  # calculate new target variable
  Y = Y - (coeffs*(Z - expectations))

  # check if results are coming from IS again and apply IS weight if it is
  if(length(results)==7){
    Y <- Y * results[[6]]
    results[[6]] <- 1
  }
  # update Y value in results list
  results[[1]] <- Y
  return(results)
}
