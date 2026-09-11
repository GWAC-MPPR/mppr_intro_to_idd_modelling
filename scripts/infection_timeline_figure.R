#' Infection timeline diagram: pathogen load and immune response after infection,
#' with the infection-status (S, E, I, R) and medical-status periods above.
#'
#' Run from the repository root:
#'   RENV_CONFIG_AUTOLOADER_ENABLED=FALSE Rscript scripts/infection_timeline_figure.R
#' Writes images/infection_timeline.pdf (beamer) and .svg (web slides). Needs {ggplot2} and pdftocairo.

library(ggplot2)

# ---- Curves (schematic, in arbitrary units; x is days since infection) --------
t_inf <- 2 # time of infection
t_lat <- 8 # end of latent period, start of infectiousness
t_sym <- 11 # onset of symptoms
t_rec <- 18 # end of infectiousness
t_dis <- 21 # end of disease
t_end <- 30

x <- seq(0, t_end, by = 0.05)
# Pathogen load: rises after infection, peaks, then is cleared
pathogen <- ifelse(x < t_inf, 0, dgamma(x - t_inf, shape = 5, rate = 0.55))
pathogen <- 0.75 * pathogen / max(pathogen)
# Immune response: lags the pathogen, peaks later, decays to a memory plateau
immune <- 0.05 +
  0.95 * plogis((x - 12) / 1.6) * (0.3 + 0.7 * plogis(-(x - 17) / 2.2))
curves <- data.frame(x = x, pathogen = pathogen, immune = immune)

col_inf <- "tomato"
col_status <- "grey25"
col_med <- "grey55"
arr <- arrow(length = unit(0.18, "cm"), ends = "both", type = "closed")
arr_left <- arrow(length = unit(0.18, "cm"), ends = "first", type = "closed")
arr_right <- arrow(length = unit(0.18, "cm"), ends = "last", type = "closed")

# Period arrows: infection status (row 1) and medical status (row 2)
y1 <- 1.12
y2 <- 1.36
ts <- 4.2 # text size

