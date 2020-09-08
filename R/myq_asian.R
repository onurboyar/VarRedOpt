myq_asian <- function(zm,K=100,ti=(1:3)/12,r=0.05,sigma=0.1,S0=100){
  # Simulation algorithm for Asian option
  # n... number of repetitions for the simulation
  # ti .. vector of control points. the last entry is the maturity T
  # Calculates expected value for the option
  # stores the last price is seperate variable named last_price
  # stores prdocuts of prices in a variable named prodSt

  # Returns:
  # ... last price , expected value, prodSt and Y in a list.

  d <- length(ti)
  dt <- ti[1]
  St <- S0*exp((r-sigma^2/2)*dt + sigma*sqrt(dt)*as.matrix(zm)[,1])
  sumSt <- St
  prodSt <- St
  # check if dimension is bigger than 1
  if(d>1){
    for(i in 2:d){
      dt <- ti[i] - ti[i-1]
      St <- St*exp((r-sigma^2/2)*dt + sigma*sqrt(dt)*zm[,i])
      sumSt <- sumSt + St
      prodSt <- prodSt * St
    }
  }
  # calculate asian option prices
  Y <- exp(-r*ti[d])* pmax(sumSt/d-K,0)
  # store the last price
  last_price <- St
  # calculate expected value
  E_z <- S0*exp(r*ti[d])
  # store them in a list
  returning_list = list(Y, last_price, E_z, prodSt)
  return(returning_list)
}
