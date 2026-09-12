#' Schematic of an SIR model stratified into n age groups.
#'
#' Run from the repository root:
#'   RENV_CONFIG_AUTOLOADER_ENABLED=FALSE Rscript scripts/age_structured_sir_figure.R
#' Writes images/age_structured_sir.pdf (beamer) and .svg (web slides). Needs {ggplot2} and pdftocairo.
#'
#' The look follows the Keynote diagrams in images/model_diagrams/: square boxes
#' with bold state labels, thick black flow arrows, red rate labels, and dashed
#' blue arrows for the infectious groups feeding the force of infection.

library(ggplot2)

# ---- Layout -----------------------------------------------------------------
rows <- c("1", "2", "n")     # age groups drawn explicitly; "..." goes between 2 and n
row_y <- c(3, 2, 0)          # y position of each drawn row (gap at y = 1 for the dots)
col_x <- c(S = 1, I = 3, R = 5)
half <- 0.32                 # half-width of a box
col_rate <- "#c8102e"
col_foi <- "#7aa6d8"

boxes <- do.call(rbind, lapply(seq_along(rows), function(k) {
  data.frame(
    state = names(col_x), group = rows[k],
    x = unname(col_x), y = row_y[k],
    label = paste0(names(col_x), "[", rows[k], "]")
  )
}))

# Flow arrows S -> I and I -> R, drawn box edge to box edge
flows <- do.call(rbind, lapply(seq_along(rows), function(k) {
  data.frame(
    x = c(col_x[["S"]] + half, col_x[["I"]] + half),
    xend = c(col_x[["I"]] - half, col_x[["R"]] - half),
    y = row_y[k], yend = row_y[k],
    label = c(paste0("lambda[", rows[k], "]"), "gamma")
  )
}))

# Dashed arrows: every drawn I_j feeds every drawn S_i -> I_i transition
foi <- expand.grid(from = seq_along(rows), to = seq_along(rows))
foi <- data.frame(
  x = col_x[["I"]], y = row_y[foi$from] + ifelse(row_y[foi$from] >= row_y[foi$to], -half, half),
  xend = (col_x[["S"]] + col_x[["I"]]) / 2 + 0.35, yend = row_y[foi$to] + 0.04,
  same = foi$from == foi$to
)

p <- ggplot() +
  # Group labels
  annotate("text", x = col_x[["S"]] - 1.0, y = row_y, hjust = 1, size = 4.6, colour = "grey30",
           label = paste("Age group", rows)) +
  annotate("text", x = col_x[["S"]] - 1.25, y = 1, size = 6, colour = "grey30", label = "...", angle = 90) +
  # Ellipsis row between group 2 and group n
  annotate("text", x = unname(col_x), y = 1, size = 7, colour = "grey30", label = "...", angle = 90) +
  # Force-of-infection influence arrows (drawn first so the boxes sit on top)
  geom_curve(data = foi[!foi$same, ], aes(x = x, y = y, xend = xend, yend = yend),
             curvature = -0.25, colour = col_foi, linetype = "dashed", linewidth = 0.6,
             arrow = arrow(length = unit(0.16, "cm"), type = "closed")) +
  geom_curve(data = foi[foi$same, ], aes(x = x - half + 0.05, y = y + 2 * half - 0.04, xend = xend, yend = yend + 0.02),
             curvature = 0.6, colour = col_foi, linetype = "dashed", linewidth = 0.6,
             arrow = arrow(length = unit(0.16, "cm"), type = "closed")) +
  # Flow arrows and rate labels
  geom_segment(data = flows, aes(x = x, y = y, xend = xend, yend = yend),
               linewidth = 1.2, colour = "black",
               arrow = arrow(length = unit(0.25, "cm"), type = "closed")) +
  geom_text(data = flows, aes(x = (x + xend) / 2 - ifelse(label == "gamma", 0, 0.3), y = y + 0.2, label = label),
            parse = TRUE, colour = col_rate, size = 5, fontface = "italic") +
  # Boxes
  geom_rect(data = boxes, aes(xmin = x - half, xmax = x + half, ymin = y - half, ymax = y + half),
            fill = "white", colour = "black", linewidth = 1.2) +
  geom_text(data = boxes, aes(x = x, y = y, label = label), parse = TRUE, size = 7, fontface = "bold") +
  # Force of infection definition
  annotate("text", x = col_x[["R"]] + 0.9, y = 1.5, hjust = 0, size = 4.6, colour = "grey30", parse = TRUE,
           label = "lambda[i] == sum(beta[ji] * I[j], j == 1, n)") +
  annotate("text", x = col_x[["R"]] + 0.9, y = 0.95, hjust = 0, size = 3.8, colour = col_foi,
           label = "dashed: every infectious group\ncontributes to every group's\nforce of infection", lineheight = 0.95) +
  coord_equal(xlim = c(-1.2, 8.6), ylim = c(-0.6, 3.6), expand = FALSE, clip = "off") +
  theme_void() +
  theme(plot.background = element_rect(fill = "white", colour = NA),
        plot.margin = margin(4, 4, 4, 4))

# Vector output: PDF from the base device (used by beamer), converted to SVG for
# the web slides with poppler's pdftocairo (no cairo support in this R build).
ggsave("images/age_structured_sir.pdf", p, width = 10, height = 4.4, device = "pdf")
system2("pdftocairo", c("-svg", "images/age_structured_sir.pdf", "images/age_structured_sir.svg"))
message("Wrote images/age_structured_sir.{pdf,svg}")
