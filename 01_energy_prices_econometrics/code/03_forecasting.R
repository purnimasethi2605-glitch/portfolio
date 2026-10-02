# Step 3. Time series forecasting of the WTI oil price.
#
# Three models are compared on data they have not seen:
#   1. Random walk  (next month equals this month)
#   2. ARIMA        (order chosen by auto.arima)
#   3. ETS          (exponential smoothing chosen by ets)
#
# Run from the project folder:  Rscript code/03_forecasting.R

library(forecast)
source("code/00_plot_style.R")

df <- read.csv("data/energy_monthly.csv")
df$date <- as.Date(df$date)

start_ym <- c(as.integer(substr(df$month[1], 1, 4)),
              as.integer(substr(df$month[1], 6, 7)))
y <- ts(df$log_wti, start = start_ym, frequency = 12)
n <- length(y)

sink("output/forecast_results.txt", split = TRUE)

# ===============================================================
# Part A. Rolling one month ahead forecasts over the last 60 months.
# Each month the models are refit on all data up to that month,
# then asked to forecast the next month.
# ===============================================================
h_test <- 60
err <- matrix(NA, nrow = h_test, ncol = 3,
              dimnames = list(NULL, c("random_walk", "arima", "ets")))
actual <- numeric(h_test)

for (i in 1:h_test) {
  end_i  <- n - h_test + i - 1
  train  <- window(y, end = time(y)[end_i])
  target <- exp(y[end_i + 1])
  actual[i] <- target

  f_rw    <- exp(as.numeric(tail(train, 1)))
  f_arima <- exp(as.numeric(forecast(auto.arima(train), h = 1)$mean))
  f_ets   <- exp(as.numeric(forecast(ets(train), h = 1)$mean))

  err[i, ] <- c(f_rw, f_arima, f_ets) - target
}

rmse <- sqrt(colMeans(err^2))
mae  <- colMeans(abs(err))
mape <- colMeans(abs(err) / actual) * 100
acc  <- data.frame(model = colnames(err), rmse = rmse, mae = mae, mape = mape,
                   row.names = NULL)

cat("Rolling one month ahead forecasts, last", h_test, "months\n")
cat("Errors are in US dollars per barrel\n\n")
print(acc, digits = 4)

cat("\nDiebold Mariano test: ARIMA against random walk\n")
cat("Null hypothesis: the two models are equally accurate\n")
print(dm.test(err[, "arima"], err[, "random_walk"], h = 1, power = 2))

write.csv(acc, "output/forecast_accuracy.csv", row.names = FALSE)

# ===============================================================
# Part B. One 24 month forecast from a single cut off point,
# to show how wide the uncertainty is.
# ===============================================================
h_hold <- 24
train  <- window(y, end = time(y)[n - h_hold])
fit    <- auto.arima(train)
fc     <- forecast(fit, h = h_hold, level = 80)

cat("\nARIMA model chosen on the training sample for Part B\n")
print(fit)
cat("\nLjung Box test on the ARIMA residuals (12 lags)\n")
print(Box.test(residuals(fit), lag = 12, type = "Ljung-Box",
               fitdf = length(fit$coef)))
sink()

hold_dates <- df$date[(n - h_hold + 1):n]
plot_hist <- data.frame(date = df$date, price = df$wti)
plot_hist <- plot_hist[plot_hist$date >= as.Date("2015-01-01"), ]
plot_fc <- data.frame(
  date  = hold_dates,
  mean  = exp(as.numeric(fc$mean)),
  lower = exp(as.numeric(fc$lower)),
  upper = exp(as.numeric(fc$upper))
)
cut_date <- df$date[n - h_hold]

p <- ggplot() +
  geom_ribbon(data = plot_fc, aes(date, ymin = lower, ymax = upper),
              fill = col_orange, alpha = 0.18) +
  geom_line(data = plot_hist, aes(date, price, colour = "Actual price"),
            linewidth = 0.7) +
  geom_line(data = plot_fc, aes(date, mean, colour = "ARIMA forecast"),
            linewidth = 0.9) +
  geom_vline(xintercept = cut_date, colour = "#898781", linetype = "dashed",
             linewidth = 0.4) +
  scale_colour_manual(values = c("Actual price" = col_blue,
                                 "ARIMA forecast" = col_orange)) +
  labs(title = "WTI oil price: 24 month forecast against what happened",
       subtitle = "Shaded band is the 80 percent prediction interval",
       x = NULL, y = "US dollars per barrel",
       caption = "The model only saw data to the left of the dashed line.") +
  theme_portfolio()
ggsave("output/fig3_forecast.png", p, width = 8, height = 4.5, dpi = 150)
