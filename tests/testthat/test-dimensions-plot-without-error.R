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
    list(linewidth = 3),
    list(linetype = "dotted"),
    list(linetype = "dashed", linewidth = 2),
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
    ggplot2::ggplot() +
      annotate_pitch(dimensions = pitch_custom) +
      theme_pitch()
  })
})


test_that("Plotting valid pitch dimensions with a negative origin plots without a warning", {
  # Based on https://github.com/Torvaney/ggsoccer/issues/31
  pitch_custom_negative_origin <- list(
    length = 105,
    width = 68,
    penalty_box_length = 16.5,
    penalty_box_width = 40.3,
    six_yard_box_length = 5.5,
    six_yard_box_width = 18.32,
    penalty_spot_distance = 11,
    goal_width = 7.32,
    origin_x = -52.5,
    origin_y = -34
  )

  expect_no_warning({
    ggplot2::ggplot() +
      annotate_pitch(dimensions = pitch_custom_negative_origin) +
      theme_pitch()
  })
})


test_that("Plotting dimensions without a `penalty_arc_radius` doesn't error", {
  dim <- list(
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

  expect_no_error({
    ggplot2::ggplot() +
      annotate_pitch(dimensions = dim)
  })

  # Also check for warnings
  expect_no_warning({
    ggplot2::ggplot() +
      annotate_pitch(dimensions = dim)
  })
})


test_that("Plotting dimensions with a `penalty_arc_radius` doesn't error", {
  dim <- list(
    length = 100,
    width = 100,
    penalty_box_length = 17,
    penalty_box_width = 57.8,
    six_yard_box_length = 5.8,
    six_yard_box_width = 26.4,
    penalty_spot_distance = 11.5,
    goal_width = 11.6,
    origin_x = 0,
    origin_y = 0,
    penalty_arc_radius = 10
  )

  expect_no_error({
    ggplot2::ggplot() +
      annotate_pitch(dimensions = dim)
  })

  # Also check for warnings
  # arcs
  expect_no_warning({
    ggplot2::ggplot() +
      annotate_pitch(dimensions = dim)
  })
})






