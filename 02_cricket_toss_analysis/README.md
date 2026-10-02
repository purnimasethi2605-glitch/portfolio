# Does the toss decide the match?

## About this project

A group project for Economics 2182, a sports economics course at Western University, completed in November 2024 with two classmates. We asked whether the toss decision, the temperature, or playing at night gave teams a measurable advantage in the ICC Men's T20 World Cup 2024.

## Data

We built the dataset by hand from the match pages on the official ICC website. The tournament had 55 matches. Three were abandoned because of rain, which left 52.

Variables:

* **MatchWinnerDummy:** 1 if the team that won the toss also won the match
* **TossDecisionDummy:** 1 if the toss winner chose to field, 0 if it chose to bat
* **DayNightDummy:** 1 if the match was played at night
* **AverageTempAC:** average temperature on match day, in degrees Celsius

Summary:

* The toss winner chose to field in 40 of 52 matches (77 percent)
* The toss winner won 27 of 52 matches (52 percent)
* 44 percent of matches were played at night
* Average temperature was 27.8 degrees, with a standard deviation of 2.8

## Method

Linear probability models estimated by OLS. The outcome is whether the toss winner won the match.

* **Model 1:** toss decision only
* **Model 2:** day or night, and temperature
* **Model 3:** toss decision, day or night, and temperature
* **Model 4:** Model 3 plus an interaction between the toss decision and day or night

## Results

**None of the factors had a statistically significant effect on who won.**

* **Model 1:** choosing to field lowered the toss winner's win rate by 8.3 percentage points (58.3 percent when batting first, 50.0 percent when fielding first). The p value is 0.62 and R squared is 0.005.
* **Model 3:** coefficients of 0.19 for night matches (p value 0.21), minus 0.08 for choosing to field (p value 0.64) and minus 0.02 per degree of temperature (p value 0.37). R squared is 0.078.
* **Model 4:** the interaction between fielding and night matches is minus 0.18 (p value 0.60). R squared is 0.083.

The toss winner won 52 percent of matches. The 95 percent confidence interval runs from 38 to 66 percent, so the data are consistent with the toss giving no advantage at all.

Our reading in the paper was that match results depend far more on team quality than on the toss or the conditions, which fits the idea that captains face a balanced choice between batting and fielding first.

## What is in this folder

The script `code/toss_analysis.R` rebuilds Model 1 from the counts above and matches the result in our paper exactly (coefficient minus 0.0833, p value 0.6206, R squared 0.0049). It also adds a Fisher exact test on the same table (p value 0.75). The output is in `output/model1_results.txt`.

The match level dataset is not included here. If the file is added at `data/t20_world_cup_2024.csv`, the same script runs Models 2 to 4. The results for those models above are the ones we reported in 2024.

## Limits

* 52 matches is a small sample, so only a large effect could have been detected.
* One tournament, played in the United States and the West Indies, may not represent other venues.
* A linear probability model is simple to read but can predict values outside 0 to 1. A logit model would be a useful check.
* Team strength is not in the model, and it is likely the main driver of results.

## How to run

```
Rscript code/toss_analysis.R
```
