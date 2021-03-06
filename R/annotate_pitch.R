#' Adds soccer pitch markings as a layer for use in a ggplot plot.
#'
#' @param colour Colour of pitch outline.
#' @param fill Colour of pitch fill.
#' @param limits Whether to adjust the plot limits to display the whole pitch.
#' @param dimensions A list containing the pitch dimensions to draw. See `help(pitch_opta)`.
#' @param goals A function for generating goal markings. Defaults to `goals_box`.
#' See `help(goals_box)`. Formulas are turned into functions with `rlang::as_function`.
#'
#' @return list of ggplot geoms to be added to a ggplot plot
#'
#' @examples
#' library(ggplot2)
#'
#' shots_data <- data.frame(x = c(90, 85, 82, 78, 83),
#'                          y = c(43, 40, 52, 56, 44))
#'
#' ggplot(shots_data, aes(x = x, y = y)) +
#'   annotate_pitch() +
#'   geom_point()
#'
#' @export
annotate_pitch <- function(colour   = "dimgray",
                           fill     = "white",
                           limits   = TRUE,
                           dimensions = pitch_opta,
                           goals = goals_box) {
  goals_f <- rlang::as_function(goals)

  # NOTE: could parameterise the whole function by the list of layer-creation
  #       functions it uses. We could then open up the API for user-defined pitch
  #       elements (e.g. a custom goal type)
  marking_layers <- unlist(list(
    annotate_base_pitch(colour, fill, dimensions),
    annotate_penalty_box(colour, fill, dimensions),
    annotate_six_yard_box(colour, fill, dimensions),
    goals_f(colour = colour, fill = fill, dimensions = dimensions)
  ), recursive = FALSE)

  if (!limits) {
    return(marking_layers)
  }

  # Leave room for full pitch + goals and direction_label by default
  limit_layers <- list(
    ggplot2::xlim(dimensions$origin_x - 3,
                  dimensions$origin_x + dimensions$length + 3),
    ggplot2::ylim(dimensions$origin_y - 5,
                  dimensions$origin_y + dimensions$width + 3)
  )

  append(
    marking_layers,
    limit_layers,
  )
}

# Pitch components -------------------------------------------------------------
# Add markings for parts of a soccer pitch.
# NOTE: Should these be exposed for top-level use?

annotate_base_pitch <- function(colour, fill, spec) {
  midpoint <- pitch_center(spec)

  list(
    ggplot2::annotate(
      geom = "rect",
      xmin = spec$origin_x,
      xmax = spec$origin_x + spec$length,
      ymin = spec$origin_y,
      ymax = spec$origin_y + spec$width,
      colour = colour,
      fill = fill
    ),
    # Centre circle
    annotate_circle(
      x = midpoint$x,
      y = midpoint$y,
      r = spec$penalty_spot_distance,
      colour = colour,
      fill = fill
    ),
    # Centre spot
    ggplot2::annotate(
      geom = "point",
      x = midpoint$x,
      y = midpoint$y,
      colour = colour,
      fill = fill
    ),
    # Halfway line
    ggplot2::annotate(
      "segment",
      x = midpoint$x,
      xend = midpoint$x,
      y = spec$origin_y,
      yend = spec$origin_y + spec$width,
      colour = colour
    )
  )
}