p <- ggplot(curves, aes(x)) +
  # Pathogen and immune response
  geom_area(aes(y = pathogen), fill = col_inf, alpha = 0.25) +
  geom_line(aes(y = pathogen), colour = col_inf, linewidth = 0.8) +
  geom_line(aes(y = immune), colour = "steelblue", linewidth = 1.2) +
  annotate(
    "text",
    x = 12.5,
    y = 0.3,
    label = "pathogen load",
    colour = col_inf,
    size = ts,
    fontface = "italic"
  ) +
  annotate(
    "text",
    x = 22.5,
    y = 0.78,
    label = "immune\nresponse",
    colour = "steelblue",
    size = ts,
    fontface = "italic",
    hjust = 0,
    lineheight = 0.9
  ) +
  # Axes
  annotate(
    "segment",
    x = 0,
    xend = t_end,
    y = 0,
    yend = 0,
    colour = col_status,
    arrow = arr_right
  ) +
  annotate(
    "text",
    x = t_end,
    y = -0.07,
    label = "time since infection",
    hjust = 1,
    size = ts,
    colour = col_status
  ) +
  annotate(
    "segment",
    x = t_inf,
    xend = t_inf,
    y = 0,
    yend = 1.02,
    colour = col_status,
    linetype = "dashed"
  ) +
  annotate(
    "text",
    x = t_inf,
    y = -0.1,
    label = "time of\ninfection",
    size = ts,
    colour = col_status,
    lineheight = 0.9,
    vjust = 1
  ) +
  # Row 1: infection status
  annotate(
    "segment",
    x = -1.2,
    xend = t_inf - 0.3,
    y = y1,
    yend = y1,
    colour = col_status,
    arrow = arr_left
  ) +
  annotate(
    "text",
    x = (-1.2 + t_inf) / 2,
    y = y1 + 0.07,
    label = "Susceptible",
    size = ts,
    colour = col_status
  ) +
  annotate(
    "segment",
    x = t_inf + 0.3,
    xend = t_lat - 0.3,
    y = y1,
    yend = y1,
    colour = col_status,
    arrow = arr
  ) +
  annotate(
    "text",
    x = (t_inf + t_lat) / 2,
    y = y1 + 0.07,
    label = "Exposed / latent",
    size = ts,
    colour = col_status
  ) +
  annotate(
    "segment",
    x = t_lat + 0.3,
    xend = t_rec - 0.3,
    y = y1,
    yend = y1,
    colour = col_inf,
    linewidth = 1.3,
    arrow = arr
  ) +
  annotate(
    "text",
    x = (t_lat + t_rec) / 2,
    y = y1 + 0.07,
    label = "Infectious",
    size = ts,
    colour = col_inf,
    fontface = "bold"
  ) +
  annotate(
    "segment",
    x = t_rec + 0.3,
    xend = t_end,
    y = y1,
    yend = y1,
    colour = col_status,
    arrow = arr_right
  ) +
  annotate(
    "text",
    x = (t_rec + t_end) / 2,
    y = y1 + 0.07,
    label = "Recovered",
    size = ts,
    colour = col_status
  ) +
  annotate(
    "text",
    x = t_end + 0.6,
    y = y1,
    label = "Infection\nstatus",
    hjust = 0,
    size = ts,
    colour = col_status,
    lineheight = 0.9,
    fontface = "bold"
  ) +
  # Row 2: medical status
  annotate(
    "segment",
    x = t_inf + 0.3,
    xend = t_sym - 0.3,
    y = y2,
    yend = y2,
    colour = col_med,
    arrow = arr
  ) +
  annotate(
    "text",
    x = (t_inf + t_sym) / 2,
    y = y2 + 0.07,
    label = "Incubation",
    size = ts,
    colour = col_med
  ) +
  annotate(
    "segment",
    x = t_sym + 0.3,
    xend = t_dis - 0.3,
    y = y2,
    yend = y2,
    colour = col_med,
    linewidth = 1.3,
    arrow = arr
  ) +
  annotate(
    "text",
    x = (t_sym + t_dis) / 2,
    y = y2 + 0.07,
    label = "Symptomatic",
    size = ts,
    colour = col_med
  ) +
  annotate(
    "text",
    x = t_end + 0.6,
    y = y2,
    label = "Medical\nstatus",
    hjust = 0,
    size = ts,
    colour = col_med,
    lineheight = 0.9,
    fontface = "bold"
  ) +
  # Guides linking the rows to the curves
  annotate(
    "segment",
    x = c(t_lat, t_rec),
    xend = c(t_lat, t_rec),
    y = 0,
    yend = y1 - 0.02,
    colour = col_inf,
    linetype = "dotted",
    alpha = 0.7
  ) +
  annotate(
    "segment",
    x = c(t_sym, t_dis),
    xend = c(t_sym, t_dis),
    y = 0,
    yend = y2 - 0.02,
    colour = col_med,
    linetype = "dotted",
    alpha = 0.7
  ) +
  coord_cartesian(
    xlim = c(-1.6, t_end + 4.5),
    ylim = c(-0.22, y2 + 0.12),
    expand = FALSE,
    clip = "off"
  ) +
  theme_void() +
  theme(
    plot.background = element_rect(fill = "white", colour = NA),
    plot.margin = margin(4, 4, 4, 4)
  )

# Vector output: PDF from the base device (used by beamer), converted to SVG for
# the web slides with poppler's pdftocairo (no cairo support in this R build).
ggsave(
  "images/infection_timeline.pdf",
  p,
  width = 10,
  height = 5,
  device = "pdf"
)
system2(
  "pdftocairo",
  c("-svg", "images/infection_timeline.pdf", "images/infection_timeline.svg")
)
