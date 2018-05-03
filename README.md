
<!-- README.md is generated from README.Rmd. Please edit that file -->
ggsoccer <img src="man/figures/logo.png" width="160px" align="right" />
=======================================================================

Overview
--------

ggsoccer provides a handful of functions to make it easy to plot Opta-style soccer event data in R/ggplot2.

Installation
------------

ggsoccer is not currently available on CRAN and must be downloaded from github like so:

``` r
# install.packages("devtools")
devtools::install_github("torvaney/ggsoccer")
```

Usage
-----

The following example uses ggsoccer to solve a fairly realistic problem: plot a set of passes onto a soccer pitch.

``` r
library(ggplot2)
library(ggsoccer)

pass_data <- data.frame(x = c(24, 18, 64, 78, 53),
                        y = c(43, 55, 88, 18, 44),
                        x2 = c(34, 44, 81, 85, 64),
                        y2 = c(40, 62, 89, 44, 28))

ggplot(pass_data) +
  annotate_pitch() +
  geom_segment(aes(x = x, y = y, xend = x2, yend = y2),
               arrow = arrow(length = unit(0.25, "cm"),
                             type = "closed")) +
  theme_pitch() +
  direction_label() +
  xlim(-1, 101) +
  ylim(-5, 101) +
  ggtitle("Simple passmap", 
          "ggsoccer example")
```

![](man/figures/README-example_passes-1.png)

Because ggsoccer is implemented as ggplot layers, it makes customising a plot very easy. Here is a different example, plotting shots on a gray pitch:

``` r

shots <- data.frame(x = c(90, 85, 82, 78, 83, 74),
                    y = c(43, 40, 52, 56, 44, 71))

ggplot(shots, aes(x = x, y = y)) +
  annotate_pitch(colour = "gray50",
                 fill = "gray90") +
  geom_point(fill = "white", size = 3, pch = 21) +
  theme_pitch() +
  coord_flip(xlim = c(49, 101),
             ylim = c(-1, 101)) +
  ggtitle("Simple shotmap",
          "ggsoccer example")
```

![](man/figures/README-example_shots-1.png)
