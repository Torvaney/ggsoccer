# No need to pull in rlang just for this...
`%||%` <- function (x, y) {
  if (is.null(x)) y else x
}
