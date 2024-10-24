

### INSTALL PACKAGES AND LIBRARIES ###

install.packages("dplyr")
library(dplyr)
library(ggplot2)
library(zoo)

# Install ARIMA Model

install.packages("forecast", type = "binary")
library(forecast)


### CLEAN AND SEPARATE DATA INTO TWO DATASETS ###

data <- Vaccination_and_cases

# New datasets from specific estimate and cases columns

new_data1 <- data.frame(date = data$Date, estimate = data$`Estimate (%)`)
new_data2 <- data.frame(date = data$Date, covid = data$Cases)

# Check the column names
names(new_data1)

# Print the first few rows to inspect the data
head(new_data1)

# Filter out rows where 'estimate' is 'NR' or 'NR †'
clean_flu <- new_data1 %>% filter(!(estimate %in% c("NR", "NR †")))

# Filter out rows where 'covid' is 'NR'
clean_covid <- subset(new_data2, covid != "NR")

# Print the cleaned datasets
print(clean_flu)
print(clean_covid)




### PLOT INFLUENZA VACCINE COVERAGE OVER TIME ###

head(clean_flu$date)
# Convert 'estimate' column to numeric if necessary
clean_flu$estimate <- as.numeric(clean_flu$estimate)
head(clean_flu$estimate)

# Remove rows with NA values in 'estimate' column
clean_flu <- clean_flu[!is.na(clean_flu$estimate), ]

# Inspect the date column
head(clean_flu$date)

# Convert 'date' column to yearmon format
clean_flu$date <- as.yearmon(clean_flu$date, format = "%Y-%m")

# Check for NA values in the date column
sum(is.na(clean_flu$date))   # should be 0

# Ensure there are no NA values in the date column
clean_flu <- clean_flu[!is.na(clean_flu$date), ]

head(clean_flu) # dates now in date format instead of string

# Fit an ARIMA model
ts_flu <- ts(clean_flu$estimate, start = c(2013, 1), frequency = 12)
model_flu <- auto.arima(ts_flu)
forecasted_values_flu <- forecast(model_flu, h = 12)

# Create a data frame for forecasted values
forecast_dates <- seq(from = max(clean_flu$date) + 1/12, by = 1/12, length.out = 12)
forecast_data <- data.frame(date = forecast_dates, estimate = forecasted_values_flu$mean)

# Combine actual and forecasted data
combined_data <- rbind(clean_flu, forecast_data)

# Convert Covid date column from string format to date format
head(clean_covid$date)
# Convert 'covid' column to numeric if necessary
clean_covid$covid <- as.numeric(clean_covid$covid)
head(clean_covid$covid)

# Remove rows with NA values in 'covid' column
clean_covid <- clean_covid[!is.na(clean_covid$covid), ]

# Inspect the date column
head(clean_covid$date)

# Convert 'date' column to yearmon format
clean_covid$date <- as.yearmon(clean_covid$date, format = "%Y-%m")

# Check for NA values in the date column
sum(is.na(clean_covid$date))   # should be 0

# Ensure there are no NA values in the date column
clean_covid <- clean_covid[!is.na(clean_covid$date), ]

head(clean_covid)





### MERGE DATASETS ON DATE COLUMN ###

# Merge the datasets on the 'date' column

# Verify the conversion
class(clean_flu$date)
class(clean_covid$date)
# both should be "yearmon"

combined_data <- merge(clean_flu, clean_covid, by = "date", all = TRUE)
head(combined_data)

# Plot the data using ggplot2
ggplot(combined_data, aes(x = as.Date(date))) +
  geom_line(aes(y = estimate, color = "Flu Vaccination Estimates")) +
  geom_line(aes(y = covid / max(combined_data$covid, na.rm = TRUE) * 100, color = "COVID-19 Cases")) +
  scale_y_continuous(
    name = "Flu Vaccination Estimates (%)",
    limits = c(0, 100),
    sec.axis = sec_axis(~ . * max(combined_data$covid, na.rm = TRUE) / 100, name = "COVID-19 Cases")
  ) +
  labs(title = "Flu Vaccination Estimates and COVID-19 Cases Over Time",
       x = "Date") +
  theme_minimal() +
  scale_color_manual(values = c("Flu Vaccination Estimates" = "blue", "COVID-19 Cases" = "red")) +
  theme(legend.position = "bottom")


### ARIMA ANALYSIS AND FORECASTS ###


# Fit ARIMA model for flu vaccination data
ts_flu <- ts(clean_flu$estimate, start = c(2013, 1), frequency = 12)
model_flu <- auto.arima(ts_flu)
forecasted_values_flu <- forecast(model_flu, h = 12)

# Fit ARIMA model for COVID-19 case data
ts_covid <- ts(clean_covid$covid, start = c(2013, 1), frequency = 12)
model_covid <- auto.arima(ts_covid)
forecasted_values_covid <- forecast(model_covid, h = 12)

# Create forecast data frames
forecast_dates <- seq(from = max(clean_flu$date) + 1/12, by = 1/12, length.out = 12)
forecast_data_flu <- data.frame(date = forecast_dates, estimate = forecasted_values_flu$mean)
forecast_data_covid <- data.frame(date = forecast_dates, covid = forecasted_values_covid$mean)

# Combine actual and forecasted data
combined_flu <- rbind(clean_flu, forecast_data_flu)
combined_covid <- rbind(clean_covid, forecast_data_covid)

# Merge datasets on 'date' column
combined_data <- merge(combined_flu, combined_covid, by = "date", all = TRUE)

# Plot the data
ggplot(combined_data, aes(x = as.Date(date))) +
  geom_line(aes(y = estimate, color = "Flu Vaccination Estimates")) +
  geom_line(aes(y = covid / max(combined_data$covid, na.rm = TRUE) * 100, color = "COVID-19 Cases")) +
  scale_y_continuous(
    name = "Flu Vaccination Estimates (%)",
    limits = c(0, 100),
    sec.axis = sec_axis(~ . * max(combined_data$covid, na.rm = TRUE) / 100, name = "COVID-19 Cases")
  ) +
  labs(title = "Flu Vaccination Estimates and COVID-19 Cases Over Time",
       x = "Date") +
  theme_minimal() +
  scale_color_manual(values = c("Flu Vaccination Estimates" = "blue", "COVID-19 Cases" = "red")) +
  theme(legend.position = "bottom")


### FIX ###


# Plot the forecasted values only
ggplot() +
  geom_line(data = forecast_data_flu, aes(x = as.Date(date), y = estimate, color = "Flu Vaccination Forecast")) +
  geom_line(data = forecast_data_covid, aes(x = as.Date(date), y = covid, color = "COVID-19 Cases Forecast")) +
  labs(title = "Forecasted Flu Vaccination Estimates and COVID-19 Cases",
       x = "Date",
       y = "Values") +
  theme_minimal() +
  scale_color_manual(values = c("Flu Vaccination Forecast" = "blue", "COVID-19 Cases Forecast" = "red")) +
  theme(legend.position = "bottom")





