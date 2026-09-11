#' Figures for the "Stochasticity in SIR models" section of the slides.
#'
#' Run from the repository root:
#'   RENV_CONFIG_AUTOLOADER_ENABLED=FALSE Rscript scripts/stochastic_sir_figures.R
#' Outputs go to images/stochastic/. Only {deSolve} and {ggplot2} are needed.

library(deSolve)
library(ggplot2)

set.seed(2026)
out_dir <- "images/stochastic"
dir.create(out_dir, showWarnings = FALSE)

theme_set(
  theme_minimal(base_size = 16) +
    theme(
      legend.position = "top",
      plot.background = element_rect(fill = "white", colour = NA)
    )
)

# Colours used in the slides for compartments
col_det <- "black"
col_stoch <- "grey55"
col_major <- "tomato"
col_minor <- "steelblue"

# ---- Models -----------------------------------------------------------------

#' Deterministic SIR (density-dependent transmission, beta = R0 * gamma / N)
sir_ode <- function(t, y, parms) {
  with(as.list(c(y, parms)), {
    dS <- -beta * S * I
    dI <- beta * S * I - gamma * I
    dR <- gamma * I
    list(c(dS, dI, dR))
  })
}

solve_sir <- function(R0, infectious_period, N, I0, t_max) {
  gamma <- 1 / infectious_period
  beta <- R0 * gamma / N
  out <- lsoda(
    y = c(S = N - I0, I = I0, R = 0),
    times = seq(0, t_max, by = 0.5),
    func = sir_ode,
    parms = c(beta = beta, gamma = gamma)
  )
  as.data.frame(out)
}

#' Stochastic SIR simulated with Gillespie's direct method
sir_gillespie <- function(R0, infectious_period, N, I0, t_max) {
  gamma <- 1 / infectious_period
  beta <- R0 * gamma / N

  # Pre-allocate: at most N infections + N recoveries can happen
  max_events <- 2 * N + 1
  time <- numeric(max_events)
  S <- integer(max_events)
  I <- integer(max_events)
  R <- integer(max_events)

  time[1] <- 0
  S[1] <- N - I0
  I[1] <- I0
  R[1] <- 0
  k <- 1

  while (I[k] > 0 && time[k] < t_max) {
    rate_inf <- beta * S[k] * I[k]
    rate_rec <- gamma * I[k]
    rate_total <- rate_inf + rate_rec

    dt <- rexp(1, rate = rate_total)
    infection <- runif(1) < rate_inf / rate_total

    k <- k + 1
    time[k] <- time[k - 1] + dt
    S[k] <- S[k - 1] - infection
    I[k] <- I[k - 1] + infection - !infection
    R[k] <- R[k - 1] + !infection
  }

  data.frame(time = time[1:k], S = S[1:k], I = I[1:k], R = R[1:k])
}

run_many <- function(n, ...) {
  do.call(
    rbind,
    lapply(seq_len(n), function(i) cbind(run = i, sir_gillespie(...)))
  )
}

# Common settings
R0 <- 2
infectious_period <- 7
N <- 1000
t_max <- 150

# ---- Figure 1: deterministic vs stochastic ----------------------------------

det <- solve_sir(R0, infectious_period, N, I0 = 5, t_max)
runs <- run_many(20, R0, infectious_period, N, I0 = 5, t_max)

p1 <- ggplot() +
  geom_step(
    data = runs,
    aes(time, I, group = run),
    colour = col_stoch,
    alpha = 0.6
  ) +
  geom_line(data = det, aes(time, I), colour = col_det, linewidth = 1.3) +
  labs(
    x = "Time (days)",
    y = "Number infectious, I(t)",
    title = "Same parameters, same starting point, 20 different epidemics",
    subtitle = sprintf(
      "Grey: 20 stochastic simulations; \nBlack: deterministic SIR (N = %d, R0 = %s, infectious period = %d days)",
      N,
      R0,
      infectious_period
    )
  ) +
  coord_cartesian(xlim = c(0, t_max))
ggsave(
  file.path(out_dir, "det_vs_stoch.png"),
  p1,
  width = 9,
  height = 5,
  dpi = 200
)

# ---- Figure 2: Gillespie schematic (first few events) ------------------------

set.seed(12)
early <- sir_gillespie(R0, infectious_period, N = 50, I0 = 3, t_max = 30)
early <- early[1:8, ]
early$event <- c(
  NA,
  ifelse(
    diff(early$I) > 0,
    "Infection (S -> S-1, I -> I+1)",
    "Recovery (I -> I-1, R -> R+1)"
  )
)
gaps <- data.frame(
  from = early$time[-nrow(early)],
  to = early$time[-1],
  label = paste0("delta * t[", seq_len(nrow(early) - 1), "]")
)

