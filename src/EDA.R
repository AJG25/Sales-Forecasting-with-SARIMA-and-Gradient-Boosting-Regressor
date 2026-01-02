library(tidyverse)
library(tsibble)
library(lubridate)
library(ggplot2)
library(feasts)
library(dplyr)
library(fable)

sales_data <- read.csv("sales_train_validation.csv")
calendar <- read_csv(file.choose("calendar.csv"))
head(sales_data)
#adjust sales to long
sales_long <- sales_data %>%
  pivot_longer(cols = starts_with("d_"), 
               names_to = "date", 
               values_to = "sales") 

head(sales_long)
head(calendar)

#####mapping:
# 'date' column changed to character
sales_long$date <- as.character(sales_long$date)

#d_1, d_2 -> to actual dates (from the calendar)
date_mapping <- setNames(calendar$date, paste0("d_", 1:nrow(calendar)))

#connect
sales_long$date <- date_mapping[sales_long$date]

#date var changed to date format 
sales_long$date <- as.Date(sales_long$date, format = "%m/%d/%Y")
head(sales_long)

# calendar$date to date form
calendar$date <- as.Date(calendar$date, format = "%m/%d/%Y")

#join calendar and sales
sales_long <- sales_long %>%
  left_join(calendar, by = "date")
head(sales_long)

######## exploration

#sumed sales by day
aggregated_sales <- sales_long %>%
  group_by(date) %>%
  summarise(total_sales = sum(sales, na.rm = TRUE))
head(aggregated_sales)

#summed data to tsibble
aggregated_sales_tsibble <- aggregated_sales %>%
  as_tsibble(index = date)
head(aggregated_sales_tsibble)

#autoplot of total sales
aggregated_sales_tsibble %>%
  autoplot(total_sales) +
  labs(title = "Total Sales Over Time", x = "Date", y = "Total Sales") +
  theme_minimal()

#gg_season-yeary
aggregated_sales_tsibble %>%
  gg_season(total_sales) +
  labs(title = "Seasonal Plot of Total Sales", y = "Total Sales")

#gg season weekly- not used
aggregated_sales_tsibble %>%
  gg_season(total_sales, period = "week") + 
  labs(title = "Weekly Seasonality", y = "Total Sales") +
  theme_minimal()

#gg season monthly-not used
aggregated_sales_tsibble %>%
  gg_season(total_sales, period = "month") +
  labs(title = "Monthly Seasonality", y = "Total Sales")

#Decompose with stl
decomposition <- aggregated_sales_tsibble %>%
  model(stl = STL(total_sales ~ trend(window = 25) + season(window = 365)))

# Plot decomposition
components(decomposition) %>%
  autoplot() +
  labs(title = "Decomposition of Total Sales (Trend, Seasonality, Residuals)")

### acf and lagggg
# ACF autoplot
aggregated_sales_tsibble %>%
  pull(total_sales) %>%
  acf(lag.max = 365) %>%
  autoplot() + 
  labs(title = "ACF of Total Sales", 
       x = "Lag", 
       y = "Autocorrelation") +
  theme_minimal()

#lag plotws
aggregated_sales_tsibble %>%
  gg_lag(total_sales, geom = "point",  show.legend = FALSE) + 
  labs(title = "Lag Scatter Plot of Total Sales", 
       x = "Lag", 
       y = "Total Sales") +
  theme_minimal()


# Forecasting Analysis with ARIMA and ETS

# Fit ARIMA model
arima_model <- aggregated_sales_tsibble %>%
  model(ARIMA(total_sales))

# View ARIMA model summary
report(arima_model)

# Generate ARIMA forecasts for the next 28 days
arima_forecast <- arima_model %>%
  forecast(h = "28 days")

# Plot ARIMA forecast
arima_forecast %>%
  autoplot(aggregated_sales_tsibble) +
  labs(title = "ARIMA Forecast for Total Sales",
       x = "Date",
       y = "Total Sales") +
  theme_minimal()

# Fit ETS (Exponential Smoothing) model
ets_model <- aggregated_sales_tsibble %>%
  model(ETS(total_sales))

# View ETS model summary
report(ets_model)

# Generate ETS forecasts for the next 28 days
ets_forecast <- ets_model %>%
  forecast(h = "28 days")

# Plot ETS forecast
ets_forecast %>%
  autoplot(aggregated_sales_tsibble) +
  labs(title = "ETS Forecast for Total Sales",
       x = "Date",
       y = "Total Sales") +
  theme_minimal()

# Combine forecasts for comparison
combined_forecasts <- bind_rows(
  arima_forecast %>% mutate(Model = "ARIMA"),
  ets_forecast %>% mutate(Model = "ETS")
)

# Plot combined forecasts
combined_forecasts %>%
  autoplot(aggregated_sales_tsibble, level = NULL) +
  facet_wrap(~Model, scales = "free_y") +
  labs(title = "Comparison of ARIMA and ETS Forecasts",
       x = "Date",
       y = "Total Sales") +
  theme_minimal()

# Evaluate accuracy of the models
accuracy_metrics <- accuracy(arima_model, aggregated_sales_tsibble) %>%
  bind_rows(accuracy(ets_model, aggregated_sales_tsibble)) %>%
  mutate(Model = c("ARIMA", "ETS"))

# Print accuracy metrics
print(accuracy_metrics)
ggsave("arima_forecast.png", plot = last_plot(), width = 8, height = 5)
ggsave("ets_forecast.png", plot = last_plot(), width = 8, height = 5)
ggsave("combined_forecasts.png", plot = last_plot(), width = 10, height = 6)


