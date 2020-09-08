simulate.outer <- function(n,d,lhs=F,auto_repetition=1,q.outer,...){
  # main function for the simulation framework
  # Parameters:
  # ... n -> simulation length
  # ... d -> simulation dimension
  # ... lhs -> applies Latin Hypercube sampling if lhs=TRUE
  # ... auto_repetition -> applies auto_repetition of auto_repetition = TRUE
  # ... q.outer -> accepts the function name of the variance reduction / simulation algorithm
  # Returns:
  # ... estimation mean
  # ... standart error
  # ... confidence interval metrics if auto_repetition = TRUE

  set.seed(1)
  # create z.matrix. if lhs=T, create it using LHS
  if(lhs == F){
    zm <- matrix(rnorm(n*d),ncol=d)
  }
  else if(lhs == T){
    zm <- matrix(lhs::randomLHS(n,d), ncol = d)
  }
  # send z.matrix to given simulation function and use only y values
  # from returning list of q.outer
  y_sim <- as.data.frame(q.outer(zm,...))[,1]
  # calculate estimation mean and standart error
  mean_y_sim = mean(y_sim)
  SE_y_sim = 1.96*sqrt(var(y_sim)/n)

  # if auto_repetition != 1, run simulation auto_repetition times with n=1000
  # set confidence intervals and count how many of them include mean_y_sim
  if(auto_repetition!=1){
    set.seed(2)
    n=1000
    repetitions=auto_repetition
    y_vector = c()
    for(i in 1:repetitions){
      if(lhs == F){
        zm <- matrix(rnorm(n*d),ncol=d)
      }
      else if(lhs == T){
        zm <- matrix(LHS(n,d), ncol = d)
      }
      # apply variance reduction algorithms through q.outer, if any given
      y <- as.data.frame(q.outer(zm,...))[,1]
      # store simulation estimation and standart errors of each of the 1000 simulations
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
    return(c(round(mean_y_sim,3), round(SE_y_sim,10), is_in_CI))
  }
  # return only mean_y_sim and SE_y_sim if auto_repetition=FALSE
  return( c(est=round(mean(y_sim),3),SE=round(1.96*sqrt(var(y_sim)/n) , 10)) )
}
