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
lossToFollowUpVector <- c(lossFollowUp1, lossFollowUp2)

#generation
generateData <- function(entries){
  D <- pgamma(entries, shape = 2, scale = 2)
  A <- pmin(pmax(rnorm(entries, 45, 15), 18), 85)
  K <- rpois(entries, exp(-2.75+0.05*A))
  E <- rbinom(entries, 1, plogis(-3.9 + 0.06 * A)) 
  data.frame(days = D, age = A, nrComor = K, damage = E)
}

drawT <- function(convariate, betaVal, gam){
  lambda <- exp(betaVal["b0"] + betaVal["bD"]*convariate[["days"]] + betaVal["bA"]*convariate[["age"]] + betaVal["bK"]*convariate[["nrComor"]] + 
                  betaVal["bE"]*convariate[["damage"]])
  U <- runif(nrow(convariate))
  T <- lambda * (U/(1-U))^(1/gam)
}

#generate censoring
#type i: patients that are alive past 90 days are censored (i.e. value  >= 90 is censored I think)
#type ii: loss to follow-up (< cmax)
findCmax <- function(targetLoss, nCount, cutoff, gamVal, betVal){ #targetLoss is either 0.05 (for 5%) or 0.1 (for 10%)
#  if(targetPrc == 0){
#    return(1.8*(10^308)) #fun fact, this is about the biggest number R can handle, after that it's INF
#  }
  
  cmaxSimulationData <- generateData(nCount) #around 1 million maybe for the simluation for cmax, arbitrary choice though
  cmaxSimulationTimes <- drawT(cmaxSimulationData, betVal, gamVal)
  minTimes <- pmin(cmaxSimulationTimes, cutoff) #smallest values for each position between the value at said position and the cutoff, 
  #i.e. remove patients that got past cutoff
  func <- function(proposedCmax) {
    mean(pmin(minTimes, proposedCmax)/proposedCmax) - targetLoss
  }
  uniroot(func, interval = c(5, max(cmaxSimulationTimes)), tol = 0.5)$root
}

cmaxData <- lapply(lossToFollowUpVector, findCmax, nCount = n1*n2*10, cutoff = tau, gamVal = gammaVal, betVal = betaValues)
names(cmaxData) <- lossToFollowUpVector
print(cmaxData)
