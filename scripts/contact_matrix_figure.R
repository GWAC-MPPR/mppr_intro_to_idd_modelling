#' Illustrative age-structured contact matrix (heatmap) for the heterogeneity slides.
#'
#' Run from the repository root:
#'   RENV_CONFIG_AUTOLOADER_ENABLED=FALSE Rscript scripts/contact_matrix_figure.R
#' Writes images/contact_matrix.png. Needs {ggplot2}.
#'
#' The numbers are made up to show the typical shape of a contact matrix from a
#' survey such as POLYMOD: a dominant diagonal (people mostly meet people of
#' their own age) and a weaker off-diagonal band for parent-child contacts.

library(ggplot2)

ages <- c("0-4", "5-17", "18-64", "65+")
# Rows: age of the individual (i); columns: age of their contact (j).
# Entries: mean number of contacts per day.
m <- matrix(c(
  4.0, 2.5, 3.5, 0.5,
  1.5, 9.0, 4.0, 0.6,
  1.0, 2.0, 7.0, 1.2,
  0.4, 0.8, 3.0, 2.5
), nrow = 4, byrow = TRUE, dimnames = list(ages, ages))

d <- expand.grid(i = ages, j = ages, stringsAsFactors = FALSE)
d$contacts <- as.vector(m[cbind(match(d$i, ages), match(d$j, ages))])
d$i <- factor(d$i, levels = rev(ages)) # youngest at the top
d$j <- factor(d$j, levels = ages)

p <- ggplot(d, aes(x = j, y = i, fill = contacts)) +
  geom_tile(colour = "white", linewidth = 1) +
  geom_text(aes(label = sprintf("%.1f", contacts)), size = 5.5,
            colour = ifelse(d$contacts > 5, "white", "grey20")) +
  scale_fill_gradient(low = "white", high = "tomato", name = "Contacts\nper day") +
  scale_x_discrete(position = "top") +
  labs(x = "Age of contact (j)", y = "Age of individual (i)") +
  coord_equal() +
  theme_minimal(base_size = 16) +
  theme(panel.grid = element_blank(),
        axis.title.x = element_text(margin = margin(b = 6)),
        plot.background = element_rect(fill = "white", colour = NA))

ggsave("images/contact_matrix.png", p, width = 6.5, height = 5, dpi = 200)
message("Wrote images/contact_matrix.png")
