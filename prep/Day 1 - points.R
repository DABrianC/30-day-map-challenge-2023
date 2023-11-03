
source(here::here("./prep/prep.R"))

chi <- st_read("./Day 1 - points/Boundaries - City.geojson"
             , drivers = "geojson")

#Chicago boundaries
bb <- st_bbox(chi)

wards <- st_read("https://data.cityofchicago.org/api/geospatial/sp34-6z76?method=export&format=GeoJSON"
                 , drivers= "geojson")

#get data for all the restaurants in the chicago bounding box
restaurants <- bb |>
  opq()|>
  add_osm_feature(key = "amenity", value = "restaurant") |>
  osmdata_sf()

#set the crs of the point data
st_crs(restaurants$osm_points) <- st_crs(wards)


#select only those points that interect with the chicago city boundaries
rests <- st_intersection(restaurants$osm_points, wards) 

rests <- rests |>
  select(osm_id, name, alcohol, amenity, craft, cuisine, description)

wards_rests <- st_join(wards, rests) 

wards_rests1 <- wards_rests |>
  group_by(ward) |>
  count() |>
  ungroup() |>
  arrange(desc(n)) |>
  mutate(percent = (n/sum(n))*100)
  

#activate showtext to use Google Fonts  
showtext.auto()

#make the plot
ggplot(wards_rests1) +
  geom_sf(fill = "#FFFFFF"
          , color = "#B3DDF2") +
  ggfx::with_outer_glow(
    geom_sf(data = st_jitter(rests), size = .2
          , color = "#FF0000")) +
  labs(title = "Restaurants of Chicago"
       , subtitle = "Half of 4,001 restaurants listed on OpenStreetMap\nare located in only 8 wards."
       , caption = "bcalhoon7 | data: Chicago Open Data, OpenStreetMap | made with rstats  \nDay 1: 30 Day Map Challenge 2023  ")+
  theme_void() +
  theme(#plot.background = element_rect(fill = "#B3DDF2")
         plot.title.position = "plot"
        #, plot.subtitle.position = "plot"
        , title = element_text(family = "Playpen Sans"
                             , size = 32
                             , color = "#FF0000")
        , plot.subtitle = element_text(family = "Playpen Sans"
                                  , size = 24
                                  , color = "#FF0000"
                                  , lineheight = .5)
        , plot.caption = element_text(size = 12
                                       , color = "black"))

#save the plot
ggsave(plot = last_plot()
       , filename = "Chicago restaurants.png"
       , path = "./Day 1 - points"
       , device = "png"
       , width = 4
       , height = 6
       , units = "in"
       , bg = "#B3DDF2")
