#' @title Function to apply Inner Control Variates Algorithm.
#'
#' @description Given matrix input with d dimension, this function aims to reduce the variance by applying Inner Control Variates algorithm. It uses input columns and their squares as inner control variates and applies feature selection for these control variates.
#
#'
#' @param zm A matrix with dimension d and length n.
#' @param q.cv q function that sim.InnerCV function gets target vectors to apply variance reduction.
#'
#' @return Updates Y value which stored in list 'results' and returns the list 'results' with updated Y value.
#'
#' @examples  simulate.outer(zm, q.outer = sim.InnerCV, q.cv = myq_asian, K=100, ti=(1:3/12), r=0.03, sigma=0.3, S0=100)
#'

sim.InnerCV <- function(zm, q.cv = myq,...){
  # zm ... z matrix
  # Y ... estimated results of the simulation.
  # this function takes zm and Y as an input and
  # calculates multiple inner CV's using zm and
  # apply them to Y

  # Returns:
  # ... Updates Y value which stored in list 'results' and returns the list 'results'
  results <- q.cv(zm,...)
  if(length(results)==7){
    zm <- results[[5]]
    Y <- results[[7]]

  }else{
    Y <- results[[1]]
  }

  # in rare event simulation, we might not be able to catch any positive observation
  # which results in a vector of whole zeros.
  # in this case, we cannot apply control variates. so we just return the values.
  if(sum(Y==0)==dim(zm)[1]){
    print("All values are equal to zero.")
    return(results)
  }

  d <- dim(zm)[2]
  cv.matrix <- c()
  expectations <- c()
  for(i in 1:d){
    cv.matrix <- cbind(cv.matrix, zm[,i])
    expectations[i] <- 0
  }

  for(i in 1:d){
    cv.matrix <- cbind(cv.matrix,zm[,i]^2)
    expectations[d+i] <- 1
  }

  lm.matrix <- cbind(Y, cv.matrix)
  model <- lm(lm.matrix[,1]~.,
              data = data.frame(lm.matrix[,-1]))
  t_vals <- summary(model)$coefficients[-1,3]
  t_vals_flag <- abs(t_vals) > 5

  if(sum(t_vals_flag)==0){
    results[[1]] <- Y
    return(results)
  }

  while(length(t_vals)!=sum(t_vals_flag)){
    cv.matrix <- cv.matrix[,t_vals_flag]
    expectations <- expectations[t_vals_flag]
    lm.matrix <- cbind(Y, cv.matrix)
    model <- lm(lm.matrix[,1]~.,
                data = data.frame(lm.matrix[,-1]))
    t_vals <- summary(model)$coefficients[-1,3]
    t_vals_flag <- abs(t_vals) > 5
  }


  coeffs <- model$coefficients[-1]

  cv_sums <- 0
  if(ncol(as.matrix(cv.matrix))>1){
    for(i in 1:length(coeffs)){
      cv_sums <- cv_sums + coeffs[i]*(cv.matrix[,i]-expectations[i])
    }
  }
  else{
    cv_sums <- cv_sums * coeffs * (cv.matrix - expectations)
  }

  Y <- Y - cv_sums

  if(length(results)==7){
    results[[7]] <- Y * results[[6]]
    results[[6]] <- 1 # change w to 1 so that it does not applied
    # again in outer cv function.
  }else{
    results[[1]] <- Y
  }
  return(results)
}