p2 <- ggplot(early, aes(time, I)) +
  geom_vline(xintercept = early$time, linetype = "dotted", colour = "grey60") +
  geom_step(colour = col_det, linewidth = 1) +
  geom_point(aes(colour = event), size = 4.5, na.rm = TRUE) +
  geom_text(
    data = gaps[c(1, 3), ],
    aes(x = (from + to) / 2, y = 0.4, label = label),
    parse = TRUE,
    size = 5,
    colour = "grey30"
  ) +
  annotate(
    "text",
    x = 0,
    y = max(early$I) + 0.6,
    size = 4.5,
    colour = "grey30",
    hjust = 0,
    label = "delta * t %~% Exp(R[total]) * \",  \" * R[total] == beta * S * I + gamma * I",
    parse = TRUE
  ) +
  scale_colour_manual(
    values = setNames(
      c(col_major, col_minor),
      c("Infection (S -> S-1, I -> I+1)", "Recovery (I -> I-1, R -> R+1)")
    ),
    name = NULL,
    na.translate = FALSE
  ) +
  scale_y_continuous(breaks = 0:10, limits = c(0, NA)) +
  labs(
    x = "Time (days)",
    y = "Number infectious, I(t)",
    title = "One event at a time",
    subtitle = "Wait a random time, then pick which event happens, weighted by the event rates"
  )
ggsave(
  file.path(out_dir, "gillespie_schematic.png"),
  p2,
  width = 9,
  height = 4.5,
  dpi = 200
)

# ---- Figure 3: fade-out with a single introduction --------------------------

set.seed(2026)
n_runs <- 100
runs1 <- run_many(n_runs, R0, infectious_period, N, I0 = 1, t_max)
final <- aggregate(R ~ run, runs1, max)
final$outcome <- ifelse(
  final$R < 0.1 * N,
  "Fade-out (minor outbreak)",
  "Major epidemic"
)
runs1 <- merge(runs1, final[, c("run", "outcome")], by = "run")
det1 <- solve_sir(R0, infectious_period, N, I0 = 1, t_max)

# Two panels: a zoom on the first weeks (where fade-outs happen) and the full run
zoom_t <- 20
zoom_I <- 10
runs1$panel <- "Full epidemic"
det1$panel <- "Full epidemic"
runs1_zoom <- subset(runs1, time <= zoom_t & I <= zoom_I)
det1_zoom <- subset(det1, time <= zoom_t & I <= zoom_I)
runs1_zoom$panel <- sprintf("Zoom: first %d days", zoom_t)
det1_zoom$panel <- sprintf("Zoom: first %d days", zoom_t)
runs_all <- rbind(runs1_zoom, runs1)
det_all <- rbind(det1_zoom, det1)
runs_all$panel <- factor(runs_all$panel, levels = unique(runs_all$panel))
det_all$panel <- factor(det_all$panel, levels = levels(runs_all$panel))

p3 <- ggplot() +
  geom_step(
    data = runs_all,
    aes(time, I, group = run, colour = outcome),
    alpha = 0.6,
    linewidth = 0.7
  ) +
  geom_line(data = det_all, aes(time, I), colour = col_det, linewidth = 1.3) +
  facet_wrap(~panel, scales = "free") +
  scale_colour_manual(
    values = c(
      "Fade-out (minor outbreak)" = col_minor,
      "Major epidemic" = col_major
    ),
    name = NULL
  ) +
  labs(
    x = "Time (days)",
    y = "Number infectious, I(t)",
    title = sprintf(
      "Starting from one case: %d of %d simulations fade out",
      sum(final$outcome != "Major epidemic"),
      n_runs
    ),
    subtitle = sprintf(
      "Black: deterministic SIR, which never fades out (N = %d, R0 = %s, I0 = 1)",
      N,
      R0
    )
  )
ggsave(
  file.path(out_dir, "fadeout_runs.png"),
  p3,
  width = 11,
  height = 5,
  dpi = 200
)

# ---- Figure 4: bimodal final size --------------------------------------------

set.seed(11)
n_runs <- 500
runs4 <- run_many(n_runs, R0, infectious_period, N, I0 = 1, t_max = 1000)
final4 <- aggregate(R ~ run, runs4, max)
final4$outcome <- ifelse(
  final4$R < 0.1 * N,
  "Fade-out (minor outbreak)",
  "Major epidemic"
)

