# Toss, temperature and day or night effects in the 2024 T20 World Cup.
#
# Part A rebuilds Model 1 from the counts reported in the course paper.
# Part B runs Models 2 to 4, but only if the match level dataset is
# placed at data/t20_world_cup_2024.csv (it is not included here).
#
# Run from the project folder:  Rscript code/toss_analysis.R

sink("output/model1_results.txt", split = TRUE)

# ===========================================================
# Part A. Model 1 from the reported counts
# 52 completed matches. The toss winner chose to field in 40
# and to bat in 12. The toss winner went on to win 20 of the
# 40 fielding matches and 7 of the 12 batting matches.
# ===========================================================
matches <- data.frame(
  TossDecisionDummy = c(rep(1, 40), rep(0, 12)),              # 1 = field
  MatchWinnerDummy  = c(rep(1, 20), rep(0, 20), rep(1, 7), rep(0, 5))
)

cat("Share of toss winners who chose to field:",
    round(mean(matches$TossDecisionDummy), 4), "\n")
cat("Share of toss winners who won the match:",
    round(mean(matches$MatchWinnerDummy), 4), "\n")
ci <- binom.test(sum(matches$MatchWinnerDummy), nrow(matches))$conf.int
cat("95 percent confidence interval for that share:",
    round(ci[1], 3), "to", round(ci[2], 3), "\n\n")

cat("Model 1: MatchWinnerDummy = a + b TossDecisionDummy + e\n")
m1 <- lm(MatchWinnerDummy ~ TossDecisionDummy, data = matches)
print(summary(m1))

cat("Fisher exact test on the same two by two table\n")
print(fisher.test(table(matches$TossDecisionDummy, matches$MatchWinnerDummy)))
sink()

# ===========================================================
# Part B. Models 2 to 4, needs the match level dataset.
# Expected columns: TossDecisionDummy, MatchWinnerDummy,
# DayNightDummy, AverageTempAC
# ===========================================================
data_file <- "data/t20_world_cup_2024.csv"
if (file.exists(data_file)) {
  d <- read.csv(data_file)
  sink("output/models2to4_results.txt", split = TRUE)
  m2 <- lm(MatchWinnerDummy ~ DayNightDummy + AverageTempAC, data = d)
  m3 <- lm(MatchWinnerDummy ~ TossDecisionDummy + DayNightDummy + AverageTempAC,
           data = d)
  m4 <- lm(MatchWinnerDummy ~ TossDecisionDummy * DayNightDummy + AverageTempAC,
           data = d)
  print(summary(m2))
  print(summary(m3))
  print(summary(m4))
  sink()
} else {
  cat("\nMatch level dataset not found, so Models 2 to 4 were skipped.\n")
}
