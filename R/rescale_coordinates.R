#' Rescale x-y coordinates
#'
#' @description Returns a list containing functions to rescale coordinates from
#' one set of pitch dimensions (i.e. data provider) to another.
#'
#' @param from The dimensions to convert from (see `help(dimensions)`)
#' @param to The dimensions to convert to (see `help(dimensions)`)
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
#' #> c(...)
#'
#' opta_to_wyscout$y(opta_ys)
#' #> c(...)
#'
#' @export
rescale_coordinates <- function(from, to) {
  # TODO: Work out the breaks
  xbreaks <- 1
  ybreaks <- 1

  list(x = rescale_line(xbreaks),
       y = rescale_line(ybreaks))
}


rescale_line <- function(breaks1, breaks2) {
  if (length(breaks1) != length(breaks2)) {
    stop("Supplied breaks must be the same length! Are all dimensions supplied?")
  }

  function(xs) {
    # 1. Split xs by breaks1 (i.e. [Double] -> [[Double]])
    segments <- cut(xs, c(-Inf, breaks1, +Inf), labels = FALSE)

    # 2. Apply the appropriate `rescale_line_segment` fn to each sublist
    #    Something like: map2([[dbl]], [fn], function(xs, f) f(xs))
    #    Preserve ordering by keeping NAs?

    # 3. Combine [[Double]] -> [Double]

    xs
  }
}

rescale_line_segment <- function(lower1, upper1, lower2, upper2) {
  size1 <- upper1 - lower1
  size2 <- upper2 - lower2

  offset <- lower2 - lower1

  function(x) {
    (size2 * x / size1) + offset
  }
}
