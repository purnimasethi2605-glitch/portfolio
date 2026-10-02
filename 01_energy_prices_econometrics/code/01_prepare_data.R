# Step 1. Load the two price series, line them up by month, and build
# the variables used in the regressions.
#
# Run from the project folder:  Rscript code/01_prepare_data.R

source("code/00_plot_style.R")

# WTI crude oil spot price, US dollars per barrel (monthly average, EIA)
wti <- read.csv("data/wti_monthly.csv")
wti$month <- substr(wti$Date, 1, 7)
wti <- wti[, c("month", "Price")]
names(wti)[2] <- "wti"

# Henry Hub natural gas spot price, US dollars per million BTU (monthly, EIA)
gas <- read.csv("data/henry_hub_monthly.csv")
names(gas) <- c("month", "gas")

# Keep only months where both prices exist
df <- merge(wti, gas, by = "month")
df <- df[order(df$month), ]
df$date <- as.Date(paste0(df$month, "-01"))

# Logs turn price changes into percentage changes
df$log_wti <- log(df$wti)
df$log_gas <- log(df$gas)

# Monthly percentage change (log difference times 100)
df$ret_wti <- c(NA, diff(df$log_wti)) * 100
df$ret_gas <- c(NA, diff(df$log_gas)) * 100

# 1 for months from January 2009 onward, 0 before
df$post2009 <- as.integer(df$date >= as.Date("2009-01-01"))

write.csv(df, "data/energy_monthly.csv", row.names = FALSE)

cat("Months in sample:", nrow(df), "\n")
cat("First month:", df$month[1], " Last month:", df$month[nrow(df)], "\n")
cat("Missing values:", sum(is.na(df$wti)) + sum(is.na(df$gas)), "\n")

# Figure 1. The two prices over time, one panel each because the units differ
long <- rbind(
  data.frame(date = df$date, price = df$wti,
             series = "WTI crude oil (US dollars per barrel)"),
  data.frame(date = df$date, price = df$gas,
             series = "Henry Hub natural gas (US dollars per million BTU)")
)
long$series <- factor(long$series, levels = unique(long$series))

p <- ggplot(long, aes(date, price, colour = series)) +
  geom_line(linewidth = 0.7) +
  facet_wrap(~series, ncol = 1, scales = "free_y") +
  scale_colour_manual(values = c(col_blue, col_orange)) +
  labs(title = "Oil and natural gas prices, monthly",
       x = NULL, y = NULL,
       caption = "Source: US Energy Information Administration spot prices") +
  theme_portfolio() +
  theme(legend.position = "none")

ggsave("output/fig1_prices.png", p, width = 8, height = 5.5, dpi = 150)
