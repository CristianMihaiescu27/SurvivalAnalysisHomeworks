set.seed(123) # reproduce results, can be removed for a more random simulation
library(survival)

find_cmax_any_prc <- function(target_prc, n_count, lambda) {
  if (target_prc == 0) {
    return(1.8 * (10^308)) # fun fact, this is about the biggest number R can handle, after that it's INF
  }

  times_values <- rexp(n_count, lambda) # generates a fresh batch of values each run
  cmax_values <- seq(1, 5 * max(times_values), by = 0.1) # make cmax based on the max of the values simulated
  empirical_censoring <- sapply(cmax_values, function(cmax) { # basically, for each cmax value
    # calculates what percentage of the simulated values would be censored, i.e. event time
    # smaller than censored time
    cnes <- runif(n_count, 0, cmax)
    mean(times_values > cnes)
  })
  # based on the ratios calculated, choose the cmax value with the closes percenetage to the
  # target from the list, as in, if the target is 50%, the cmax entry where the empirical
  # percentage is 49% or 51% is chosen, no safety for higher or lower
  best_cmax <- cmax_values[which.min(abs(empirical_censoring - target_prc))]

  list(cmax = best_cmax)
}


general_simulation_function <- function(simulation_r = 2000, n_count, target_prc, target_cmax, lambda) {
  naive_estimator <- 0
  mle_estimator <- 0

  naive_estimator_results <- vector(mode = "logical", length = simulation_r)
  mle_estimator_results <- vector(mode = "logical", length = simulation_r)

  censoring_proportions <- vector(mode = "logical", length = simulation_r)

  r_zero_na_counter <- vector(mode = "logical", length = simulation_r)

  for (run in 1:simulation_r) {
    # these are taken straight from the lecture slides, minus the if's
    events_t <- rexp(n_count, lambda)

    if (target_prc == 0) {
      # for 0 percentile case we can assure no censoring by setting the censor values to infinite
      censored <- rep(Inf, n_count)
    } else {
      # else censor uniformly from [0, empirical c_max values]
      censored <- runif(n_count, 0, target_cmax)
    }

    y <- pmin(events_t, censored)

    delta <- as.integer(events_t <= censored)

    naive_estimator <- 1 / mean(y)

    censoring_proportions[run] <- 1 - mean(delta)

    if (sum(delta) == 0) {
      mle_estimator <- NA
      r_zero_na_counter[run] <- TRUE
    } else {
      mle_estimator <- sum(delta) / sum(y)
    }

    naive_estimator_results[run] <- naive_estimator
    mle_estimator_results[run] <- mle_estimator
  }

  mean_naive <- mean(naive_estimator_results)
  mean_mle <- mean(mle_estimator_results)

  mse_naive <- mean((naive_estimator_results - lambda)^2)
  mse_mle <- mean((mle_estimator_results - lambda)^2, na.rm = TRUE)

  naive_bias <- mean(naive_estimator_results) - lambda
  mle_bias <- mean(mle_estimator_results, na.rm = TRUE) - lambda

  naive_variance <- mse_naive - naive_bias^2
  mle_variance <- mse_mle - mle_bias^2

  list(
    censoring_props_avg = mean(censoring_proportions), naive_estimator = mean_naive, mle_estimator = mean_mle,
    naive_bias = naive_bias, mle_bias = mle_bias,
    naive_variance = naive_variance, mle_variance = mle_variance, mse_naive = mse_naive,
    mse_mle = mse_mle, r_zero_cases = mean(r_zero_na_counter)
  )
}


censor_percentage1 <- 0.1
censor_percentage2 <- 0.5
censor_percentage3 <- 0


n1 <- 200
n2 <- 500

lambda <- 0.05


# censoring dist family = uniform (for now)

times <- rexp(n1, lambda)
times2 <- rexp(n2, lambda)

# find cmaxes, assignment says calibration on 1000 values, so I'll just hardcode that

calibration_cmax_10prc_200_entries <- find_cmax_any_prc(censor_percentage1, 1000, lambda)
calibration_cmax_50prc_200_entries <- find_cmax_any_prc(censor_percentage2, 1000, lambda)
calibration_cmax_0prc_200_entries <- find_cmax_any_prc(censor_percentage3, 1000, lambda)


cmax_10prc <- calibration_cmax_10prc_200_entries$cmax # cmax for 10 percentage censoring, 200 values
cmax_50prc <- calibration_cmax_50prc_200_entries$cmax # cmax for 50 percentage censoring, 200 values
cmax_0prc <- calibration_cmax_0prc_200_entries
# do simulations
simulation_r <- 2000

simulation_10prc_200_entries <- general_simulation_function(
  simulation_r = simulation_r, n1, censor_percentage1,
  cmax_10prc, lambda
)

simulation_50prc_200_entries <- general_simulation_function(
  simulation_r = simulation_r, n1, censor_percentage2,
  cmax_50prc, lambda
)

simulation_10prc_500_entries <- general_simulation_function(
  simulation_r = simulation_r, n2, censor_percentage1,
  cmax_10prc, lambda
)

simulation_50prc_500_entries <- general_simulation_function(
  simulation_r = simulation_r, n2, censor_percentage2,
  cmax_50prc, lambda
)

simulation_0prc_200_entries <- general_simulation_function(
  simulation_r = simulation_r, n1, censor_percentage3,
  cmax_0prc, lambda
)

simulation_0prc_500_entries <- general_simulation_function(
  simulation_r = simulation_r, n2, censor_percentage3,
  cmax_0prc, lambda
)

print("10%, n = 500\n")
print(simulation_10prc_500_entries)

print("50%, n = 500\n")
print(simulation_50prc_500_entries)

print("0%, n = 500\n")
print(simulation_0prc_500_entries)
