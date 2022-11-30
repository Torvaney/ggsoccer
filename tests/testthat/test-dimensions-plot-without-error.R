test_that("Plotting each of the supplied dimensions doesn't throw an error", {
  dimensions <- list(pitch_opta, pitch_wyscout, pitch_statsbomb, pitch_international)
  for (dim in dimensions) {
    expect_no_error({
      ggplot2::ggplot() +
        annotate_pitch(dimensions = dim)
    })
  }
})
