# --------------------------------------------------------------------------------------- #
# Description: Generate RMSE for both ATE and CATE based on synthetic data (Section 6.1)  #
#              using Multilevel Test (MLT).                                               #
# --------------------------------------------------------------------------------------- #

# Load libraries
library(lme4)   # For mixed models
library(MASS)

# Save results here (Desktop/data2020_final_project/)
save_file <- "~/Desktop/data2020_final_project/"
filename <- "MLT_Simulation_Section61"
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
        
        # Fit Multilevel Model
        # Here, we assume a random intercept model: outcome ~ treatment + (1 | covariate cluster)
        # Since we don't have natural clusters, create pseudo-clusters based on X5
        x$Cluster <- as.factor(data$x$X5)  # cluster based on categorical X5
        
        fit.mlt <- tryCatch({
          lmer(y ~ z + (1 | Cluster), data = data.frame(y = y, z = z, Cluster = x$Cluster))
        }, error = function(e) NULL)
        
        if (!is.null(fit.mlt)) {
          # Estimated fixed effect for treatment z
          coef_summary <- summary(fit.mlt)$coefficients
          tau_hat <- rep(coef_summary["z", "Estimate"], n)  # constant estimate across observations
          
          # RMSE calculations
          rmse_cate <- rmse_func(tau_true, tau_hat)
          rmse_ate <- rmse_func(mean(tau_true), mean(tau_hat))
          
          SaveResults <- data.frame(
            Method = "MLT",
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

