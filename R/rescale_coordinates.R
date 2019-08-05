#' Rescale x-y coordinates
#'
#' @description Returns a list containing 2 functions to translate x and y coordinates,
#' from one set of pitch dimensions (i.e. data provider) to another.
#'
#' Any x or y coordinate is rescaled linearly between the nearest two pitch markings.
#' For example, the edge of the penalty box and the half way-line.
#'
#' @param from The dimensions to convert from (see `help(dimensions)`)
#' @param to The dimensions to convert to (see `help(dimensions)`)
#'
#' @details `pitch_international` creates a rescaler to `pitch_international`
#' coordinates.
#'
#' @examples
#'
#' opta_to_wyscout <- rescale_coordinates(
#'   from = pitch_opta,
#'   to   = pitch_wyscout
#' )
#'
#' opta_xs <- c(10, 22, 55, 78)
#' opta_ys <- c(10, 22, 55, 78)
#'
#' opta_to_wyscout$x(opta_xs)
#' #> c(9.75000, 21.15152, 55.15152, 78.84848)
#'
#' opta_to_wyscout$y(opta_ys)
#' #> c(9.004739, 20.031847, 55.172414, 79.968153)
#'
#' @export
rescale_coordinates <- function(from, to) {
  list(x = rescale_line(get_xbreaks(from), get_xbreaks(to)),
       y = rescale_line(get_ybreaks(from), get_ybreaks(to)))
}


rescale_line <- function(breaks1, breaks2) {
  if (length(breaks1) != length(breaks2)) {
    stop("Supplied breaks must be the same length! Are all dimensions supplied?")
  }

  function(xs) {
    rescaled_xs <- c()
    for (x in xs) {
      for (i in 1:(length(breaks1) - 1)) {
        lower1 <- breaks1[i]
        upper1 <- breaks1[i+1]
        lower2 <- breaks2[i]
        upper2 <- breaks2[i+1]
        rescaler <- rescale_line_segment(lower1, upper1, lower2, upper2)

        if ((x > lower1) & (x <= upper1)) {
          # If x = -Inf, this will never be TRUE, and so the rescaler will return
          # NULL. For now, we assume that this edge case can be safely ignored &
          # so it is not handled. Could cause some pernicious errors later on.
          rescaled_xs <- c(rescaled_xs, rescaler(x))
        }
      }
    }

    rescaled_xs
  }
}

rescale_line_segment <- function(lower1, upper1, lower2, upper2) {
  # For any coordinates outside the pitch area, the transformation is undefined
  # In these cases (i.e. where one of the bounds is +/- Inf), we just leave the
  # value unchanged
  if (any(is.infinite(c(lower1, upper1, lower2, upper2)))) {
    return(identity)
  }

  size1 <- upper1 - lower1
  size2 <- upper2 - lower2

  offset <- lower2 - lower1

  function(x) {
    lower2 + (x - lower1) * (size2 / size1)
  }
}

get_xbreaks <- function(dimensions) {
  midpoint <- pitch_center(dimensions)

  c(-Inf,
    dimensions$origin_x,
    dimensions$origin_x + dimensions$six_yard_box_length,
    dimensions$origin_x + dimensions$penalty_spot_distance,
    dimensions$origin_x + dimensions$penalty_box_length,
    dimensions$origin_x + midpoint$x,
    dimensions$origin_x + dimensions$length - dimensions$penalty_box_length,
    dimensions$origin_x + dimensions$length - dimensions$penalty_spot_distance,
    dimensions$origin_x + dimensions$length - dimensions$six_yard_box_length,
    dimensions$origin_x + dimensions$length,
    +Inf)
}

get_ybreaks <- function(dimensions) {
  midpoint <- pitch_center(dimensions)

  c(-Inf,
    dimensions$origin_y,
    midpoint$y - dimensions$penalty_box_width/2,
    midpoint$y - dimensions$six_yard_box_width/2,
    midpoint$y - dimensions$goal_width/2,
    midpoint$y + dimensions$goal_width/2,
    midpoint$y + dimensions$six_yard_box_width/2,
    midpoint$y + dimensions$penalty_box_width/2,
    dimensions$origin_y + dimensions$width,
    +Inf)
}

#' @rdname rescale_coordinates
#' @export
rescale_international <- function(from) rescale_coordinates(from, to = pitch_international)
