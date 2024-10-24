# The code below is more ARIMA modeling so that we can create a graph that looks at and forecasts
# for just Vaccination Coverage Percentage 

# Loading libraries 
library(forecast)
library(dplyr)

# Loading data
df <- read.csv("vaccine.csv")

# Cleaning data and getting rid of columns not needed in this analysis 
df_2columns <- df %>% select(-Cases, -Sample.Size, -X95..CI....)
# Getting rid of rows with NR (not reported)
df_cleaned <- df_2columns %>%
  filter_all(all_vars(. != "NR"))
# Turning Estimate column to numeric 
df_cleaned$Estimate <- as.numeric(df_cleaned$Estimate)
df_cleaned <- df_cleaned %>% select(-Estimate....)
# Adding day to the Date column, so that formatting works 
df_cleaned$Date <- paste0(df_cleaned$Date, "-01")
df_cleaned$Date <- as.Date(df_cleaned$Date, format = "%Y-%m-%d")

# Converting Estimate to a time series object
start_year <- as.numeric(format(min(df_cleaned$Date), "%Y"))
end_year <- as.numeric(format(max(df_cleaned$Date), "%Y"))
time_series_data <- ts(df_cleaned$Estimate, start = c(start_year, 1), frequency = 12)

# ARIMA modeling
model <- auto.arima(time_series_data)
print(model)

# Forecast future vaccination coverage for the next 10 months 
forecast_data <- forecast(model, 10)
print(forecast_data)

# Fixing so that X-axis is years 
plot(forecast_data, main = "Forecasting of Vaccination Coverage", 
     ylab = "Predicted Vaccination Coverage", xlab = "Year", ylim = c(0, 50))



