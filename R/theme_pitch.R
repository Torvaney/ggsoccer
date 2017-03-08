#' Removes background and axes details from a ggplot plot.
#'
#' @param force_aspect whether to force the plot to obey a given aspect ratio
#' @param aspect_ratio ratio of y / x
#' @return list of ggplot themes to be added to a ggplot plot
#' @export
#' @examples
#' ggplot(shots_data, aes(x = x, y = y)) + pitch_layer() + geom_point() + theme_pitch()
theme_pitch <- function(force_aspect = TRUE, aspect_ratio = 68/105) {
  
  theme_basic <- 
    ggplot2::theme(
      panel.grid.major = ggplot2::element_blank(),
         panel.grid.minor = ggplot2::element_blank(),
         axis.title = ggplot2::element_blank(),
         axis.ticks = ggplot2::element_blank(), 
         axis.text = ggplot2::element_blank(),
         axis.line = ggplot2::element_blank(),
         panel.background = ggplot2::element_blank(), 
         panel.border = ggplot2::element_blank()
    )
  
  if (force_aspect) {
    theme_layer <- list(
      theme_basic, 
      ggplot2::theme(aspect.ratio = aspect_ratio)
    )
  } else {
    theme_layer <- list(theme_basic)
  }

  return(theme_layer)
}
