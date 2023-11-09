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

df1 <- st_crop(df1, st_bbox(lakes))

#I had visions of animating this, but I keep getting an error
# with the crs when using gganimate
#df1$BaseDateTime <- ymd_hms(df1$BaseDateTime)
#df2 <- df1 |>
#  mutate(date = as_date(BaseDateTime))

font_add_google("Monoton", "Monoton")
showtext.auto()

#plot it
plot <- ggplot() +
  ggfx::with_outer_glow(geom_sf(data = lakes, fill = "darkblue"
          , color = "darkblue")) +
  ggfx::with_outer_glow(geom_sf(data = st_jitter(df1, .05) 
          , color = "#FF007F"
          , size = .1
          , alpha = .3)) +
  labs(title = "Great Lakes Boat Traffic"
       , subtitle = "Chicago restaurants probably get some of their food\nthis way."
       , caption = "@bcalhoon7 | data: NOAA marine cadastre, naturalearth  | made with rstats  \nDay 7: 30 Day Map Challenge 2023  ")+
  theme_void() +
  theme(legend.position = "none"
        , plot.title.position = "plot"
        , title = element_text(family = "Monoton"
                               , size = 32
                               , color = "#FF007F")
        , plot.subtitle = element_text(family = "Monoton"
                                       , size = 24
                                       , color = "#FF007F"
                                       , lineheight = .5)
        , plot.caption = element_text(size = 14
                                      , color = "black"
                                      , lineheight = .5))


ggsave(plot = plot
       , filename = "great lakes shipping.png"
       , path = "./Day 7 - navigation"
       , device = "png"
       , width = 6
       , height = 4
       , units = "in"
       , bg = "grey")
