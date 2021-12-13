# Goals components -------------------------------------------------------------

#' Goals markings
#'
#' Various functions can be supplied to `annotate_pitch` to specify the appearance
#' of goals in the resulting plot.
#'
#' Each function takes `colour`, `fill`, and `dimensions` arguments. User-defined
#' functions with the same arguments can also be used.
#'
#' `goals_box` is used for goals that take a 2d, rectangular appearance.
#'
#' `goals_strip` is used for goals that take the appearance of a single line.
#' By default, this line appears offset from the goalline. However, this can
#' be modified by the `offset` parameter.
#'
#' A `goals_line` function is provided for
#' convenience which is like `goals_strip` except that it places the line on the
#' goalline (`offset = 0`).
#'
#' @param colour Colour of pitch outline.
#' @param fill Colour of pitch fill.
#' @param dimensions A list containing the pitch dimensions to draw. See `help(pitch_opta)`.
#' @param ... Passed onto underlying `ggplot2::annotate` calls.
#' @param offset Determines how deep the goal extends.
#' @param size Determines line thickness in `goals_strip` and `goals_line`.
#' @param lineend Determines lineend in `goals_strip` and `goals_line`.
#' @param geom Determines the geom to use for goals in `goals_box`. This argument
#' can be used for deeper customisation, for instance, by using `geom = ggpattern::GeomRectPattern`
#'
#' @return list of ggplot geoms to be added to a ggplot plot
#'
#' @examples
#' library(ggplot2)
#'
#' shots_data <- data.frame(x = c(90, 85, 82, 78, 83),
#'                          y = c(43, 40, 52, 56, 44))
#'
#' # Default
#' ggplot(shots_data, aes(x = x, y = y)) +
#'   annotate_pitch(goals = goals_box) +
#'   geom_point()
#'
#' # Other goals markings
#' ggplot(shots_data, aes(x = x, y = y)) +
#'   annotate_pitch(goals = goals_strip) +
#'   geom_point()
#'
#' # Partial functions can be used to customise further
#' ggplot(shots_data, aes(x = x, y = y)) +
#'   annotate_pitch(goals = ~ goals_strip(..., size = 2)) +
#'   geom_point()
#'
#' @include dimensions.R
#' @export
goals_box <- function(colour, fill, dimensions, offset = 2, ..., geom = "rect") {
  midpoint <- pitch_center(dimensions)

  list(
    ggplot2::annotate(
      geom = geom,
      xmin = dimensions$origin_x + dimensions$length,
      xmax = dimensions$origin_x + dimensions$length + offset,
      ymin = midpoint$y - dimensions$goal_width/2,
      ymax = midpoint$y + dimensions$goal_width/2,
      colour = colour,
      fill = fill,
      ...
    ),
    ggplot2::annotate(
      geom = geom,
      xmin = dimensions$origin_x - offset,
      xmax = dimensions$origin_x,
      ymin = midpoint$y - dimensions$goal_width/2,
      ymax = midpoint$y + dimensions$goal_width/2,
      colour = colour,
      fill = fill,
      ...
    )
  )
}

#' @rdname goals_box
#' @importFrom rlang %||%
#' @export
goals_strip <- function(colour, fill, dimensions, offset = 1, size = 1, lineend = "round", ...) {
  midpoint <- pitch_center(dimensions)

  list(
    ggplot2::annotate(
      geom = "segment",
      x    = dimensions$origin_x + dimensions$length + offset,
      xend = dimensions$origin_x + dimensions$length + offset,
      y    = midpoint$y - dimensions$goal_width/2,
      yend = midpoint$y + dimensions$goal_width/2,
      colour = colour,
      size = size,
      lineend = lineend,
      ...
    ),
    ggplot2::annotate(
      geom = "segment",
      x    = dimensions$origin_x - offset,
      xend = dimensions$origin_x - offset,
      y    = midpoint$y - dimensions$goal_width/2,
      yend = midpoint$y + dimensions$goal_width/2,
      colour = colour,
      size = size,
      lineend = lineend,
      ...
    )
  )
}

#' @rdname goals_box
#' @export
goals_line <- function(colour, fill, dimensions, ..., offset = 0, size = 1.5) {
  goals_strip(colour, fill, dimensions, offset = offset, size = size, ...)
}
