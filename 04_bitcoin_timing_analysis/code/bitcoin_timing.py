"""
Does timing matter when buying Bitcoin?

Three questions, answered with daily prices from 2015 onward:
  1. Is the price in an up trend or a down trend? (200 day moving average)
  2. Would holding Bitcoin only during up trends have beaten simply holding it?
  3. Is it better to invest a sum all at once, or in 12 monthly pieces?

This is a study of past prices. It is not investment advice and it does not
predict future prices.

Run from the project folder:  python3 code/bitcoin_timing.py
"""

import numpy as np
import pandas as pd
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

START = "2015-01-01"      # first day of the study period
MAIN_WINDOW = 200         # days in the moving average
COST_PER_TRADE = 0.01     # assumed cost each time the rule buys or sells (1 percent)

BLUE, ORANGE = "#2a78d6", "#eb6834"
SURFACE, GRID, AXIS = "#fcfcfb", "#e1e0d9", "#c3c2b7"
INK, INK2, MUTED = "#0b0b0b", "#52514e", "#898781"


def style(ax):
    ax.set_facecolor(SURFACE)
    ax.grid(True, axis="y", color=GRID, linewidth=0.6)
    ax.grid(False, axis="x")
    for side in ("top", "right", "left"):
        ax.spines[side].set_visible(False)
    ax.spines["bottom"].set_color(AXIS)
    ax.tick_params(colors=MUTED, length=0)


def max_drawdown(value):
    """Largest fall from an earlier peak, as a negative fraction."""
    return (value / value.cummax() - 1).min()


def yearly_growth(value):
    """Average growth per year (compound annual growth rate)."""
    years = (value.index[-1] - value.index[0]).days / 365.25
    return (value.iloc[-1] / value.iloc[0]) ** (1 / years) - 1


def trend_rule(price, window, cost):
    """
    Hold Bitcoin on a day only if yesterday's close was above its moving
    average. Otherwise hold cash that earns nothing.
    Returns the daily value of 1 dollar and the daily position (1 or 0).
    """
    average = price.rolling(window).mean()
    signal = (price > average).astype(int)
    position = signal.shift(1)            # act the day after the signal
    daily_return = price.pct_change()
    trades = position.diff().abs()
    strategy_return = position * daily_return - trades * cost
    return strategy_return, position, average


prices = pd.read_csv("data/bitcoin_daily.csv", parse_dates=["date"])
price = prices.set_index("date")["price_usd"]

lines = []
def say(text=""):
    print(text)
    lines.append(text)

# ==============================================================
# 1 and 2. Trend rule against buy and hold
# ==============================================================
strategy_return, position, average = trend_rule(price, MAIN_WINDOW, COST_PER_TRADE)
study = price.loc[START:].index
hold_value = price.loc[study] / price.loc[study].iloc[0]
rule_value = (1 + strategy_return.loc[study].fillna(0)).cumprod()
rule_value.iloc[0] = 1.0
in_market = position.loc[study]

say(f"Study period: {study[0].date()} to {study[-1].date()} ({len(study)} days)")
say(f"Moving average window: {MAIN_WINDOW} days. Assumed cost per trade: {COST_PER_TRADE:.0%}")
say()
say("Growth of 1 dollar, buy and hold against the trend rule")
say(f"{'':28}{'Buy and hold':>14}{'Trend rule':>14}")
say(f"{'Final value of 1 dollar':28}{hold_value.iloc[-1]:>14.1f}{rule_value.iloc[-1]:>14.1f}")
say(f"{'Average growth per year':28}{yearly_growth(hold_value):>14.1%}{yearly_growth(rule_value):>14.1%}")
say(f"{'Worst fall from a peak':28}{max_drawdown(hold_value):>14.1%}{max_drawdown(rule_value):>14.1%}")
say(f"{'Share of days invested':28}{1:>14.0%}{in_market.mean():>14.0%}")
say(f"{'Number of trades':28}{1:>14.0f}{int(in_market.diff().abs().sum()):>14.0f}")
say()

# What happened in the 90 days after an up trend day or a down trend day?
forward = price.shift(-90) / price - 1
table = pd.DataFrame({"up": price > average, "forward": forward}).loc[study].dropna()
say("Price change over the next 90 days, by trend on the starting day")
for label, flag in (("Up trend days", True), ("Down trend days", False)):
    part = table.loc[table["up"] == flag, "forward"]
    say(f"{label:18} days = {len(part):5d}   median = {part.median():7.1%}   "
        f"share that rose = {(part > 0).mean():.0%}")
say()

# Does the answer depend on the window chosen?
say("Same test with other moving average windows")
say(f"{'Window':>8}{'Final value':>14}{'Growth per year':>18}{'Worst fall':>13}{'Trades':>9}")
rows = []
for window in (50, 100, 150, 200, 250):
    r, pos, _ = trend_rule(price, window, COST_PER_TRADE)
    value = (1 + r.loc[study].fillna(0)).cumprod()
    value.iloc[0] = 1.0
    n_trades = int(pos.loc[study].diff().abs().sum())
    rows.append((window, value.iloc[-1], yearly_growth(value), max_drawdown(value), n_trades))
    say(f"{window:>8}{value.iloc[-1]:>14.1f}{yearly_growth(value):>18.1%}{max_drawdown(value):>13.1%}{n_trades:>9}")