p4 <- ggplot(final4, aes(R, fill = outcome)) +
  geom_histogram(binwidth = 20, boundary = 0, colour = "white") +
  scale_fill_manual(
    values = c(
      "Fade-out (minor outbreak)" = col_minor,
      "Major epidemic" = col_major
    ),
    name = NULL
  ) +
  labs(
    x = "Final epidemic size (total ever infected)",
    y = "Number of simulations",
    title = sprintf(
      "Final size of %d simulations starting from one case",
      n_runs
    ),
    subtitle = sprintf(
      "Fraction fading out: %.2f, compared with 1/R0 = %.2f",
      mean(final4$outcome != "Major epidemic"),
      1 / R0
    )
  )
ggsave(
  file.path(out_dir, "final_size_hist.png"),
  p4,
  width = 9,
  height = 5,
  dpi = 200
)

# ---- Figure 5: probability of fade-out vs 1/R0^n -----------------------------

set.seed(3)
R0_grid <- c(1.25, 1.5, 2, 2.5, 3, 4)
I0_grid <- c(1, 2, 3)
n_runs <- 300
pext <- expand.grid(R0 = R0_grid, I0 = I0_grid)
pext$p_sim <- mapply(
  function(r0, i0) {
    fs <- replicate(
      n_runs,
      max(sir_gillespie(r0, infectious_period, N, i0, t_max = 1000)$R)
    )
    mean(fs < 0.1 * N)
  },
  pext$R0,
  pext$I0
)
pext$p_theory <- 1 / pext$R0^pext$I0
pext$I0 <- factor(pext$I0, labels = paste0("I[0] == ", I0_grid))
theory <- expand.grid(R0 = seq(1.2, 4, by = 0.05), I0 = I0_grid)
theory$p_theory <- 1 / theory$R0^theory$I0
theory$I0 <- factor(theory$I0, labels = paste0("I[0] == ", I0_grid))

p5 <- ggplot() +
  geom_line(data = theory, aes(R0, p_theory), colour = col_det, linewidth = 1) +
  geom_point(data = pext, aes(R0, p_sim), colour = col_major, size = 3.5) +
  facet_wrap(~I0, labeller = label_parsed) +
  labs(
    x = expression(R[0]),
    y = "Probability of fade-out",
    title = "Chance of fade-out after introducing a few cases",
    subtitle = sprintf(
      "Points: fraction of %d simulations that faded out; line: 1 / R0^I0",
      n_runs
    )
  )
ggsave(
  file.path(out_dir, "pext_vs_R0.png"),
  p5,
  width = 10,
  height = 4.5,
  dpi = 200
)

message("Figures 1-5 written to ", out_dir)

# ---- Figure 6: ball-in-bowl schematic (redrawn after Keeling & Rohani 2008, Fig. 6.1) ----

set.seed(5)
bowl <- function(a, label) {
  data.frame(
    x = seq(-2, 2, length.out = 100),
    y = a * seq(-2, 2, length.out = 100)^2,
    panel = label
  )
}
panels <- c(
  "Deterministic attractor",
  "Added stochasticity",
  "Greater stochasticity",
  "Weaker attractor"
)
bowls <- rbind(
  bowl(1, panels[1]),
  bowl(1, panels[2]),
  bowl(1, panels[3]),
  bowl(0.25, panels[4])
)
bowls$panel <- factor(bowls$panel, levels = panels)

# Balls: one at rest for the deterministic panel; a cloud whose spread grows with noise / shallower bowl
ball_cloud <- function(n, sd, a, label) {
  x <- rnorm(n, 0, sd)
  data.frame(x = x, y = a * x^2 + 0.12, panel = label)
}
balls <- rbind(
  data.frame(x = 0, y = 0.12, panel = panels[1]),
  ball_cloud(25, 0.35, 1, panels[2]),
  ball_cloud(25, 0.8, 1, panels[3]),
  ball_cloud(25, 0.9, 0.25, panels[4])
)
balls$panel <- factor(balls$panel, levels = panels)

# Deterministic path: rolls down the side of the bowl and settles at the bottom
path <- data.frame(x = seq(-1.7, -0.25, length.out = 60))
path$y <- path$x^2 + 0.35
path$panel <- factor(panels[1], levels = panels)
start_ball <- data.frame(
  x = -1.75,
  y = 1.75^2 + 0.12,
  panel = factor(panels[1], levels = panels)
)

# "Shaking" arrows under the noisy bowls; longer arrows = more noise
shake <- data.frame(
  panel = factor(panels[2:4], levels = panels),
  half = c(0.5, 1.0, 0.5)
)

