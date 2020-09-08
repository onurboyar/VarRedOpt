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
