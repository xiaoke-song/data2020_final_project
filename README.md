# Causal Inference with BCF, BART, and Multilevel Models

This project compares the performance of three causal inference models—**Bayesian Causal Forests (BCF)**, **Bayesian Additive Regression Trees (BART)**, and **Multilevel Linear Models (MLT)**—through a structured simulation study and an application to real-world healthcare data from the **National Medical Expenditure Survey (NMES)**. We follow the simulation setup in the "paper_to_read" and evaluate model performance using metrics such as RMSE, confidence intervals, and standard deviation.

---

## Simulation Study

We simulate datasets with \(n = 250\) and \(500\) using five covariates:
- \(X_1, X_2, X_3 \sim \mathcal{N}(0,1)\)  
- \(X_4 \sim \text{Bernoulli}(0.5)\)  
- \(X_5 \in \{1, 2, 3\}\) categorical  

Outcome model \(\mu(x)\) and treatment effect \(\tau(x)\) are defined as:
- **Linear**: \(\mu(x) = 1 + g(X_5) + X_1X_3\)
- **Nonlinear**: \(\mu(x) = -6 + g(X_5) + 6|X_3 - 1|\)
- **Homogeneous**: \(\tau(x) = 3\)
- **Heterogeneous**: \(\tau(x) = 1 + 2X_2X_5\)

The **propensity score** is known and generated as:
\[
\pi(x) = 0.8 \cdot \Phi\left(\frac{3\mu(x)}{\text{sd}(\mu)} - 0.5X_1\right) + 0.05 + \frac{u}{10}
\]
where \(u \sim \text{Uniform}(0, 1)\).  
The observed outcome is \(Y = \mu(x) + \tau(x)Z + \epsilon\), with \(\epsilon \sim \mathcal{N}(0,1)\).

Each scenario is repeated 50 times to assess stability and robustness.

---

## NMES Dataset Analysis

We apply all three models to the NMES dataset to estimate the causal effect of **heavy smoking** (defined as >17 pack-years) on total medical expenditures:
- **Treatment**: Binary indicator of heavy smoking  
- **Outcome**: Log-transformed `TOTALEXP`  
- **Covariates**: Age, gender, race, education, income, marital status, smoking history, etc.

Each model is run 50 times to account for sampling variability.

---

## Evaluation Metrics

We assess models using:
- **RMSE** for ATE and CATE
- **95% Confidence Intervals** for CATE RMSE
- **Standard Deviation** of RMSE across replications
- **Optional**: \(R^2\) to measure predictive accuracy (if tau estimates are retained)
