#' Adds soccer pitch markings as a layer for use in a ggplot plot.
#'
#' @param fill fill colour of the pitch
#' @param colour outline colour of the pitch
#' @param x_scale scale applied to x coordinates of the pitch markings
#' @param y_scale scale applied to y coordinates of the pitch markings
#' @param x_shift constant value added to x coordinates of the pitch markings
#' @param y_shift constant value added to y coordinates of the pitch markings
#' @param juego boolean indicating whether additional 'juego de posicion' markings should be shown
#' @return list of ggplot geoms to be added to a ggplot plot
#' @export
#' @examples
#' ggplot(shots_data, aes(x = x, y = y)) + pitch_layer() + geom_point() + theme_pitch()
pitch_layer <- function(fill = "green", colour = "white", 
                       x_scale = 1, y_scale = 1,
                       x_shift = 0, y_shift = 0,
                       juego = FALSE) {
  markings <- list(
    # Add pitch outline
    ggplot2::geom_rect(
      xmin = 0*x_scale+x_shift,
      xmax = 100*x_scale+x_shift,
      ymin = 0*y_scale+y_shift, 
      ymax = 100*y_scale+y_shift,
      colour  = colour,
      fill  = fill,
      alpha = 1
      ),
    # Centre circle
    ggplot2::annotation_custom(
      grob=grid::circleGrob(r=grid::unit(1,"npc"),
                            gp = grid::gpar(col=colour, fill = fill, lwd = 2)),
      xmin=(50-7)*x_scale+x_shift,
      xmax=(50+7)*x_scale+x_shift,
      ymin=(50-7)*y_scale+y_shift,
      ymax=(50+7)*y_scale+y_shift
    ),
    # Centre spot
    ggplot2::geom_rect(
      xmin = 49.8*x_scale+x_shift,
      xmax = 50.2*x_scale+x_shift,
      ymin = 49.8*y_scale+y_shift,
      ymax = 50.2*y_scale+y_shift,
      colour  = colour,
      fill  = colour
    ),
    # Halfway line
    ggplot2::annotate(
      "segment",
      x = 50*x_scale+x_shift,
      xend = 50*x_scale+x_shift,
      y = 0*y_scale+y_shift, 
      yend = 100*y_scale+y_shift,
      colour = colour
    ),
    # Add penalty areas (with penalty spot)
    ggplot2::annotation_custom(
      grob=grid::circleGrob(r=grid::unit(1,"npc"),
                      gp = grid::gpar(col=colour, fill = fill, lwd = 2)),
      xmin=(88.5-7)*x_scale+x_shift,
      xmax=(88.5+7)*x_scale+x_shift, 
      ymin=(50-7)*y_scale+y_shift,
      ymax=(50+7)*y_scale+y_shift
    ),
    ggplot2::geom_rect(
      xmin = 83*x_scale+x_shift,
      xmax = 100*x_scale+x_shift,
      ymin = 21.1*y_scale+y_shift,
      ymax = 79.9*y_scale+y_shift,
      colour  = colour,
      fill = fill,
      alpha = 1
    ),
    ggplot2::geom_rect(  # Penalty spot
      xmin = 88.4*x_scale+x_shift,
      xmax = 88.6*x_scale+x_shift,
      ymin = 49.8*y_scale+y_shift,
      ymax = 50.2*y_scale+y_shift,
      colour  = colour,
      fill  = colour
    ),
    ggplot2::annotation_custom(
      grob=grid::circleGrob(r=grid::unit(1,"npc"),
                      gp = grid::gpar(col=colour, fill = fill, lwd = 2)),
      xmin=(11.5-7)*x_scale+x_shift, 
      xmax=(11.5+7)*x_scale+x_shift, 
      ymin=(50-7)*y_scale+y_shift, 
      ymax=(50+7)*y_scale+y_shift
    ),
    ggplot2::geom_rect(
      xmin = 0*x_scale+x_shift,
      xmax = 17*x_scale+x_shift,
      ymin = 21.1*y_scale+y_shift,
      ymax = 79.9*y_scale+y_shift,
      colour  = colour,
      fill = fill,
      alpha = 1
    ),
    ggplot2::geom_rect(  # Penalty spot
      xmin = 11.4*x_scale+x_shift,
      xmax = 11.6*x_scale+x_shift,
      ymin = 49.8*y_scale+y_shift, 
      ymax = 50.2*y_scale+y_shift,
      colour  = colour,
      fill  = colour
    ),
    # Add 6 yard boxes
    ggplot2::geom_rect(
      xmin = 94.2*x_scale+x_shift,
      xmax = 100*x_scale+x_shift,
      ymin = 36.8*y_scale+y_shift,
      ymax = 63.2*y_scale+y_shift,
      colour  = colour, fill = fill,
      alpha = 1),
    ggplot2::geom_rect(
      xmin = 0*x_scale+x_shift,
      xmax = 5.8*x_scale+x_shift,
      ymin = 36.8*y_scale+y_shift,
      ymax = 63.2*y_scale+y_shift,
      colour  = colour, fill = fill,
      alpha = 1),
    # Add goals
    ggplot2::geom_rect(
      xmin = 100*x_scale+x_shift,
      xmax = 102*x_scale+x_shift,
      ymin = 44.2*y_scale+y_shift,
      ymax = 55.8*y_scale+y_shift,
      colour  = colour,
      fill = fill,
      alpha = 1),
    ggplot2::geom_rect(
      xmin = 0*x_scale+x_shift,
      xmax = -2*x_scale+x_shift,
      ymin = 44.2*y_scale+y_shift,
      ymax = 55.8*y_scale+y_shift,
      colour  = colour,
      fill = fill,
      alpha = 1
    )
  )
  
  return(markings)
}