p6 <- ggplot() +
  geom_line(data = bowls, aes(x, y), linewidth = 1.2, colour = "grey30") +
  geom_path(
    data = path,
    aes(x, y),
    colour = col_major,
    linewidth = 1,
    linetype = "dashed",
    arrow = arrow(length = unit(0.25, "cm"), type = "closed")
  ) +
  geom_point(
    data = start_ball,
    aes(x, y),
    size = 3.5,
    colour = "steelblue",
    alpha = 0.4
  ) +
  geom_point(
    data = balls,
    aes(x, y),
    size = 3.5,
    colour = "steelblue",
    alpha = 0.8
  ) +
  geom_segment(
    data = shake,
    aes(x = -half, xend = half, y = -0.6, yend = -0.6),
    arrow = arrow(length = unit(0.25, "cm"), ends = "both", type = "closed"),
    linewidth = 0.9,
    colour = "grey30"
  ) +
  facet_wrap(~panel, ncol = 2) +
  coord_equal(ylim = c(-0.8, 4.2)) +
  theme_void(base_size = 16) +
  theme(
    strip.text = element_text(size = 15, face = "bold", margin = margin(b = 6)),
    plot.background = element_rect(fill = "white", colour = NA)
  )
ggsave(
  file.path(out_dir, "ball_in_bowl.png"),
  p6,
  width = 8,
  height = 6.5,
  dpi = 200
)

# ---- Figure 7: extinctions vs population size (own simulation) -----------------
#
# SIR with births, deaths and imports of infection, simulated with the tau-leap
# method (fixed step, Poisson event counts). Parameters follow Keeling & Rohani
# (2008), Section 6.3.3: R0 = 10, 1/gamma = 10 days, mu = 5.5e-5 per day,
# imports at 0.02 * sqrt(N) per year. An "extinction" is I dropping to zero.

sir_demog_tau <- function(
  N,
  R0 = 10,
  infectious_period = 10,
  mu = 5.5e-5,
  import_per_year = 0.02 * sqrt(N),
  years = 120,
  dt = 0.1
) {
  gamma <- 1 / infectious_period
  beta <- R0 * (gamma + mu)
  delta <- import_per_year / 365

  # Start near the deterministic endemic equilibrium
  S <- round(N / R0)
  I <- round(N * mu * (R0 - 1) / (gamma + mu) / R0)
  R <- N - S - I

  n_steps <- ceiling(years * 365 / dt)
  I_out <- integer(n_steps)

  for (k in seq_len(n_steps)) {
    inf <- min(S, rpois(1, (beta * S * I / N + delta) * dt))
    rec <- min(I, rpois(1, gamma * I * dt))
    births <- rpois(1, mu * N * dt)
    dS <- min(S - inf, rpois(1, mu * S * dt))
    dI <- min(I - rec, rpois(1, mu * I * dt))
    dR <- min(R, rpois(1, mu * R * dt))

    S <- S + births - inf - dS
    I <- I + inf - rec - dI
    R <- R + rec - dR
    I_out[k] <- I
  }
  data.frame(time = seq_len(n_steps) * dt / 365, I = I_out)
}

set.seed(8)
N_grid <- c(1e4, 2.5e4, 5e4, 1e5, 1.5e5, 2e5, 3e5, 4e5, 5e5, 7.5e5, 1e6)
n_reps <- 3 # independent 100-year runs per population size, averaged
burn_in <- 20
ext <- do.call(
  rbind,
  lapply(N_grid, function(n) {
    reps <- replicate(n_reps, {
      sim <- sir_demog_tau(n)
      sim <- sim[sim$time > burn_in, ]
      went_extinct <- sim$I == 0 & c(1, head(sim$I, -1)) > 0
      c(sum(went_extinct) / (max(sim$time) - burn_in), 100 * mean(sim$I == 0))
    })
    data.frame(
      N = n,
      extinctions_per_year = mean(reps[1, ]),
      pct_time_extinct = mean(reps[2, ])
    )
  })
)
print(ext)

ext_long <- rbind(
  data.frame(
    N = ext$N,
    value = ext$extinctions_per_year,
    panel = "Extinctions per year"
  ),
  data.frame(
    N = ext$N,
    value = ext$pct_time_extinct,
    panel = "Time with no infection (%)"
  )
)

p7 <- ggplot(ext_long, aes(N, value)) +
  geom_line(colour = col_major, linewidth = 1) +
  geom_point(colour = col_major, size = 3) +
  facet_wrap(~panel, scales = "free_y") +
  scale_x_continuous(labels = function(x) paste0(x / 1000, "k")) +
  labs(
    x = "Population size, N",
    y = NULL,
    title = "Larger populations lose the infection less often",
    subtitle = sprintf(
      "Stochastic SIR with births, deaths and imports of infection (R0 = 10, infectious period = 10 days)"
    )
  )
ggsave(
  file.path(out_dir, "extinctions_vs_N.png"),
  p7,
  width = 10,
  height = 4.5,
  dpi = 200
)

message("Done")
