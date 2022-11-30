test_that("Plotting each of the supplied dimensions doesn't throw an error", {
  dimensions <- list(pitch_opta, pitch_wyscout, pitch_statsbomb, pitch_international)
  for (dim in dimensions) {
    expect_no_error({
      ggplot2::ggplot() +
        annotate_pitch(dimensions = dim)
    })

    # Also check for warnings in case the dimensions don't show the penalty
    # arcs
    expect_no_warning({
      ggplot2::ggplot() +
        annotate_pitch(dimensions = dim)
    })
  }
})


test_that("Pitch can be plotted with aesthetic attributes", {
  # c.f. https://github.com/Torvaney/ggsoccer/issues/23
  aesthetics <- list(
    list(size = 3),
    list(linetype = "dotted"),
    list(linetype = "dashed", size = 2),
    list(alpha = 0.5)
  )

  for (args in aesthetics) {
    expect_no_error({
      ggplot2::ggplot() +
        do.call(annotate_pitch, args)
    })
  }
})


test_that("Plotting pitch dimensions without a visible penalty arc shows a warning", {
  pitch_custom <- list(
    length = 150,
    width = 100,
    penalty_box_length = 28,
    penalty_box_width = 60,
    six_yard_box_length = 8,
    six_yard_box_width = 26,
    penalty_spot_distance = 14,
    goal_width = 12,
    origin_x = 0,
    origin_y = 0
  )

  expect_warning({
    ggplot() +
      annotate_pitch(dimensions = pitch_custom) +
      theme_pitch()
  })
})






