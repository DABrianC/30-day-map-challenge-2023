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

#cast the points to lines
points <- rests$geometry

lines <- st_cast(st_geometry(rests), "LINESTRING")

# Number of total linestrings to be created
n <- length(points) - 1

# Build linestrings
linestrings <- lapply(X = 1:n, FUN = function(x) {
  
  pair <- st_combine(c(points[x], points[x + 1]))
  line <- st_cast(pair, "LINESTRING")
  return(line)
  
})

# One MULTILINESTRING object with all the LINESTRINGS
all_lines <- st_sfc(st_multilinestring(do.call("rbind", linestrings)))

#set the CRS of all_lines to match that of the wards object
st_crs(all_lines) <- st_crs(wards)

rests_wards <- st_join(rests, wards)

ggplot(wards) +
  geom_sf() +
    geom_sf(data = all_lines
          , color = "grey"
          , linewidth = .5) +
  geom_sf(data = rests_wards
          , aes(color = ward)
          , alpha = .3
          , size = .5) +
  scale_color_manual(values = paletteer_c("grDevices::Plasma", 50))
