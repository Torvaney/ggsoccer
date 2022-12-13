#' Adds an arrow indicating the direction of play to a ggplot plot
#'
#' @param x_label x position of the centre of the arrow on the plot
#' @param y_label y position of the arrow on the plot
#' @param label_length length of arrow (in x axis units)
#' @param colour colour of the arrow and text
#' @param linewidth thickness of the arrow
#' @param linetype linetype of the arrow
#' @param text_size size of label text (passed onto `geom_text`)
#'
#' @return list of ggplot layers to be added to a ggplot plot
#'
#' @examples
#' library(ggplot2)
#'
#' shots_data <- data.frame(x = c(90, 85, 82, 78, 83),
#'                          y = c(43, 40, 52, 56, 44))
#'
#' p <- ggplot(shots_data, aes(x = x, y = y)) +
#'   annotate_pitch() +
#'   geom_point()
#'
#' # Add direction of play label
#' p + direction_label()
#'
#' @importFrom ggplot2 annotate
#' @importFrom grid arrow unit
#'
#' @export
direction_label <- function(x_label = 50,
                            y_label = -3,
                            label_length = 20,
                            colour    = "dimgray",
                            linewidth = 0.5,
                            linetype  = "solid",
                            text_size = 3) {
  layer <- list(
    annotate(
      "segment",
      x = x_label - (label_length / 2),
      y = y_label,
      xend = x_label + (label_length / 2),
      yend = y_label,
      arrow = arrow(length = unit(0.02, "npc"),
                    type = "closed"),
      colour = colour,
      linetype = linetype,
      linewidth = linewidth
    ),
    annotate(
      "text",
      x = x_label,
      y = y_label - 1,
      label = "Direction of play",
      vjust = 1.5,
      size = text_size,
      colour = colour
      )
    )

  return(layer)
}
