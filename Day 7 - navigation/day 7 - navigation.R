source(here::here("./prep/prep.R"))

#ship data
df <- read_csv("./Day 7 - navigation/shipdata.csv") |>
  select(1:7)

df <- df[1:400000,]


#land data

#lake boundary data
names <- c("Lake Michigan", "Lake Ontario", "Lake Huron"
           , "Lake Superior", "Lake Erie")


#data from naturalearth
lakes <- st_read("./Day 7 - navigation/ne_10m_lakes.shp") |>
  filter(name %in% names)

#river boundary data
rivers <- st_read("./Day 7 - navigation/ne_10m_rivers_lake_centerlines.shp") 


df1 <- df |>
  st_as_sf(coords = c("LON", "LAT")
           , crs = 4326)

#set the CRS's to the same
lakes <- st_transform(lakes, crs = st_crs(df1))
land <- st_transform(land, crs = st_crs(df1))

land <- st_crop(land, st_bbox(lakes))
df1 <- st_crop(df1, st_bbox(lakes))

#
df1$BaseDateTime <- ymd_hms(df1$BaseDateTime)


#plot it
plot <- ggplot() +
  geom_sf(data = land, fill = "grey"
          , color = "white") +
  
  ggfx::with_outer_glow(geom_sf(data = lakes, fill = "darkblue"
          , color = "darkblue")) +
  ggfx::with_outer_glow(geom_sf(data = st_jitter(df1_filt, .05) 
          , color = "#FF007F"
          , size = .1
          , alpha = .3)) +
  theme_void() +
  theme(legend.position = "none") 

plot

df3 <- df1 |>
  mutate(date = as_date(BaseDateTime))
        

#
ggplot() +
  geom_sf(data = land, fill = "grey"
          , color = "white") +
  
  ggfx::with_outer_glow(geom_sf(data = lakes, fill = "darkblue"
                                , color = "darkblue")) +
  ggfx::with_outer_glow(geom_sf(data = st_jitter(df3, .05) 
                                , color = "yellow"
                                , size = .1
                                , alpha = .3)) +
  theme_void() +
  theme(legend.position = "none") +
  gganimate::transition_time(df3$date) #animate it

get_map <- function(y) {
  df3 |> filter(date == y) %>% 
    ggplot() + 
    geom_sf(data = land, fill = "grey"
            , color = "white") +
    ggfx::with_outer_glow(geom_sf(data = lakes, fill = "darkblue"
                                  , color = "darkblue")) +
    ggfx::with_outer_glow(geom_sf(data = st_jitter(df3, .05) 
                                  , color = "yellow"
                                  , size = .1
                                  , alpha = .3)) +
    theme_void() +
    theme(legend.position = "none") + 
    labs(title = y) 
}

y_list <- df3$date |> 
  sort |> 
  unique
my_maps <- paste0("~./Day 7 - navigation/", seq_along(y_list), ".png")
for (i in seq_along(y_list)){
  get_map(y = y_list[i])
  ggsave(my_maps[i], width = 6, height = 4)
}

magick::image_animate(my_maps, fps = 1)

