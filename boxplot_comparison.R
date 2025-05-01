# --------------------------------------------------------------------------------------- #
# Description: Combine and compare BCF, BART, and MLT simulation results                  #
#              Plot boxplots for RMSE_CATE and RMSE_ATE                                   #
# --------------------------------------------------------------------------------------- #

# Load libraries
library(dplyr)
library(ggplot2)
library(tidyverse)
library(stringr)
options(warn = 0)

# Set working directory
setwd("~/Desktop/data2020_final_project/")

# Load the results ----------------------------------------------------------------------------------------

load('BCF_Simulation_Section61.RData'); res_bcf = consolidated_results
load('BART_Simulation_Section61.RData'); res_bart = consolidated_results
load('MLT_Simulation_Section61.RData'); res_mlt = consolidated_results

# Combine all results into one dataframe
db = as.data.frame(rbind(res_bcf, res_bart, res_mlt))

# Organize details ----------------------------------------------------------------------------------------

rownames(db) = NULL
names(db) = c('Algorithm', 'RMSE_CATE', 'RMSE_ATE', 'rep', 'n', 'p', 'tau_str', 'mu_str')

db$RMSE_CATE = as.numeric(as.character(db$RMSE_CATE))
db$RMSE_ATE = as.numeric(as.character(db$RMSE_ATE))
db$rep = as.numeric(as.character(db$rep))
db$p = factor(db$p, levels = c('5'))  # Always 5 covariates in your simulation
db$tau_str = factor(db$tau_str, levels = c('heterogeneous', 'homogeneous'), 
                    labels = c(expression(paste(tau, '(x) = heterogeneous')), 
                               expression(paste(tau, '(x) = homogeneous'))))
db$mu_str = factor(db$mu_str, levels = c('linear', 'nonlinear'), 
                   labels = c(expression(paste(mu, '(x) = linear')), 
                              expression(paste(mu, '(x) = nonlinear'))))

db$Algorithm = factor(db$Algorithm, levels=c('BCF', 'BART', 'MLT'))

# Plot results ------------------------------------------------------------------------------------------

plot_rmse = function(sample_size, estimand){
  
  pdf(paste0('Comparison_', estimand, '_n', sample_size, '.pdf'), width = 10, height = 8)
  
  my_plot <- db %>%
    filter(n == sample_size) %>%
    ggplot(aes(x = Algorithm, y = get(paste0('RMSE_', estimand)), fill = Algorithm)) +
    geom_boxplot(outlier.size = 1) +
    labs(title = paste0('RMSE of ', estimand, ' (n = ', sample_size, ')'),
         y = 'RMSE', x = '') +
    theme_bw(base_size = 18) +
    theme(plot.title = element_text(size = 14, hjust = 0.5),
          legend.position = 'none',
          panel.grid.major = element_blank(),
          panel.grid.minor = element_blank(),
          strip.background = element_rect(fill = "white", size = 0.8)
    ) +
    facet_grid(mu_str ~ tau_str, scales = 'fixed', labeller = label_parsed)
  
  print(my_plot)
  dev.off()
  
}

# Generate plots
#plot_rmse(250, 'CATE')
#plot_rmse(250, 'ATE')
#plot_rmse(500, 'CATE')
#plot_rmse(500, 'ATE')

# Compute CI
summary_table <- db %>%
  group_by(Algorithm, n, tau_str, mu_str) %>%
  summarise(
    Mean_RMSE_ATE = mean(RMSE_ATE, na.rm = TRUE),
    CI_Lower_ATE = quantile(RMSE_ATE, 0.025, na.rm = TRUE),
    CI_Upper_ATE = quantile(RMSE_ATE, 0.975, na.rm = TRUE),
    
    Mean_RMSE_CATE = mean(RMSE_CATE, na.rm = TRUE),
    CI_Lower_CATE = quantile(RMSE_CATE, 0.025, na.rm = TRUE),
    CI_Upper_CATE = quantile(RMSE_CATE, 0.975, na.rm = TRUE)
  )


# Compute SDs per group (higher variability = worse fit)
variation_check <- db %>%
  group_by(Algorithm, n, tau_str, mu_str) %>%
  summarise(
    SD_ATE = sd(RMSE_ATE, na.rm = TRUE),
    SD_CATE = sd(RMSE_CATE, na.rm = TRUE)
  )



