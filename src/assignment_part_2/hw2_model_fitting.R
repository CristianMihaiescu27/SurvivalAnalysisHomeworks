# Step 1: Load Simulated Data
# The dataset contains 4 simulation scenarios:
# - Two sample sizes: n = 200 and n = 500 patients
# - Two loss-to-follow-up rates: 5% and 10%
# - Each scenario consists of R = 2000 independent simulation runs
# - Each patient observation has 6 variables:
#   days, age, comorbidities, etiology, observed time, and event indicator

# Step 2: Fit Models for Research Question 1 (True Log-Logistic Model)
# Objective: Fit the correctly specified model across all 4 scenarios.
# For each of the 4 scenarios:
#   For each simulation run (1 to 2000):
#     Fit the log-logistic survival model using all covariates:
#       response: observed time and event indicator
#       predictors: days to treatment, age, comorbidities, and etiology
#     Extract and store the estimated regression coefficients
#     and shape parameter for this run

# Step 3: Fit Models for Research Question 2 (Misspecified Models)
# Objective: Fit alternative models to evaluate misspecification.
# Part A: Misspecified Baseline Hazard (Weibull Model)
#   For each simulation run:
#     Fit a Weibull survival model using all covariates:
#       response: observed time and event indicator
#       predictors: days to treatment, age, comorbidities, and etiology
#     Extract and store the estimated regression coefficients
# Part B: Omitted Confounder (Leave Out Age)
#   For each simulation run:
#     Fit a log-logistic survival model omitting age:
#       response: observed time and event indicator
#       predictors: days to treatment, comorbidities, and etiology
#     Extract and store the estimated regression coefficients

# Step 4: Save Simulation Results
# Save all extracted estimates across runs and scenarios to disk
