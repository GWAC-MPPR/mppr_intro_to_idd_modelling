#' Schematic of the SIR model with an isolated compartment (SIQR).
#'
#' Run from the repository root:
#'   RENV_CONFIG_AUTOLOADER_ENABLED=FALSE Rscript scripts/siqr_figure.R
#' Writes images/siqr_model.pdf (beamer) and .svg (web slides). Needs {ggplot2} and pdftocairo.
#'
#' Same look as images/model_diagrams/: square boxes with bold state labels,
#' thick black flow arrows and red rate labels.

library(ggplot2)

half <- 0.36
col_rate <- "#c8102e"

boxes <- data.frame(
  state = c("S", "I", "R", "Q"),
  x = c(0, 2, 4, 2),
  y = c(1, 1, 1, -0.6)
)

# Flow arrows, drawn box edge to box edge, with the rate on each
flows <- data.frame(
  x    = c(0 + half, 2 + half, 2,          2 + half),
  y    = c(1,        1,        1 - half,   -0.6),
  xend = c(2 - half, 4 - half, 2,          4 - half),
  yend = c(1,        1,        -0.6 + half, 1 - half - 0.02),
  label = c("beta * I", "gamma", "delta", "tau"),
  lx = c(1, 3, 2.22, 3.35),
  ly = c(1.22, 1.22, 0.2, -0.12)
)
# The Q -> R arrow goes diagonally to the bottom edge of R
flows$xend[4] <- 4 - 0.12
flows$yend[4] <- 1 - half - 0.02

p <- ggplot() +
  geom_segment(data = flows, aes(x = x, y = y, xend = xend, yend = yend),
               linewidth = 1.3, colour = "black",
               arrow = arrow(length = unit(0.28, "cm"), type = "closed")) +
  geom_text(data = flows, aes(x = lx, y = ly, label = label),
            parse = TRUE, colour = col_rate, size = 7, fontface = "italic") +
  geom_rect(data = boxes, aes(xmin = x - half, xmax = x + half, ymin = y - half, ymax = y + half),
            fill = "white", colour = "black", linewidth = 1.4) +
  geom_text(data = boxes, aes(x = x, y = y, label = state), size = 10, fontface = "bold") +
  coord_equal(xlim = c(-0.6, 4.6), ylim = c(-1.15, 1.6), expand = FALSE, clip = "off") +
  theme_void() +
  theme(plot.background = element_rect(fill = "white", colour = NA),
        plot.margin = margin(4, 4, 4, 4))

# Vector output: PDF from the base device (used by beamer), converted to SVG for
# the web slides with poppler's pdftocairo (no cairo support in this R build).
ggsave("images/siqr_model.pdf", p, width = 7, height = 3.8, device = "pdf")
system2("pdftocairo", c("-svg", "images/siqr_model.pdf", "images/siqr_model.svg"))
message("Wrote images/siqr_model.{pdf,svg}")
