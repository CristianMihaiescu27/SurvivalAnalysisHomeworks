set.seed(123)

beta_values <- c(b_0 = 5.8, b_d = -0.1, b_a = -0.02, b_k = -0.25, b_e = -0.7)
gamma_val <- 1.1
phi_vals <- c(p_d = 0.9, p_a = 0.98, p_k = 0.78, p_e = 0.5)
tau <- 90 # days limit

# simulation params
n_1 <- 200
n_2 <- 500
sim_runs <- 2000
loss_follow_up_1 <- 0.05
loss_follow_up_2 <- 0.1
loss_to_follow_up_vector <- c(loss_follow_up_1, loss_follow_up_2)

# generation
generate_data <- function(entries) {
  d <- rgamma(entries, shape = 2, scale = 2)
  a <- pmin(pmax(rnorm(entries, 45, 15), 18), 85)
  k <- rpois(entries, exp(-2.75 + 0.05 * a))
  e <- rbinom(entries, 1, plogis(-3.9 + 0.06 * a))
  data.frame(days = d, age = a, nr_comor = k, damage = e)
}

draw_t <- function(covariates, beta_values, gamma_val) {
  lambda <- exp(
    beta_values["b_0"] +
      beta_values["b_d"] * covariates[["days"]] +
      beta_values["b_a"] * covariates[["age"]] +
      beta_values["b_k"] * covariates[["nr_comor"]] +
      beta_values["b_e"] * covariates[["damage"]]
  )
  u <- runif(nrow(covariates))
  lambda * (u / (1 - u))^(1 / gamma_val)
}

# generate censoring
# type i: patients that are alive past 90 days are censored (i.e. value >= 90 is censored)
# type ii: loss to follow-up (< cmax)
find_cmax <- function(target_loss, n_count, cutoff, gamma_val, beta_values) {
  # Around 1 million entries for the simulation for cmax
  cmax_sim_data <- generate_data(n_count)
  cmax_sim_times <- draw_t(cmax_sim_data, beta_values, gamma_val)
  # Smallest values for each position between the value at said position and cutoff (remove past cutoff)
  min_times <- pmin(cmax_sim_times, cutoff)
  loss_objective <- function(proposed_cmax) {
    mean(pmin(min_times, proposed_cmax) / proposed_cmax) - target_loss
  }
  uniroot(loss_objective, interval = c(5, max(cmax_sim_times)), tol = 0.5)$root
}

cmax_data <- lapply(
  loss_to_follow_up_vector,
  find_cmax,
  n_count = n_1 * n_2 * 10,
  cutoff = tau,
  gamma_val = gamma_val,
  beta_values = beta_values
)
names(cmax_data) <- loss_to_follow_up_vector
print(cmax_data)
