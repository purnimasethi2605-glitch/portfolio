# Outreach response rates for a small business

## About this project

Psol Supplies is my side venture importing healthcare linens for Ontario long term care homes. I sent roughly 500 outreach emails to potential buyers. Replies from the London region seemed more positive than replies from elsewhere. This project checks whether the numbers support that impression.

## Data

* **London region:** 63 replies. 23 were a yes and 40 were a no. These are exact counts.
* **Other regions:** about 20 percent of replies were a yes. This is my estimate. I did not keep exact counts for other regions.

No buyer names or contact details are included.

## Method

An exact binomial test. It gives a confidence interval for the London yes rate and tests whether that rate differs from the rate elsewhere. Because the rate elsewhere is an estimate, I tested against three values (20, 25 and 30 percent) to see how much the conclusion depends on it.

## Results

* London yes rate: **36.5 percent** (23 of 63)
* 95 percent confidence interval: **24.7 to 49.6 percent**

Is London different from the other regions?

* If the rate elsewhere is 20 percent: yes, clearly (p value 0.002)
* If the rate elsewhere is 25 percent: yes, narrowly (p value 0.041)
* If the rate elsewhere is 30 percent: no (p value 0.27)

**The honest conclusion:** London probably did respond better, but the answer depends on a number I only estimated. With 63 replies the confidence interval is wide.

## What I would do next

1. Record every reply with its region and outreach method (email, phone, in person).
2. Once exact counts exist for other regions, compare the regions directly with a two sample test.
3. Fit a logistic regression of yes or no on region and outreach method, to separate the effect of location from the effect of how the contact was made. My impression is that direct contact works better than cold email. If direct contact was more common in London, the two effects are mixed together in the current numbers.

## Limits

* Replies are not a random sample. People who answer an email differ from people who do not.
* The comparison rate is an estimate, not a measurement.
* A positive reply is not a sale.

## How to run

```
Rscript code/outreach_analysis.R
```

Output is saved in `output/results.txt`.
