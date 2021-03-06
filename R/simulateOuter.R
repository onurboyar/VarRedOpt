#' @title Main function for VarRedOpt simulation framework.
#'
#' @description This function creates the z matrix which is an input matrix with given dimension value, d, and given length, n. Values are generated from standard normal distribution. After creating the z matrix, this function sends this input matrix to given simulation function. After simulation steps are completed, simulate.outer function gets the final simulated values and calculates expected value and variance. For instance, if myq_asian and sim.AV functions are given in simulate.outer function as parameters, the input matrix will be sent to sim.AV function and sim.AV function will send input value to myq_asian function twice with opposite signs and gets simulation results. After collecting these results it applies Antithetic Variates algorithm and finds the final simulation value and sends it back to the simulate.outer function.
#
#'
#' @param n Simulation length.
#' @param d Simulation dimension.
#' @param auto_repetition Applies auto_repetition of auto_repetition = TRUE.
#' @param  q.outer Accepts the function name of the variance reduction / simulation algorithm.
#' @param ... ellipsis parameter. different parameters can be passed depending on the problem.
#'
#' @return estimation mean, standard error, confidence interval metrics if auto_repetition = TRUE
#'
#' @examples  sim.outer(n=1e3, d=3, q.outer = sim.AV,
#' q.av = myq_asian, K=100, ti=(1:3/12), r=0.03, sigma=0.3, S0=100)
#' @export sim.outer
#' @export
sim.outer <- function(n,d,auto_repetition=1,q.outer,...){
  # main function for the simulation framework
  # Parameters:
  # ... n -> simulation length
  # ... d -> simulation dimension
  # ... auto_repetition -> applies auto_repetition of auto_repetition = TRUE
  # ... q.outer -> accepts the function name of the variance reduction / simulation algorithm
  # Returns:
  # ... estimation mean
  # ... standard error
  # ... confidence interval metrics if auto_repetition = TRUE

  zm <- matrix(rnorm(n*d),ncol=d)

  # send z.matrix to given simulation function and use only y values
  # from returning list of q.outer
  y_sim <- as.data.frame(q.outer(zm,...))[,1]
  # calculate estimation mean and standard error
  mean_y_sim = mean(y_sim)
  SE_y_sim = 1.96*sqrt(var(y_sim)/n)

  # if auto_repetition != 1, run simulation auto_repetition times with n=1000
  # set confidence intervals and count how many of them include mean_y_sim
  if(auto_repetition!=1){
    n=1000
    repetitions=auto_repetition
    y_vector = c()
    for(i in 1:repetitions){

      zm <- matrix(rnorm(n*d),ncol=d)
      # apply variance reduction algorithms through q.outer, if any given
      y <- as.data.frame(q.outer(zm,...))[,1]
      # store simulation estimation and standard errors of each of the 1000 simulations
      y_vector <- rbind(y_vector, c(mean(y),2*sqrt(var(y)/n) ))
    }
    # create confidence intervals
    confidence_interval_lower = y_vector[,1] - y_vector[,2]
    confidence_interval_upper = y_vector[,1] + y_vector[,2]
    # find the percentage of confidence intervals that includes mean_y_sim value
    # obtained from our bigger simulation
    is_in_CI = sum(mean_y_sim > confidence_interval_lower &
                     mean_y_sim < confidence_interval_upper)/1000

    # return mean_y_sim,SE_y_sim and is_in_CI if auto_repetition=TRUE
    return(c(Estimation=round(mean_y_sim,3), StandardError=round(SE_y_sim,10), ConfidenceIntervalRatio=is_in_CI))
  }
  # return only mean_y_sim and SE_y_sim if auto_repetition=FALSE
  return( c(Estimation=round(mean(y_sim),3),StandardError=round(1.96*sqrt(var(y_sim)/n) , 10)) )
}
