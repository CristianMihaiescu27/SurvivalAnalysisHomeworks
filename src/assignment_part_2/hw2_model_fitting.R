# Step 1: Load Simulated Data
# The dataset contains 4 simulation scenarios:
# - Two sample sizes: n = 200 and n = 500 patients
# - Two loss-to-follow-up rates: 5% and 10%
# - Each scenario consists of R = 2000 independent simulation runs
# - Each patient observation has 6 variables:
#   days, age, comorbidities, etiology, observed time, and event indicator

# Step 2: Address Research Question 1 (Log-Logistic Model Accuracy)
# Objective: Evaluate how accurately the true parameters are estimated
# across sample sizes (200 vs 500) and loss-to-follow-up (5% vs 10%).
# For each of the 4 scenarios:
#   For each simulation run (1 to 2000):
#     Fit the true log-logistic model using all covariates:
#       response: survival time and event indicator
#       predictors: days to treatment, age, comorbidities, and etiology
#     Extract and store the estimated regression coefficients
#   For each parameter, compute performance metrics across all 2000 runs:
#     - Bias: average estimated value minus true value
#     - Variance: variance of the estimated values across runs
#     - Mean Squared Error: sum of squared bias and variance

# Step 3: Address Research Question 2 (Model and Confounder Misspecification)
# Objective: Measure the bias introduced by misspecifying the baseline hazard
# or omitting the confounder age.
# Part A: Misspecified Baseline Hazard (Weibull Model)
#   For each simulation run:
#     Fit a Weibull model using all covariates
#     Extract estimated regression coefficients
#     Calculate bias by comparing estimates against true parameter values
#     Evaluate how the inability to capture the early hazard peak affects
#     the coefficient estimates
# Part B: Omitted Confounder (Leave Out Age)
#   For each simulation run:
#     Fit a log-logistic model omitting age as a predictor
#     Extract estimated coefficients for remaining predictors
#     Calculate bias, specifically analyzing how leaving out age distorts
#     the effects of etiology and comorbidities
