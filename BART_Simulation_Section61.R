# --------------------------------------------------------------------------------------- #
# Description: Generate RMSE for both ATE and CATE based on synthetic data (Section 6.1)  #
#              using BART instead of BCF.                                                  #
# --------------------------------------------------------------------------------------- #

# Load libraries
library(BART)
library(MASS)

# Save results here (Desktop/data2020_final_project/)
save_file <- "~/Desktop/data2020_final_project/"
filename <- "BART_Simulation_Section61"
dir.create(save_file, showWarnings = FALSE)

# Initialize
consolidated_results <- NULL
num_rep <- 50
sample_sizes <- c(250, 500)
tau_str <- c('heterogeneous', 'homogeneous')
mu_str <- c('linear', 'nonlinear')

# Function to generate data
generate_data <- function(n, tau_type, mu_type, seed = 1) {
  set.seed(seed)
  
  # Covariates
  X1 <- rnorm(n)
  X2 <- rnorm(n)
  X3 <- rnorm(n)
  X4 <- rbinom(n, 1, 0.5)
  X5 <- sample(1:3, n, replace = TRUE)
  X <- data.frame(X1, X2, X3, X4, X5)
  
  # g function
  g_func <- ifelse(X4 == 1, 2, ifelse(X4 == 0, -1, -4))
  
  # mu(x)
  if (mu_type == "linear") {
    mu <- 1 + g_func + X1 * X3
  } else {
    mu <- -6 + g_func + 6 * abs(X3 - 1)
  }
  
  # tau(x)
  if (tau_type == "homogeneous") {
    tau <- rep(3, n)
  } else {
    tau <- 1 + 2 * X2 * X5
  }
  
  # Propensity score
  s_mu <- sd(mu)
  pi_x <- 0.8 * pnorm(3 * mu / s_mu - 0.5 * X1) + 0.05 + runif(n, 0, 0.1)
  pi_x <- pmin(pmax(pi_x, 0), 1)
  
  # Treatment assignment
  Z <- rbinom(n, 1, pi_x)
  
  # Outcome
  Y <- mu + tau * Z + rnorm(n)
  
  return(list(
    y = Y,
    x = X,
    z = Z,
    pihat = pi_x,
    tau = tau,
    n = n,
    p = 5
  ))
}

# Function to calculate RMSE
rmse_func <- function(true, estimate) {
  sqrt(mean((true - estimate)^2))
}

# Begin simulation
for (n in sample_sizes) {
  for (mu_setting in mu_str) {
    for (tau_setting in tau_str) {
      for (rep in 1:num_rep) {
        
        # Generate data
        data <- generate_data(n = n, tau_type = tau_setting, mu_type = mu_setting, seed = rep)
        
        # Extract data
        y <- data$y
        x <- data$x
        z <- data$z
        pihat <- data$pihat
        tau_true <- data$tau
        
        # Prepare datasets for counterfactual prediction
        X1 <- data.frame(z = 1, x)  # everyone treated
        X0 <- data.frame(z = 0, x)  # everyone control
        X_full <- data.frame(z = z, x)  # observed
        
        # Fit BART
        fit.bart <- tryCatch({
          wbart(x.train = as.matrix(X_full), y.train = y, nskip = 1000, ndpost = 1000)
        }, error = function(e) NULL)
        
        if (!is.null(fit.bart)) {
          # Predict counterfactuals
          pred1 <- predict(fit.bart, newdata = as.matrix(X1))
          pred0 <- predict(fit.bart, newdata = as.matrix(X0))
          
          # CATE estimates = mean difference across MCMC draws
          tau_hat_samples <- pred1 - pred0
          tau_hat <- rowMeans(tau_hat_samples)
          
          # RMSE calculations
          rmse_cate <- rmse_func(tau_true, tau_hat)
          rmse_ate <- rmse_func(mean(tau_true), mean(tau_hat))
          
          SaveResults <- data.frame(
            Method = "BART",
            RMSE_CATE = rmse_cate,
            RMSE_ATE = rmse_ate,
            rep = rep,
            n = n,
            p = 5,
            tau_setting = tau_setting,
            mu_setting = mu_setting
          )
          
          consolidated_results <- rbind(consolidated_results, SaveResults)
        }
        
        # Save intermediate results
        save(consolidated_results, file = paste0(save_file, filename, ".RData"))
      }
    }
  }
}

