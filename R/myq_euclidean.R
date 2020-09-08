myq_euclidean <- function(zm,point=c(1,2,1)){
  # returns Euclidean distance of iid N(0,1) vector to "point"
  d <- length(point)
  sumDist2 <- 0
  for(i in 1:d) sumDist2 <- sumDist2 + (point[i]-zm[,i])^2

  returning_list = list(sqrt(sqrt(sumDist2)))
  return(returning_list)
}
