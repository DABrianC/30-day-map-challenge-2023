
source(here::here("./prep/prep.R"))

chi <- st_read("./Day 1 - points/Boundaries - City.geojson"
             , drivers = "geojson")

#Chicago boundaries
bb <- st_bbox(chi)

#chicago population acs data
chi_pop <- readxl::read_xlsx("./Day 1 - points/chi_pop.xlsx")

#chicago census tracts
tracts_sf <- st_read("./Day 1 - points/Wards and Census Tracts 2.geojson"
                     , drivers = "geojson")

tracts <- tracts_sf |>
  left_join(chi_pop
            , by = join_by("geoid10" == "GEOID"))


wards <- st_read("https://data.cityofchicago.org/api/geospatial/sp34-6z76?method=export&format=GeoJSON"
                 , drivers= "geojson")

#get data for all the restaurants in the chicago bounding box
restaurants <- bb |>
  opq()|>
  add_osm_feature(key = "amenity", value = "restaurant") |>
  osmdata_sf()

#set the crs of the point data
st_crs(restaurants$osm_points) <- st_crs(tracts)


#select only those points that interect with the chicago city boundaries
rests <- st_intersection(restaurants$osm_points, tracts) 

rests <- rests |>
  select(osm_id, name, alcohol, amenity, craft, cuisine, description)

wards_rests <- st_join(wards, rests) 

wards_rests1 <- wards_rests |>
  group_by(ward) |>
  count() |>
  ungroup() |>
  arrange(desc(n)) |>
  mutate(percent = (n/sum(n))*100)
  
  
ggplot(wards) +
  geom_sf() +
  geom_sf(data = wards_rests1, aes(fill = case_when(percent > 4 ~ "blue"
                                                    , TRUE ~ NA))) +
    geom_sf(data = rests, size = .1
            , color = "white") +
  theme_void()

font_add(family = "Playpen Sans"
         , regular = "C:\\Windows\\Fonts\\PlaypenSans.tff")

font_add(family = "Roboto", regular = "C:\\Windows\\Fonts\\Roboto.tff")

font_add(family = "Playpen Sans"
         , regular = "C:\\Windows\\Fonts\\PlaypenSans-Regular.ttf")

font_add_google("Roboto")                    
showtext.auto()

ggplot(wards) +
  geom_sf() +
  geom_sf_text(aes(label = ward))

ggplot(wards_rests1) +
  geom_sf(fill = "black"
          , color = "white") +
  ggfx::with_outer_glow(
    geom_sf(data = st_jitter(rests), size = .2
          , color = "yellow")) +
  labs(title = "Restaurants of Chicago"
       , subtitle = "Half of 4,001 restaurants listed on OpenStreetMap \nare located in only 8 wards."
       , caption = "bcalhoon7 | data: Chicago Open Data, OpenStreetMap | made with rstats")+
  theme_void() +
  theme(plot.background = element_rect(fill = "lightgrey")
        , plot.title.position = "plot"
        #, plot.subtitle.position = "plot"
        , title = element_text(family = "Playpen Sans"
                             , size = 32)
        , plot.subtitle = element_text(family = "Playpen Sans"
                                  , size = 24
                                  , color = "yellow")
        , plot.caption = element_text(size = 12
                                       , color = "black"))

ggsave("Chicago restaurants")
