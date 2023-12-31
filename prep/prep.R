#A prep script that automatically loads all the libraries I 
#expect to need for the 30 day map challenge

#load libraries
packages <- c("crsuggest", "elevatr", "extrafont", "extrafontdb", "fastDummies","ggfx", "ggtext", "glue"
              , "here", "janitor", "leaflet", "leaflet.extras", "lubridate", "magick"
              , "maptiles", "mapview","nationalparkcolors", "osmdata", "paletteer", "patchwork", "rayimage", "rayrender", "rayshader"
              , "rcartocolor", "readxl", "rnaturalearth", "rnaturalearthdata", "sf", "showtext", "tanaka", "terra"
              , "tidycensus",  "tidyverse", "tmap"
              , "tmaptools", "viridis", "viridisLite")

# Install packages not yet installed
installed_packages <- packages %in% rownames(installed.packages())
if (any(installed_packages == FALSE)) {
  install.packages(packages[!installed_packages])
}
# Packages loading
lapply(packages, library, character.only = TRUE) |>
  invisible()

#gganimate
# install.packages('devtools')
#devtools::install_github('thomasp85/gganimate')

#Add some Google Fonts
#font_add(family = "Roboto", regular = "C:\\Windows\\Fonts\\Roboto-Regular.tff")

font_add(family = "Playpen Sans"
         , regular = "C:\\Windows\\Fonts\\PlaypenSans-Regular.ttf")
