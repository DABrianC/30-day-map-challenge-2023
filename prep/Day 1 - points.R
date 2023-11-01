
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

rests_tracts <- st_join(tracts, rests)

rests_tracts1 <- rests_tracts |>
  group_by()
                    
showtext.auto()
font_add_google("Schoolbell", "bell")

ggplot(tracts) +
  geom_sf() +
  geom_sf(data = rests, size = .3) +
  labs(title = "Chicago")+
  theme_void() +
  theme(title = element_text(family = "Schoolbell"))
