# Time-Series-Sales-Forecasting-with-SARIMA-and-Gradient-Boosting

## Project Overview
This project's aim was to forecast daily product-level sales for the food category at selected stores using statistical and machine learning methods. The goal was to predict sales 28 days ahead while accounting for seasonality, events, and temporal patterns, using both SARIMA and Gradient Boosting models.

---

## Technologies
- R: forecast, tseries, tidyverse (SARIMA modeling)
- Python: scikit-learn, Pandas, NumPy (Gradient Boosting Regressor)
- Data handling: CSV processing, feature engineering

---

## Methods & Techniques
- **SARIMA (Seasonal ARIMA)**: Captures trend, seasonality, autocorrelation  
- **Gradient Boosting Regressor (GBR)**: Handles non-linearities and event effects  
- **Feature Engineering**: One-hot encoded date features, event alignment, item-level modeling  
- **Evaluation & Tuning**: Hyperparameter tuning, cross-validation, performance comparison vs baseline

---

## Results & Key Takeaways
- GBR outperformed SARIMA for daily sales prediction, particularly in capturing non-linear patterns and event effects  
- SARIMA served as a robust baseline for seasonality and trend  
- Modular pipelines and item-level modeling improved reproducibility and interpretability
