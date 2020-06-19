#' Pitch dimensions
#'
#' @description The coordinate system used to generate pitch markings in
#' can be customised by supplying a pitch specification to the `dimensions`
#' argument of `annotate_pitch`.
#'
#' ggsoccer provides pitch specifications for a few popular data providers by default.
#' However, user-defined specifications can also be used.
#'
#' @details A "pitch specification" is simply a list of dimensions that define a
#' coordinate system. The required dimensions are:
#'
#' \itemize{
#'  \item{"length"}{The length of the pitch from one goal to the other (x axis)}
#'  \item{"width"}{The width of the pitch from touchline to the other (y axis)}
#'  \item{"penalty_box_length"}{The distance from the goalline to the edge of the penalty area}
#'  \item{"penalty_box_width"}{The width of the penalty area}
#'  \item{"six_yard_box_length"}{The distance from the goalline to the edge of the six-yard box}
#'  \item{"six_yard_box_width"}{The width of the six-yard box}
#'  \item{"penalty_spot_distance"}{The distance from the goalline to the penalty spot}
#'  \item{"goal_width"}{The distance from one goal post to the other}
#'  \item{"origin_x"}{The minimum x coordinate of the pitch}
#'  \item{"origin_y"}{The minimum y coordinate of the pitch}
#' }
#'
#' The following pitch dimensions are provided
#' \itemize{
#'  \item{"pitch_opta"}{For Opta f24 data}
#'  \item{"pitch_statsbomb"}{For Statsbomb data}
#'  \item{"pitch_wyscout"}{For Wyscout data}
#'  \item{"pitch_international"}{As per UEFA Category 4 stadium regulations}
#'  \item{"pitch_tracab"}{"For ChyronHego Tracab, using the 105m x 68m default size"}
#' }
#'
#' @examples
#' library(ggplot2)
#' library(ggsoccer)
#'
#' ggplot() +
#'   annotate_pitch(dimensions = pitch_statsbomb) +
#'   theme_pitch()
#'
#' @export
pitch_opta <- list(
  length = 100,
  width = 100,
  penalty_box_length = 17,
  penalty_box_width = 57.8,
  six_yard_box_length = 5.8,
  six_yard_box_width = 26.4,
  penalty_spot_distance = 11.5,
  goal_width = 11.6,
  origin_x = 0,
  origin_y = 0
)

#' @rdname pitch_opta
#' @export
# Source: https://github.com/statsbomb/open-data/blob/master/doc/StatsBomb%20Event%20Data%20Specification%20v1.0.2.pdf
pitch_statsbomb <- list(
  length = 120,
  width = 80,
  penalty_box_length = 18,
  penalty_box_width = 44,
  six_yard_box_length = 6,
  six_yard_box_width = 20,
  penalty_spot_distance = 12,
  goal_width = 8,
  origin_x = 0,
  origin_y = 0
)

#' @rdname pitch_opta
#' @export
# Source: A length email chain with customer support...
pitch_wyscout <- list(
  length = 100,
  width = 100,
  penalty_box_length = 16,
  penalty_box_width = 62,
  six_yard_box_length = 6,
  six_yard_box_width = 26,
  penalty_spot_distance = 10,
  goal_width = 12,
  origin_x = 0,
  origin_y = 0
)

#' @rdname pitch_opta
#' @export
# As per UEFA Category 4 regulations
# Source: https://www.sportscourtdimensions.com/soccer/
pitch_international <- list(
  length = 100,
  width = 68,
  penalty_box_length = 16.5,
  penalty_box_width = 40.32,
  six_yard_box_length = 5.5,
  six_yard_box_width = 18.32,
  penalty_spot_distance = 11,
  goal_width = 7.32,
  origin_x = 0,
  origin_y = 0
)

#' @rdname pitch_tracab
#' @export
# ChyronHego Tracab: only length & width provided in metadata.
# Source: official documentation.
# This solution takes the remaining dimensions from the international pitch.
make_pitch_tracab <- function(length=105, width=68){
  pitch_tracab <- lapply(pitch_international, function(x){100.0*x}) # cm
  pitch_tracab["length"] <- 100.0*length
  pitch_tracab["width"] <- 100.0*width
  pitch_tracab["origin_x"] <- -pitch_tracab[["length"]]/2.0
  pitch_tracab["origin_y"] <- -pitch_tracab[["width"]]/2.0
  return(pitch_tracab)
}

pitch_tracab <- make_pitch_tracab()
