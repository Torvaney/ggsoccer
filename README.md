
<!-- README.md is generated from README.Rmd. Please edit that file -->

# ggsoccer <img src="man/figures/logo.png" width="160px" align="right" />

<!-- badges: start -->

[![CRAN\_Status\_Badge](http://www.r-pkg.org/badges/version/ggsoccer)](https://cran.r-project.org/package=ggsoccer)
[![CRAN\_Version\_Badge](https://cranlogs.r-pkg.org/badges/ggsoccer?color=ff69b4)](https://cran.r-project.org/package=ggsoccer)
[![lifecycle](https://img.shields.io/badge/lifecycle-stable-brightgreen.svg)](https://www.tidyverse.org/lifecycle/#stable)
[![R-CMD-check](https://github.com/Torvaney/ggsoccer/workflows/R-CMD-check/badge.svg)](https://github.com/Torvaney/ggsoccer/actions)
<!-- badges: end -->

## Overview

ggsoccer provides a handful of functions that make it easy to plot
soccer event data in R/ggplot2 from a variety of data providers.

## Installation

ggsoccer is available via CRAN:

``` r
install.packages("ggsoccer")
```

Alternatively, you can download the latest version from github like so:

``` r
# install.packages("remotes")
remotes::install_github("torvaney/ggsoccer")
```

## Usage

``` r
library(ggplot2)
library(ggsoccer)

ggplot() +
  annotate_pitch() +
  theme_pitch()
```

![](man/figures/README-example_blank-1.png)<!-- -->

The following example uses ggsoccer to solve a realistic problem:
plotting a set of passes onto a soccer pitch.

``` r
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
  ggtitle("Simple passmap", 
          "ggsoccer example")
```

![](man/figures/README-example_passes-1.png)<!-- -->

Because ggsoccer is implemented as ggplot layers, it makes customising a
plot very easy. Here is a different example, plotting shots on a
**green** pitch.

Note that by default, ggsoccer will display the whole pitch. To display
a subsection of the pitch, simply set the plot limits as you would with
any other ggplot2 plot. Here, we use the `xlim` and `ylim` arguments to
`coord_flip`.

Because of the way coordinates get flipped, we must also reverse the
y-axis to ensure that the orientation remains correct.

NOTE: Ordinarily, we would just do this with `scale_y_reverse`. However,
due to a [bug in
ggplot2](https://github.com/tidyverse/ggplot2/issues/3120), this results
in certain elements of the pitch (centre circle and penalty box arcs)
failing to render. Instead, we can flip the y coordinates manually (`100
- y` in this case).

``` r

shots <- data.frame(x = c(90, 85, 82, 78, 83, 74, 94, 91),
                    y = c(43, 40, 52, 56, 44, 71, 60, 54))

ggplot(shots) +
  annotate_pitch(colour = "white",
                 fill   = "springgreen4",
                 limits = FALSE) +
  geom_point(aes(x = x, y = 100 - y),
             fill = "yellow", 
             shape = 21,
             size = 4) +
  theme_pitch() +
  theme(panel.background = element_rect(fill = "springgreen4")) +
  coord_flip(xlim = c(49, 101),
             ylim = c(-12, 112)) +
  ggtitle("Simple shotmap",
          "ggsoccer example")
```

![](man/figures/README-example_shots-1.png)<!-- -->

### Data providers

ggsoccer defaults to Opta’s 100x100 coordinate system. However,
different data providers may use alternative coordinates.

ggsoccer provides support for a few data providers out of the box, as
well as an interface for any custom coordinate system:

  - Opta
  - Statsbomb
  - Wyscout

#### Statsbomb

``` r
# ggsoccer enables you to rescale coordinates from one data provider to another, too
to_statsbomb <- rescale_coordinates(from = pitch_opta, to = pitch_statsbomb)

passes_rescaled <- data.frame(x  = to_statsbomb$x(pass_data$x),
                              y  = to_statsbomb$y(pass_data$y),
                              x2 = to_statsbomb$x(pass_data$x2),
                              y2 = to_statsbomb$y(pass_data$y2))

ggplot(passes_rescaled) +
  annotate_pitch(dimensions = pitch_statsbomb) +
  geom_segment(aes(x = x, y = y, xend = x2, yend = y2),
               colour = "coral",
               arrow = arrow(length = unit(0.25, "cm"),
                             type = "closed")) +
  theme_pitch() +
  direction_label(x_label = 60) +
  ggtitle("Simple passmap", 
          "Statsbomb co-ordinates")
```

![](man/figures/README-example_passes_sb-1.png)<!-- -->

#### Custom data

To plot data for a dataset not provided, ggsoccer just requires a pitch
specification. This is a list containing the required pitch dimensions
like so:

``` r
pitch_custom <- list(
  length = 150,
  width = 100,
  penalty_box_length = 25,
  penalty_box_width = 50,
  six_yard_box_length = 8,
  six_yard_box_width = 26,
  penalty_spot_distance = 16,
  goal_width = 12,
  origin_x = 0,
  origin_y = 0
)

ggplot() +
  annotate_pitch(dimensions = pitch_custom) +
  theme_pitch()
```

![](man/figures/README-example_custom-1.png)<!-- -->

### Goals customisation

The standard “box” goals may not be perfectly suited to your use-case.
ggsoccer allows you to customise your goals markings by supplying a
function to the `goals` argument of `annotate_pitch`:

``` r
ggplot() +
  annotate_pitch(fill = "steelblue4", colour = "white", goals = goals_line) +
  theme_pitch() +
  theme(panel.background = element_rect(fill = "steelblue4"))
```

![](man/figures/README-example_goals_line-1.png)<!-- -->

``` r
ggplot() +
  annotate_pitch(goals = goals_strip, fill = "lightgray") +
  theme_pitch()
```

![](man/figures/README-example_goals_strip-1.png)<!-- -->

Since this argument just requires a function, you can modify the
supplied functions, or create your own goal markings function.

The `goals` argument also supports using one-sided formulas as lambda
functions (see
[`rlang::as_function`](https://rlang.r-lib.org/reference/as_function.html))
to modify or extend the existing goals functions:

``` r
if (require(ggpattern)) {
  ggplot() +
    annotate_pitch(
      goals = ~ goals_box(
        ..., 
        geom = ggpattern::GeomRectPattern,
        pattern_density = 0.1, 
        pattern_spacing = 0.007,
        pattern_colour = "gray",
        pattern_fill = "whitesmoke",
        ),
      fill = "whitesmoke"
    ) +
    theme_pitch()
}
#> Warning in library(package, lib.loc = lib.loc, character.only = TRUE,
#> logical.return = TRUE, : there is no package called 'ggpattern'
```

See `help(goals_box)` for the full list of available functions.

The idea for having multiple goal markings was taken and adapted from
the [fc.rstats](https://github.com/FCrSTATS/fc.rstats) package.

## Other options

There are other packages that offer alternative pitch plotting options.
Depending on your use case, you may want to check these out too:

  - [soccermatics](https://github.com/JoGall/soccermatics)
  - [SBpitch](https://github.com/FCrSTATS/SBpitch)
  - [fc.rstats](https://github.com/FCrSTATS/fc.rstats)

### Python

There are a couple of pitch plotting options for matplotlib, too:

  - [mplsoccer](https://github.com/andrewRowlinson/mplsoccer)
  - [matplotsoccer](https://github.com/TomDecroos/matplotsoccer)
