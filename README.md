# Causal Inference: Comparing BCF, BART, and Multilevel Models

This project investigates the performance of causal inference models—**Bayesian Causal Forests (BCF)**, **Bayesian Additive Regression Trees (BART)**, and **Multilevel Linear Models (MLT)**—under both synthetic and real-world settings. We replicate the data-generating process described in [Hahn et al. (2020)](https://doi.org/10.1214/19-BA1175), and apply the models to the **National Medical Expenditure Survey (NMES)** dataset to estimate the causal effect of heavy smoking on healthcare costs.

---

## 🔬 Simulation Study (Hahn et al. 2020)
- **Data-generating process** includes 5 covariates:
  - \(X_1, X_2, X_3 \sim \mathcal{N}(0,1)\)
  - \(X_4 \sim \text{Bernoulli}(0.5)\), \(X_5 \sim \text{Categorical}\{1,2,3\}\)
- Outcome and treatment effect functions:
  - \(\mu(x) = 1 + g(X_5) + X_1X_3\) (linear) or \(-6 + g(X_5) + 6|X_3 - 1|\) (nonlinear)
  - \(\tau(x) = 3\) (homogeneous) or \(1 + 2X_2X_5\) (heterogeneous)
- Propensity score:
  \[
  \pi(x) = 0.8 \cdot \Phi\left(\frac{3\mu(x)}{\text{sd}(\mu)} - 0.5X_1\right) + 0.05 + \frac{u}{10}
  \]
- **50 simulations** per setting, sample sizes \(n = 250\) and \(500\)

### 🔧 Models Evaluated
- `bcf` package for Bayesian Causal Forests
- `wbart` for BART
- Linear mixed model for MLT

### 📊 Evaluation Metrics
- **RMSE** for ATE and CATE
- **95% Confidence Intervals** and **Standard Deviations**
- (Optional) **R²** for predictive accuracy

---

## 🏥 Real-World Analysis: NMES Dataset

We analyze the NMES dataset to estimate the causal effect of heavy smoking (>17 pack-years) on total medical expenditure.

- Treatment variable: binary indicator of heavy smoking
- Outcome: log-transformed `TOTALEXP`
- Covariates: age, race, education, income, marital status, etc.
- Models: BCF, BART, MLT
- Repeated 50 times to assess robustness


