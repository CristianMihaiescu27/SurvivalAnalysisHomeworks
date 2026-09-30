set.seed(123)

betaValues <- c(b0 = 5.8, bD = -0.1, bA =-0.02, bK = -0.25, bE = -0.7)
gammaVal <- 1.1
phiVals <- c(pD = 0.9, pA = 0.98, pK = 0.78, pE = 0.5)
tau <- 90 #days limit

#simulation params
n1 <- 200
n2<- 500
simRuns <- 2000
lossFollowUp1<- 0.05
lossFollowUp2<- 0.1

#generation
generateData <- function(entries){
  D <- pgamma(n, shape = 2, scale = 2)
  A <- pmin(pmax(rnorm(n, 45, 15), 18), 85)
  K <- rpois(n, exp(-2.75+0.05*A))
  E <- rbinom(n, 1, plogis(-3.9 + 0.06 * A)) 
  data.frame(days = D, age = A, nrComor = K, damage = E)
}

drawT <- function(convariate, betaVal, gam){
  lambda <- exp(betaVal["b0"] + betaVal["bD"]*convariate["days"] + betaVal["bA"]*convariate["age"] + betaVal["bK"]*convariate["nrComor"] + 
                  betaVal["bE"]*convariate["damage"])
  U <- runif(nrow(convariate))
  T <- lambda * (U/(1-U))^(1/gam)
}