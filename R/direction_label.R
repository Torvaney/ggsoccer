#' Adds an arrow indicating the direction of play to a ggplot plot
#'
#' @param x_label x position of the centre of the arrow on the plot
#' @param y_label y position of the arrow on the plot
#' @param label_length length of arrow
#' @param arrow_colour colour of the arrow and text
#' @return list of ggplot layers to be added to a ggplot plot
#' @export
#' @examples
#' ggplot(shots_data, aes(x = x, y = y)) + pitch_layer() + geom_point() + theme_pitch()
direction_label <- function(x_label = 50, y_label = -3, 
                            label_length = 20, arrow_colour = "gray75") {
  require(ggplot2)
  require(grid)
  # Adds 'Direction of play' indicator to pitch plot
  # Args:
  #   y_label: Where on the pitch the arrow and label should show. Defaults to -3.
  #
  # Returns:
  #   ggplot layer
  
  layer <- list(
    geom_segment(
      x = x_label - (label_length / 2),
      y = y_label,
      xend = x_label + (label_length / 2),
      yend = y_label,
      arrow = arrow(length = unit(0.02, "npc")),
      colour = arrow_colour),
    annotate(
      "text", 
      x = x_label,
      y = y_label - 1, 
      label = c("Direction of play"), 
      vjust = 1.5, 
      size = 3,
      colour = arrow_colour
      )
    )
  
  return(layer)
}