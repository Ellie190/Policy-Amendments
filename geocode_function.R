library(tidygeocoder)
library(dplyr)

city_input <- "london, uk"
geo_loc <- tidygeocoder::geo(city_input, method = 'osm', lat = latitude, long = longitude) 

# Access latitude 
geo_loc$latitude[1]

# Access longitude 
geo_loc$longitude[1]

## Miles 
miles <- 100

## Putting the latitude and longitude and miles 
paste0(paste0(paste0(geo_loc$latitude[1], ","), paste0(geo_loc$longitude[1], ",")),
       paste0(miles, "mi"))

geocode_ES <- function(loc, mil) {
  geo_loc <- tidygeocoder::geo(loc, method = 'osm', lat = latitude, long = longitude)
  paste0(paste0(paste0(geo_loc$latitude[1], ","), paste0(geo_loc$longitude[1], ",")),
         paste0(mil, "mi"))
  
}

geocode_ES("london, uk", 100)

