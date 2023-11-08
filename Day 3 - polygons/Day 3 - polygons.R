
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

rests <- restaurants$osm_points

rests_wards <- st_join(wards, rests)

#make the voronoi polygons
# https://stackoverflow.com/questions/76856625/perimeter-of-voronoi-cells
voronoi_sf <- rests_wards |> 
  st_union() |> 
  st_voronoi() |> 
  st_collection_extract("POLYGON") |>
  st_sf(geometry = _)

#check bbox
st_bbox(voronoi_sf)

rows <- data.frame(row = 1:nrow(voronoi_sf))
voronoi <- voronoi_sf |>
  bind_cols(rows)

showtext.auto()

ggplot() +
  geom_sf(data = voronoi
          , aes(fill = row
                , color = -row))+
          #, color = "")+
          #, alpha = .2) +
  #coord_sf(xlim = c(bb[[1]], bb[[3]]
   #                 , ylim = c(bb[[2]], bb[[4]])))+
  labs(title = "Conceptual Chicago"
       , subtitle = "Voronoi tesselation of restaurant locations"
       , caption = "@bcalhoon7 | data: Chicago Open Data, OpenStreetMap | made with rstats  \nDay 1: 30 Day Map Challenge 2023  ")+
  theme_void() +
  theme(legend.position = "none"
        , plot.title.position = "plot"
        , title = element_text(family = "Playpen Sans"
                               , size = 32
                               , color = "darkblue")
        , plot.subtitle = element_text(family = "Playpen Sans"
                                       , size = 24
                                       , color = "darkblue"
                                       , lineheight = .5)
        , plot.caption = element_text(size = 12
                                      , color = "black"
                                      , lineheight = .5))

#save the plot
ggsave(plot = last_plot()
       , filename = "restaurants voronoi.png"
       , path = "./Day 3 - polygons"
       , device = "png"
       , width = 4
       , height = 6
       , units = "in"
       , bg = "#B3DDF2")

