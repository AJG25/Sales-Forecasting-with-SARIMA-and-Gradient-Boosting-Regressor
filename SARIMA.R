# Load libraries
library(forecast)
library(tidyverse)

# Load datasets
train_data <- read.csv('sales_train_validation.csv')
test_data <- read.csv('sales_test_validation.csv')
calendar <- read.csv('calendar.csv')
sell_prices <- read.csv('sell_prices.csv')
submission <- read.csv('sample_submission.csv')

# Filter data for FOODS_3 and TX_3
filtered_train <- train_data %>% 
  filter(str_detect(id, "FOODS_3") & str_detect(id, "TX_3")) %>% 
  select(starts_with("d_")) %>% 
  summarise_all(sum)

filtered_test <- test_data %>% 
  filter(str_detect(id, "FOODS_3") & str_detect(id, "TX_3")) %>% 
  select(starts_with("d_")) %>% 
  summarise_all(sum)

# Combine train and test sets for validation
train_series <- as.numeric(filtered_train[1, ])
test_series <- as.numeric(filtered_test[1, ])
full_series <- c(train_series, test_series)

# Prepare the time series for training
time_series <- ts(train_series, start = c(2011, 1), frequency = 365)

# Fit SARIMA model on training data
fit <- auto.arima(time_series, seasonal = TRUE)
summary(fit)

# Forecast for the test period
forecast_length <- length(test_series)
forecast_result <- forecast(fit, h = forecast_length)

# Calculate RMSE for test set
rmse <- sqrt(mean((test_series - forecast_result$mean)^2))
cat("RMSE on Test Set:", rmse, "\n")

# Convert test series into a time series object for alignment
test_ts <- ts(test_series, start = c(2016, 1), frequency = 365)

# Plot the forecast vs actual values
autoplot(forecast_result) +
  autolayer(test_ts, series = "Actual", PI = FALSE) +
  ggtitle("SARIMA Forecast vs Actual Sales on Test Set") +
  xlab("Date") +
  ylab("Sales") +
  theme_minimal()

# Save the plot as a file (optional)
ggsave("SARIMA_Forecast_vs_Actual.png")

