# ggsoccer
Plot soccer event data in R/ggplot2

## Installation
```
devtools::install_github("torvaney/ggsoccer")
```

## Usage
```
ggplot(shots_data, aes(x = x, y = y)) + 
  pitch_layer() +
  geom_point() + 
  theme_pitch()
```
