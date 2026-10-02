# Shared chart style so every figure in this project looks the same.
library(ggplot2)

col_blue   <- "#2a78d6"
col_orange <- "#eb6834"
col_aqua   <- "#1baf7a"

theme_portfolio <- function() {
  theme_minimal(base_size = 12) +
    theme(
      plot.background    = element_rect(fill = "#fcfcfb", colour = NA),
      panel.background   = element_rect(fill = "#fcfcfb", colour = NA),
      panel.grid.major   = element_line(colour = "#e1e0d9", linewidth = 0.3),
      panel.grid.minor   = element_blank(),
      axis.line.x        = element_line(colour = "#c3c2b7", linewidth = 0.4),
      axis.text          = element_text(colour = "#898781"),
      axis.title         = element_text(colour = "#52514e"),
      plot.title         = element_text(colour = "#0b0b0b", face = "bold"),
      plot.subtitle      = element_text(colour = "#52514e"),
      plot.caption       = element_text(colour = "#898781", hjust = 0),
      legend.position    = "top",
      legend.justification = "left",
      legend.title       = element_blank(),
      legend.text        = element_text(colour = "#52514e"),
      strip.text         = element_text(colour = "#0b0b0b", face = "bold", hjust = 0)
    )
}
