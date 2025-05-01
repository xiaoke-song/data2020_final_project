# --------------------------------------------------------------------------------------- #
# Description: Plot histograms of RMSE_CATE and RMSE_ATE for BCF, BART, and MLT           #
# --------------------------------------------------------------------------------------- #

# Load libraries
library(ggplot2)
library(dplyr)
library(viridis)
options(warn = 0)

# Set working directory
setwd("~/Desktop/data2020_final_project/")

# Load simulation results
load("BCF_Simulation_Section61.RData"); res_bcf <- consolidated_results
load("BART_Simulation_Section61.RData"); res_bart <- consolidated_results
load("MLT_Simulation_Section61.RData"); res_mlt <- consolidated_results

# Combine into one dataframe
res_all <- rbind(res_bcf, res_bart, res_mlt)
rownames(res_all) <- NULL
names(res_all) <- c("Algorithm", "RMSE_CATE", "RMSE_ATE", "rep", "n", "p", "tau_str", "mu_str")

# Ensure numeric
res_all$RMSE_CATE <- as.numeric(res_all$RMSE_CATE)
res_all$RMSE_ATE <- as.numeric(res_all$RMSE_ATE)
res_all$Algorithm <- factor(res_all$Algorithm, levels = c("BCF", "BART", "MLT"))

# Function to plot histograms
plot_histograms <- function(metric, sample_size) {
  df <- res_all %>%
    filter(n == sample_size)
  
  ggplot(df, aes(x = .data[[paste0("RMSE_", metric)]], fill = Algorithm)) +
    geom_histogram(
      position = "identity",
      bins = 30,
      alpha = 0.4,
      color = "black"
    ) +
    facet_grid(mu_str ~ tau_str, labeller = label_parsed) +
    scale_fill_viridis_d(option = "D", begin = 0.2, end = 0.9) +
    labs(
      title = paste("Histogram of RMSE for", metric),
      subtitle = paste("Sample size n =", sample_size),
      x = paste("RMSE", metric),
      y = "Frequency",
      fill = "Algorithm"
    ) +
    theme_minimal(base_size = 16) +
    theme(
      plot.title = element_text(hjust = 0.5, face = "bold", size = 18),
      plot.subtitle = element_text(hjust = 0.5, size = 14),
      legend.position = "bottom",
      panel.grid.minor = element_blank(),
      strip.text = element_text(size = 14)
    )
}



# Save histograms as PDF
pdf("Histogram_CATE_n250.pdf", width = 10, height = 8)
print(plot_histograms("CATE", 250))
dev.off()

pdf("Histogram_ATE_n250.pdf", width = 10, height = 8)
print(plot_histograms("ATE", 250))
dev.off()

pdf("Histogram_CATE_n500.pdf", width = 10, height = 8)
print(plot_histograms("CATE", 500))
dev.off()

pdf("Histogram_ATE_n500.pdf", width = 10, height = 8)
print(plot_histograms("ATE", 500))
dev.off()