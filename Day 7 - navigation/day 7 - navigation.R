source(here::here("./prep/prep.R"))

#ship data
df <- read_csv("./Day 7 - navigation/shipdata.csv") |>
  select(1:7)

df <- df[1:200000,]


#land data

lands <- c("United States of America", "Canada")
type = c("Country", "Sovereign country")

land <- st_read("./Day 7 - navigation/ne_10m_admin_0_countries.shp") |>
  filter(SOVEREIGNT %in% lands) |>
  filter(TYPE %in% type)

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
st_crs(lakes) <- st_crs(df1)
st_crs(land) <- st_crs(df1)


land <- st_crop(land, st_bbox(lakes))
df1 <- st_crop(df1, st_bbox(lakes))

df2 <- st_join(df1, lakes)
#plot it
ggplot() +
  geom_sf(data = land, fill = "black"
          , color = "white") +
  #geom_sf(data = rivers_crop, fill = "darkblue")+
  with_outer_glow(geom_sf(data = lakes, fill = "darkblue"
          , color = "darkblue")) +
  with_outer_glow(geom_sf(data = st_jitter(df2, .05) 
          , color = "yellow"
          , size = .1
          , alpha = .3)) +
  theme_void() +
  theme(legend.position = "none")