say(f"{'Hold':>8}{hold_value.iloc[-1]:>14.1f}{yearly_growth(hold_value):>18.1%}{max_drawdown(hold_value):>13.1%}{1:>9}")
say()

# ==============================================================
# 3. All at once against 12 monthly pieces
# ==============================================================
month_starts = price.loc[START:].resample("MS").first()
wins, lump_results, monthly_results = 0, [], []
for i in range(len(month_starts) - 12):
    buy_prices = month_starts.iloc[i:i + 12]
    end_price = month_starts.iloc[i + 12]
    lump = 1200 / buy_prices.iloc[0] * end_price
    monthly = (100 / buy_prices).sum() * end_price
    lump_results.append(lump)
    monthly_results.append(monthly)
    wins += lump > monthly
n_tests = len(lump_results)
say("Investing 1,200 dollars: all at once, or 100 dollars a month for 12 months")
say(f"Start months tested: {n_tests}")
say(f"All at once ended higher in {wins} of {n_tests} start months ({wins / n_tests:.0%})")
say(f"Median value after 12 months, all at once: {np.median(lump_results):,.0f} dollars")
say(f"Median value after 12 months, monthly:     {np.median(monthly_results):,.0f} dollars")
say(f"Worst result, all at once: {min(lump_results):,.0f} dollars")
say(f"Worst result, monthly:     {min(monthly_results):,.0f} dollars")

with open("output/results.txt", "w") as f:
    f.write("\n".join(lines) + "\n")

pd.DataFrame(rows, columns=["window_days", "final_value", "growth_per_year",
                            "worst_fall", "trades"]).to_csv(
    "output/window_comparison.csv", index=False)

# ==============================================================
# Figures
# ==============================================================
plt.rcParams["font.family"] = "DejaVu Sans"

# Figure 1. Price with up trend and down trend days marked
fig, ax = plt.subplots(figsize=(8, 4.5), facecolor=SURFACE)
style(ax)
p = price.loc[study]
up = (price > average).loc[study]
ax.plot(p.index, p.where(up), color=BLUE, linewidth=1.6, label="Up trend (price above 200 day average)")
ax.plot(p.index, p.where(~up), color=ORANGE, linewidth=1.6, label="Down trend (price below 200 day average)")
ax.plot(p.index, average.loc[study], color=MUTED, linewidth=0.9, label="200 day average")
ax.set_yscale("log")
ax.set_yticks([300, 1000, 3000, 10000, 30000, 100000])
ax.set_yticklabels(["300", "1,000", "3,000", "10,000", "30,000", "100,000"])
ax.minorticks_off()
ax.set_ylabel("US dollars, log scale", color=INK2)
ax.set_title("Bitcoin price and its trend", loc="left", color=INK, fontweight="bold")
ax.legend(frameon=False, loc="upper left", fontsize=9, labelcolor=INK2)
fig.text(0.01, 0.01, "Source: Coin Metrics community data", color=MUTED, fontsize=8)
fig.tight_layout(rect=(0, 0.03, 1, 1))
fig.savefig("output/fig1_price_and_trend.png", dpi=150, facecolor=SURFACE)

# Figure 2. Growth of 1 dollar and the fall from peak, for each approach
fig, axes = plt.subplots(2, 1, figsize=(8, 6), facecolor=SURFACE, sharex=True,
                         gridspec_kw={"height_ratios": [3, 2]})
for ax in axes:
    style(ax)
axes[0].plot(hold_value.index, hold_value, color=BLUE, linewidth=1.6, label="Buy and hold")
axes[0].plot(rule_value.index, rule_value, color=ORANGE, linewidth=1.6, label="Trend rule")
axes[0].set_yscale("log")
axes[0].set_yticks([1, 3, 10, 30, 100, 300])
axes[0].set_yticklabels(["1", "3", "10", "30", "100", "300"])
axes[0].minorticks_off()
axes[0].set_ylabel("Value of 1 dollar, log scale", color=INK2)
axes[0].set_title("Buy and hold against the trend rule", loc="left", color=INK, fontweight="bold")
axes[0].legend(frameon=False, loc="upper left", fontsize=9, labelcolor=INK2)
axes[1].plot(hold_value.index, (hold_value / hold_value.cummax() - 1) * 100, color=BLUE, linewidth=1.3)
axes[1].plot(rule_value.index, (rule_value / rule_value.cummax() - 1) * 100, color=ORANGE, linewidth=1.3)
axes[1].set_ylabel("Fall from earlier peak, percent", color=INK2)
fig.text(0.01, 0.01, "Trend rule includes an assumed cost of 1 percent per trade. Past results only.",
         color=MUTED, fontsize=8)
fig.tight_layout(rect=(0, 0.03, 1, 1))
fig.savefig("output/fig2_rule_against_hold.png", dpi=150, facecolor=SURFACE)