annotate_penalty_box <- function(colour, fill, spec) {
  midpoint <- pitch_center(spec)

  list(
    # Right penalty area
    annotate_circle(
      x      = spec$origin_x + spec$length - spec$penalty_spot_distance,
      y      = midpoint$y,
      r      = spec$penalty_spot_distance,
      colour = colour,
      fill   = fill
    ),
    ggplot2::annotate(
      geom = "rect",
      xmin = spec$origin_x + spec$length - spec$penalty_box_length,
      xmax = spec$origin_x + spec$length,
      ymin = midpoint$y - spec$penalty_box_width/2,
      ymax = midpoint$y + spec$penalty_box_width/2,
      colour = colour,
      fill = fill
    ),
    ## Penalty spot
    ggplot2::annotate(
      geom = "point",
      x = spec$origin_x + spec$length - spec$penalty_spot_distance,
      y = midpoint$y,
      colour = colour,
      fill = fill
    ),
    # Left penalty area
    annotate_circle(
      x      = spec$origin_x + spec$penalty_spot_distance,
      y      = midpoint$y,
      r      = spec$penalty_spot_distance,
      colour = colour,
      fill   = fill
    ),
    ggplot2::annotate(
      geom = "rect",
      xmin = spec$origin_x,
      xmax = spec$origin_x + spec$penalty_box_length,
      ymin = midpoint$y - spec$penalty_box_width/2,
      ymax = midpoint$y + spec$penalty_box_width/2,
      colour = colour,
      fill = fill
    ),
    ## Penalty spot
    ggplot2::annotate(
      geom = "point",
      x = spec$origin_x + spec$penalty_spot_distance,
      y = midpoint$y,
      colour = colour,
      fill = fill
    )
  )
}

annotate_six_yard_box <- function(colour, fill, spec) {
  midpoint <- pitch_center(spec)

  list(
    ggplot2::annotate(
      geom = "rect",
      xmin = spec$origin_x + spec$length - spec$six_yard_box_length,
      xmax = spec$origin_x + spec$length,
      ymin = midpoint$y - spec$six_yard_box_width/2,
      ymax = midpoint$y + spec$six_yard_box_width/2,
      colour = colour,
      fill = fill
    ),
    ggplot2::annotate(
      geom = "rect",
      xmin = spec$origin_x,
      xmax = spec$origin_x + spec$six_yard_box_length,
      ymin = midpoint$y - spec$six_yard_box_width/2,
      ymax = midpoint$y + spec$six_yard_box_width/2,
      colour = colour,
      fill = fill
    )
  )
}


# Goals components -------------------------------------------------------------

#' Goals markings
#'
#' Various functions ca be supplied to `annotate_pitch` to specify the appearance
#' of goals in the resulting plot.
#'
#' Each function takes `colour`, `fill`, and `dimensions` arguments. User-defined
#' functions with the same arguments can also be used
#'
#' @param colour Colour of pitch outline.
#' @param fill Colour of pitch fill.
#' @param dimensions A list containing the pitch dimensions to draw. See `help(pitch_opta)`.
#' @param ... Passed onto underlying `ggplot2::annotate` calls.
#' @param offset Determines how deep the goal extends.
#' @param size Determines line thickness in `goals_strip` and `goals_line`.
#' @param lineend Determines lineend in `goals_strip` and `goals_line`.
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
#' @export
goals_box <- function(colour, fill, dimensions, offset = 2, ...) {
  midpoint <- pitch_center(dimensions)

  list(
    ggplot2::annotate(
      geom = "rect",
      xmin = dimensions$origin_x + dimensions$length,
      xmax = dimensions$origin_x + dimensions$length + offset,
      ymin = midpoint$y - dimensions$goal_width/2,
      ymax = midpoint$y + dimensions$goal_width/2,
      colour = colour,
      fill = fill,
      ...
    ),
    ggplot2::annotate(
      geom = "rect",
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
goals_line <- function(colour, fill, dimensions, ...) {
  goals_strip(colour, fill, dimensions, offset = 0, size = 1.5, ...)
}

# Helper functions

pitch_center <- function(spec) {
  list(x = spec$origin_x + spec$length/2,
       y = spec$origin_y + spec$width/2)
}

annotate_circle <- function(x, y, r, colour, fill) {
  ggplot2::annotation_custom(
    grob = grid::circleGrob(gp = grid::gpar(col  = colour, fill = fill, lwd  = 1.5)),
    xmin = x - r,
    xmax = x + r,
    ymin = y - r,
    ymax = y + r
  )
}
