#' Adds soccer pitch markings as a layer for use in a ggplot plot.
#'
#' @param colour Colour of pitch outline.
#' @param fill Colour of pitch fill.
#' @param limits Whether to adjust the plot limits to display the whole pitch.
#' @param dimensions A list containing the pitch dimensions to draw. See `help(pitch_opta)`.
#' @param goals A function for generating goal markings. Defaults to `goals_box`.
#' See `help(goals_box)`. Formulas are turned into functions with `rlang::as_function`.
#' @param linewidth The linewidth of the pitch markings
#' @param alpha The transparency of the pitch markings and fill
#' @param linetype The linetype of the pitch markings (e.g. "dotted")
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
annotate_pitch <- function(colour     = "dimgray",
                           fill       = "white",
                           limits     = TRUE,
                           dimensions = pitch_opta,
                           goals      = goals_box,
                           linewidth  = 0.5,
                           alpha      = 1,
                           linetype   = "solid") {
  goals_f <- rlang::as_function(goals)

  marking_layers <- unlist(list(
    annotate_base_pitch(colour, fill, dimensions, linewidth, alpha, linetype),
    annotate_penalty_box(colour, fill, dimensions, linewidth, alpha, linetype),
    annotate_six_yard_box(colour, fill, dimensions, linewidth, alpha, linetype),
    goals_f(colour = colour, fill = fill, dimensions = dimensions, linewidth = linewidth, alpha = alpha, linetype = linetype)
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

annotate_base_pitch <- function(colour, fill, spec, linewidth, alpha, linetype) {
  midpoint <- pitch_center(spec)

  # NOTE: Alpha not included in lines and points for consistency
  # On the `rect`s, it refers to the alpha of the fill,
  # whereas on the segments, it refers to the segments of
  # the line itself. Since we want all the lines to look the
  # same, we don't add the alpha argument to lines and points.
  list(
    ggplot2::annotate(
      geom = "rect",
      xmin = spec$origin_x,
      xmax = spec$origin_x + spec$length,
      ymin = spec$origin_y,
      ymax = spec$origin_y + spec$width,
      colour    = colour,
      fill      = fill,
      linewidth = linewidth,
      alpha     = alpha,
      linetype  = linetype,
      lineend   = "round"
    ),
    # Centre circle
    annotate_circle(
      x = midpoint$x,
      y = midpoint$y,
      r = spec$penalty_spot_distance,
      colour    = colour,
      linewidth = linewidth,
      linetype  = linetype,
      lineend   = "round"
    ),
    # Centre spot
    ggplot2::annotate(
      geom = "point",
      x = midpoint$x,
      y = midpoint$y,
      colour   = colour,
      size     = linewidth*2
    ),
    # Halfway line
    ggplot2::annotate(
      "segment",
      x = midpoint$x,
      xend = midpoint$x,
      y = spec$origin_y,
      yend = spec$origin_y + spec$width,
      colour    = colour,
      linewidth = linewidth,
      linetype  = linetype,
      lineend   = "round"
    )
  )
}

annotate_penalty_box <- function(colour, dimensions, spec, linewidth, alpha, linetype) {
  midpoint <- pitch_center(spec)

  # NOTE: Penalty boxes are drawn as 3 lines because we don't want to overlap
  # with the base pitch. This can cause inconsistency when the `linetype` argument
  # is provided.

  list(
    # Right penalty box
    ggplot2::annotate(
      geom = "segment",
      x    = spec$origin_x + spec$length - spec$penalty_box_length,
      xend = spec$origin_x + spec$length,
      y    = midpoint$y - spec$penalty_box_width/2,
      yend = midpoint$y - spec$penalty_box_width/2,
      colour    = colour,
      linewidth = linewidth,
      linetype  = linetype,
      lineend   = "round"
    ),
    ggplot2::annotate(
      geom = "segment",
      x    = spec$origin_x + spec$length - spec$penalty_box_length,
      xend = spec$origin_x + spec$length - spec$penalty_box_length,
      y    = midpoint$y - spec$penalty_box_width/2,
      yend = midpoint$y + spec$penalty_box_width/2,
      colour    = colour,
      linewidth = linewidth,
      linetype  = linetype,
      lineend   = "round"
    ),
    ggplot2::annotate(
      geom = "segment",
      x    = spec$origin_x + spec$length - spec$penalty_box_length,
      xend = spec$origin_x + spec$length,
      y    = midpoint$y + spec$penalty_box_width/2,
      yend = midpoint$y + spec$penalty_box_width/2,
      colour    = colour,
      linewidth = linewidth,
      linetype  = linetype,
      lineend   = "round"
    ),
    # Right penalty arc
    annotate_intersection_arc(
      xintercept = spec$origin_x + spec$length - spec$penalty_box_length,
      x0 = spec$origin_x + spec$length - spec$penalty_spot_distance,
      y0 = midpoint$y,
      r  = spec$penalty_spot_distance,
      direction = "left",
      colour    = colour,
      linewidth = linewidth,
      linetype  = linetype,
      lineend   = "round"
    ),
    # Right penalty spot
    ggplot2::annotate(
      geom = "point",
      x = spec$origin_x + spec$length - spec$penalty_spot_distance,
      y = midpoint$y,
      colour   = colour,
      size     = linewidth*2
    ),
    # Left penalty area
    ggplot2::annotate(
      geom = "segment",
      x    = spec$origin_x,
      xend = spec$origin_x + spec$penalty_box_length,
      y    = midpoint$y - spec$penalty_box_width/2,
      yend = midpoint$y - spec$penalty_box_width/2,
      colour    = colour,
      linewidth = linewidth,
      linetype  = linetype,
      lineend   = "round"
    ),
    ggplot2::annotate(
      geom = "segment",
      x    = spec$origin_x + spec$penalty_box_length,
      xend = spec$origin_x + spec$penalty_box_length,
      y    = midpoint$y - spec$penalty_box_width/2,
      yend = midpoint$y + spec$penalty_box_width/2,
      colour    = colour,
      linewidth = linewidth,
      linetype  = linetype,
      lineend   = "round"
    ),
    ggplot2::annotate(
      geom = "segment",
      x    = spec$origin_x,
      xend = spec$origin_x + spec$penalty_box_length,
      y    = midpoint$y + spec$penalty_box_width/2,
      yend = midpoint$y + spec$penalty_box_width/2,
      colour    = colour,
      linewidth = linewidth,
      linetype  = linetype,
      lineend   = "round"
    ),
    # Left penalty arc
    annotate_intersection_arc(
      xintercept = spec$origin_x + spec$penalty_box_length,
      x0 = spec$origin_x + spec$penalty_spot_distance,
      y0 = midpoint$y,
      r  = spec$penalty_spot_distance,
      direction = "right",
      colour    = colour,
      linewidth = linewidth,
      linetype  = linetype,
      lineend   = "round"
    ),
    # Left penalty spot
    ggplot2::annotate(
      geom = "point",
      x = spec$origin_x + spec$penalty_spot_distance,
      y = midpoint$y,
      colour   = colour,
      size     = linewidth*2
    )
  )
}

annotate_six_yard_box <- function(colour, dimensions, spec, linewidth, alpha, linetype) {
  midpoint <- pitch_center(spec)

  # NOTE: As with penalty boxes, six-yard boxes are drawn as 3 lines because we
  # don't want to overlap with the base pitch. This can cause inconsistency when
  # the `linetype` argument
  # is provided.

  list(
    # Right 6yb
    ggplot2::annotate(
      geom = "segment",
      x    = spec$origin_x + spec$length - spec$six_yard_box_length,
      xend = spec$origin_x + spec$length,
      y    = midpoint$y - spec$six_yard_box_width/2,
      yend = midpoint$y - spec$six_yard_box_width/2,
      colour    = colour,
      linewidth = linewidth,
      linetype  = linetype,
      lineend   = "round"
    ),
    ggplot2::annotate(
      geom = "segment",
      x    = spec$origin_x + spec$length - spec$six_yard_box_length,
      xend = spec$origin_x + spec$length - spec$six_yard_box_length,
      y    = midpoint$y - spec$six_yard_box_width/2,
      yend = midpoint$y + spec$six_yard_box_width/2,
      colour    = colour,
      linewidth = linewidth,
      linetype  = linetype,
      lineend   = "round"
    ),
    ggplot2::annotate(
      geom = "segment",
      x    = spec$origin_x + spec$length - spec$six_yard_box_length,
      xend = spec$origin_x + spec$length,
      y    = midpoint$y + spec$six_yard_box_width/2,
      yend = midpoint$y + spec$six_yard_box_width/2,
      colour    = colour,
      linewidth = linewidth,
      linetype  = linetype,
      lineend   = "round"
    ),
    # Left 6yb
    ggplot2::annotate(
      geom = "segment",
      x    = spec$origin_x,
      xend = spec$origin_x + spec$six_yard_box_length,
      y    = midpoint$y - spec$six_yard_box_width/2,
      yend = midpoint$y - spec$six_yard_box_width/2,
      colour    = colour,
      linewidth = linewidth,
      linetype  = linetype,
      lineend   = "round"
    ),
    ggplot2::annotate(
      geom = "segment",
      x    = spec$origin_x + spec$six_yard_box_length,
      xend = spec$origin_x + spec$six_yard_box_length,
      y    = midpoint$y - spec$six_yard_box_width/2,
      yend = midpoint$y + spec$six_yard_box_width/2,
      colour    = colour,
      linewidth = linewidth,
      linetype  = linetype,
      lineend   = "round"
    ),
    ggplot2::annotate(
      geom = "segment",
      x    = spec$origin_x,
      xend = spec$origin_x + spec$six_yard_box_length,
      y    = midpoint$y + spec$six_yard_box_width/2,
      yend = midpoint$y + spec$six_yard_box_width/2,
      colour    = colour,
      linewidth = linewidth,
      linetype  = linetype,
      lineend   = "round"
    )
  )
}

annotate_intersection_arc <- function(xintercept, x0, y0, r, direction, ...) {
  direction <- match.arg(direction, c("left", "right"))
  direction_values <- c(left = 1, right = -1)

  # Find intersection of arc with a vertical line
  # (Assuming there is a valid intersection...)
  # This determines the start and end points, and the curvature
  suppressWarnings({
    pos_y <-  sqrt(r^2 - (xintercept - x0)^2) + y0
    neg_y <- -sqrt(r^2 - (xintercept - x0)^2) + y0
  })

  # It's possible (but very unlikely) that the provided dimensions don't result
  # in the penalty box intersecting with the penalty arc, or result in a single
  # intersection point (pos and neg roots are the same).
  # If this does happen, we provide a warning
  if (is.nan(pos_y) | (pos_y == neg_y)) {
    warning("Penalty box arc does not intersect with penalty box and won't appear with the current dimensions", call. = FALSE)
    return(list())
  }

  # Determine the curvature by finding the central angle
  # I *think* I can approximate the curvature is just a ratio (i.e. x:1)
  # so a curvature of 1 is 1:1, or 50% of the circle.
  # i.e. curvature / (curvature + 1) = arc proportion
  # This isn't *exactly* correct (you can check by layering an
  # `annotate_intersection_arc` with `xintercept = spec$penalty_spot_distance`
  # on top of a pitch_international pitch and comparing to the drawn arc)
  # but it is close enough.
  angle <- acos((r^2 + r^2 - abs(pos_y - neg_y)^2)/(2*r^2))
  arc_proportion <- angle/(2*pi)
  curvature <- -arc_proportion/(arc_proportion-1)

  ggplot2::annotate(
    geom   = "curve",
    x      = xintercept,
    xend   = xintercept,
    y      = pos_y,
    yend   = neg_y,
    curvature = curvature*direction_values[direction],
    ncp    = 100,
    ...
  )
}

annotate_circle <- function(x, y, r, ...) {
  list(
    annotate_intersection_arc(xintercept = x, x0 = x, y0 = y, r = r, direction = "left", ...),
    annotate_intersection_arc(xintercept = x, x0 = x, y0 = y, r = r, direction = "right", ...)
  )
}


# Goals components -------------------------------------------------------------

#' Goals markings
#'
#' Various functions can be supplied to `annotate_pitch` to specify the appearance
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
#' @param alpha Determines alpha in `goals_box`.
#' @param linetype Determines linetype in `goals_box` and `goals_strip`.
#' @param linewidth Determines line thickness in `goals_strip` and `goals_line`.
#' @param lineend Determines lineend in `goals_strip` and `goals_line`.
#' @param relative_width Determines relative width of the goal marking to the pitch markings in `goals_line`.
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
#'   annotate_pitch(goals = ~ goals_box(..., offset = 4)) +
#'   geom_point()
#'
#' @export
goals_box <- function(colour, fill, dimensions, linewidth = 1, alpha = 1, linetype = "solid", offset = 2, ...) {
  midpoint <- pitch_center(dimensions)

  list(
    ggplot2::annotate(
      geom = "rect",
      xmin = dimensions$origin_x + dimensions$length,
      xmax = dimensions$origin_x + dimensions$length + offset,
      ymin = midpoint$y - dimensions$goal_width/2,
      ymax = midpoint$y + dimensions$goal_width/2,
      colour    = colour,
      fill      = fill,
      linewidth = linewidth,
      alpha     = alpha,
      linetype  = linetype,
      ...
    ),
    ggplot2::annotate(
      geom = "rect",
      xmin = dimensions$origin_x - offset,
      xmax = dimensions$origin_x,
      ymin = midpoint$y - dimensions$goal_width/2,
      ymax = midpoint$y + dimensions$goal_width/2,
      colour    = colour,
      fill      = fill,
      linewidth = linewidth,
      alpha     = alpha,
      linetype  = linetype,
      ...
    )
  )
}

#' @rdname goals_box
#' @importFrom rlang %||%
#' @export
goals_strip <- function(colour, fill, dimensions, linewidth = 1, alpha = 1, linetype = "solid", offset = 1, lineend = "round", ...) {
  midpoint <- pitch_center(dimensions)

  list(
    ggplot2::annotate(
      geom = "segment",
      x    = dimensions$origin_x + dimensions$length + offset,
      xend = dimensions$origin_x + dimensions$length + offset,
      y    = midpoint$y - dimensions$goal_width/2,
      yend = midpoint$y + dimensions$goal_width/2,
      colour    = colour,
      linewidth = linewidth,
      linetype  = linetype,
      lineend   = lineend,
      ...
    ),
    ggplot2::annotate(
      geom = "segment",
      x    = dimensions$origin_x - offset,
      xend = dimensions$origin_x - offset,
      y    = midpoint$y - dimensions$goal_width/2,
      yend = midpoint$y + dimensions$goal_width/2,
      colour    = colour,
      linewidth = linewidth,
      linetype  = linetype,
      lineend   = lineend,
      ...
    )
  )
}

#' @rdname goals_box
#' @export
goals_line <- function(colour, fill, dimensions, ..., linewidth = 1, linetype = NULL, relative_width = 3) {
  # Function arguments absorb linetype (removing them from `...`) because we *always*
  # want this to be solid

  # We want the goals line to be responsive to the size of the rest of the pitch markings
  # To do this, we multiply the provided size for the rest of the pitch markings by
  # a scaling factor, `relative_width`
  goals_strip(colour, fill, dimensions, linewidth = linewidth*relative_width, ..., offset = 0)
}

# Helper functions

pitch_center <- function(spec) {
  list(x = spec$origin_x + spec$length/2,
       y = spec$origin_y + spec$width/2)
}
