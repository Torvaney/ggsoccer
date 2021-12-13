test_that("Rescaling x coordinates works", {
  dimensions <- list(pitch_opta, pitch_wyscout, pitch_statsbomb, pitch_international)

  expect_equal_rescaled_x <- function(dim1, dim2) {
    rescaler <- rescale_coordinates(dim1, dim2)

    x_dimensions <- c("length", "penalty_box_length", "penalty_spot_distance",
                      "six_yard_box_length", "origin_x")
    for (dim in x_dimensions) {
      expect_equal(
        rescaler$x(dim1[[dim]]),
        dim2[[dim]]
      )
    }
  }

  for (dim1 in dimensions) {
    for (dim2 in dimensions) {
      expect_equal_rescaled_x(dim1, dim2)
    }
  }
})


test_that("Rescaling y coordinates works", {
  expect_equal_rescaled_y <- function(dim1, dim2) {
    rescaler <- rescale_coordinates(dim1, dim2)

    ybreaks1 <- ggsoccer:::get_ybreaks(dim1)
    ybreaks2 <- ggsoccer:::get_ybreaks(dim2)

    finite_ybreaks1 <- ybreaks1[is.finite(ybreaks1)]
    finite_ybreaks2 <- ybreaks2[is.finite(ybreaks2)]

    expect_equal(rescaler$y(finite_ybreaks1), finite_ybreaks2)
  }

  dimensions <- list(pitch_opta, pitch_wyscout, pitch_statsbomb, pitch_international)
  for (dim1 in dimensions) {
    for (dim2 in dimensions) {
      expect_equal_rescaled_y(dim1, dim2)
    }
  }
})
