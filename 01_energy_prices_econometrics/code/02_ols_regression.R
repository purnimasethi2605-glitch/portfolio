# Step 2. OLS regressions: how closely does the natural gas price follow
# the oil price?
#
# Run from the project folder:  Rscript code/02_ols_regression.R

library(lmtest)     # coeftest, bgtest, bptest, dwtest
library(sandwich)   # NeweyWest standard errors
library(tseries)    # adf.test, po.test
source("code/00_plot_style.R")

df <- read.csv("data/energy_monthly.csv")
df$date <- as.Date(df$date)

sink("output/regression_results.txt", split = TRUE)

cat("=====================================================\n")
cat("A. Unit root tests (Augmented Dickey Fuller)\n")
cat("   Null hypothesis: the series has a unit root (it wanders)\n")
cat("=====================================================\n")
adf_row <- function(x, label) {
  t <- suppressWarnings(adf.test(na.omit(x)))
  cat(sprintf("%-28s statistic = %7.3f   p value = %.3f\n",
              label, t$statistic, t$p.value))
}
adf_row(df$log_wti, "log WTI, level")
adf_row(df$log_gas, "log gas, level")
adf_row(df$ret_wti, "WTI, monthly change")
adf_row(df$ret_gas, "gas, monthly change")
cat("Note: adf.test reports p values only between 0.01 and 0.10.\n\n")

cat("=====================================================\n")
cat("B. Model 1: OLS in levels   log(gas) = a + b log(WTI) + e\n")
cat("=====================================================\n")
m1 <- lm(log_gas ~ log_wti, data = df)
print(summary(m1))
cat("Durbin Watson test on Model 1 residuals\n")
print(dwtest(m1))
cat("Phillips Ouliaris cointegration test\n")
cat("Null hypothesis: the two series are NOT cointegrated\n")
print(suppressWarnings(po.test(cbind(df$log_gas, df$log_wti))))

cat("=====================================================\n")
cat("C. Model 2: OLS in monthly changes\n")
cat("   gas change = a + b WTI change + e\n")
cat("=====================================================\n")
d <- df[!is.na(df$ret_gas), ]
m2 <- lm(ret_gas ~ ret_wti, data = d)
print(summary(m2))
cat("Breusch Godfrey test for serial correlation (12 lags)\n")
print(bgtest(m2, order = 12))
cat("Breusch Pagan test for heteroskedasticity\n")
print(bptest(m2))
cat("Model 2 with Newey West standard errors\n")
m2_nw <- coeftest(m2, vcov = NeweyWest(m2))
print(m2_nw)

cat("=====================================================\n")
cat("D. Model 3: did the link change after 2008?\n")
cat("   gas change = a + b WTI change + c post2009\n")
cat("                + d (WTI change x post2009) + e\n")
cat("=====================================================\n")
m3 <- lm(ret_gas ~ ret_wti * post2009, data = d)
print(summary(m3))
cat("Model 3 with Newey West standard errors\n")
m3_nw <- coeftest(m3, vcov = NeweyWest(m3))
print(m3_nw)

cat("=====================================================\n")
cat("E. Model 4: Model 3 plus month of year dummies (seasonality check)\n")
cat("=====================================================\n")
d$month_of_year <- factor(format(d$date, "%m"))
m4 <- lm(ret_gas ~ ret_wti * post2009 + month_of_year, data = d)
m4_nw <- coeftest(m4, vcov = NeweyWest(m4))
print(m4_nw[c("ret_wti", "post2009", "ret_wti:post2009"), ])
cat(sprintf("\nR squared, Model 4: %.4f\n", summary(m4)$r.squared))

sink()

# Compact table of the main coefficients, saved as CSV
tab <- data.frame(
  model = c("Model 1 levels", "Model 2 changes", "Model 3 before 2009",
            "Model 3 change in slope from 2009"),
  term = c("log_wti", "ret_wti", "ret_wti", "ret_wti:post2009"),
  estimate = c(coef(m1)["log_wti"], m2_nw["ret_wti", 1],
               m3_nw["ret_wti", 1], m3_nw["ret_wti:post2009", 1]),
  std_error = c(summary(m1)$coefficients["log_wti", 2], m2_nw["ret_wti", 2],
                m3_nw["ret_wti", 2], m3_nw["ret_wti:post2009", 2]),
  p_value = c(summary(m1)$coefficients["log_wti", 4], m2_nw["ret_wti", 4],
              m3_nw["ret_wti", 4], m3_nw["ret_wti:post2009", 4]),
  std_error_type = c("ordinary", "Newey West", "Newey West", "Newey West"),
  r_squared = c(summary(m1)$r.squared, summary(m2)$r.squared,
                summary(m3)$r.squared, summary(m3)$r.squared),
  n = c(nobs(m1), nobs(m2), nobs(m3), nobs(m3))
)
write.csv(tab, "output/regression_table.csv", row.names = FALSE)

# Figure 2. Monthly changes, before and after 2009, with fitted lines
d$period <- ifelse(d$post2009 == 1, "2009 onward", "1997 to 2008")
p <- ggplot(d, aes(ret_wti, ret_gas, colour = period)) +
  geom_point(alpha = 0.45, size = 1.6) +
  geom_smooth(method = "lm", formula = y ~ x, se = FALSE, linewidth = 0.9) +
  facet_wrap(~period) +
  scale_colour_manual(values = c(col_blue, col_orange)) +
  scale_x_continuous(breaks = c(-40, -20, 0, 20, 40)) +
  labs(title = "Monthly change in gas price against monthly change in oil price",
       x = "WTI crude oil, percent change",
       y = "Henry Hub natural gas, percent change",
       caption = "Lines are OLS fits. Percent changes are log differences times 100.") +
  theme_portfolio() +
  theme(legend.position = "none", panel.spacing = unit(1.5, "lines"))
ggsave("output/fig2_scatter.png", p, width = 8, height = 4.5, dpi = 150)
