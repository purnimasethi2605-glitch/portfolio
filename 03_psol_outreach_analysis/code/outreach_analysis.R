# Psol Supplies outreach: did contacts in the London region say yes more often?
#
# What is known exactly: among London region contacts who replied,
# 23 said yes and 40 said no.
# What is only an estimate: in other regions about 20 percent of replies
# were a yes (no was about 70 to 80 percent). Exact counts were not kept.
#
# Run from the project folder:  Rscript code/outreach_analysis.R

london_yes <- 23
london_no  <- 40
n <- london_yes + london_no

sink("output/results.txt", split = TRUE)

rate <- london_yes / n
test <- binom.test(london_yes, n)
cat("London region replies:", n, "\n")
cat(sprintf("Yes rate: %.1f percent\n", rate * 100))
cat(sprintf("95 percent confidence interval: %.1f to %.1f percent\n\n",
            test$conf.int[1] * 100, test$conf.int[2] * 100))

cat("Is the London yes rate different from the other regions?\n")
cat("The other regions rate is an estimate, so three values are tried.\n\n")
cat(sprintf("%-28s %s\n", "Assumed rate elsewhere", "p value (exact binomial test)"))
for (benchmark in c(0.20, 0.25, 0.30)) {
  p <- binom.test(london_yes, n, p = benchmark)$p.value
  cat(sprintf("%-28s %.3f\n", paste0(benchmark * 100, " percent"), p))
}
sink()
