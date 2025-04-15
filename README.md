# Time-Series-Sales-Forecasting-with-SARIMA

The project is focused on forecasting product-level sales for the food category at selected store using statistical and machine learning methods. It applies time series forecasting on real-world retail data. Different modeling approaches for predicting daily sales 28 days ahead are tested, incorporating seasonality, event effects, and temporal patterns.

## Data

- Daily sales: `sales_train_validation.csv`
- Calendar: `calendar.csv`
- Test data: `sales_test_validation.csv`

## Methods & Tools

### Time Series Modeling (R)
- **SARIMA** (Seasonal ARIMA): Captures trend, seasonality, and autocorrelation (baseline model)
- Libraries: `forecast`, `tseries`, `tidyverse`

### Machine Learning (Python)
- **Gradient Boosting Regressor (GBR)**: Tree-based regression with feature engineering
- Stack: `scikit-learn`, `pandas`, `numpy`
- One-hot encoded date features, separate model per item

## Evaluation

Metric: **RMSE (Root Mean Squared Error)** on 28-day forecast

| Model   | Avg. RMSE |
|---------|-----------|
| Naive   | 2.6       |
| **SARIMA**| ~321    |
| GBR     | 2.2       |

- GBR outperformed SARIMA, handling non-linearity and event-based patterns better.
- SARIMA used as baseline for capturing seasonality/trends.

## Key Features

- Data preprocessing with calendar/event alignment
- Item-level modeling
- Hyperparameter tuning
- Clean and modular pipelines

## Future Work

- Extend to other categories/stores
- Incorporate deep learning
- Add external data (promotions, pricing)

