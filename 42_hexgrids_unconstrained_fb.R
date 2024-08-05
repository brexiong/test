# clear environment
rm(list = ls())

# calculate start time of code (determine how long it takes to complete all code)
start <- Sys.time()

#####################################
#####################################

# Load packages
if (!require("pacman")) install.packages("pacman")
pacman::p_load(docxtractr,
               dplyr,
               elsa,
               fasterize,
               fs,
               ggplot2,
               janitor,
               ncf,
               paletteer,
               pdftools,
               plyr,
               purrr,
               raster,
               RColorBrewer,
               reshape2,
               # rgdal,
               rgeoda,
               # rgeos,
               rmapshaper,
               rnaturalearth, # use devtools::install_github("ropenscilabs/rnaturalearth") if packages does not install properly
               RSelenium,
               sf,
               shadowr,
               sp,
               stringr,
               terra, # is replacing the raster package
               tidyr,
               tidyverse)

##################################### *USER INPUT NEEDED*
##################################### 
# Set directories
## Input directories

### Study area directory
#### The hex grids are stored within individual study area directories. Instead of accessing and referencing 
#### multiple directories separately, we can simultaneously access the hex grids from the main study area directory
study_area_dir <- "C:/Users/Breanna.Xiong/Documents/R Scripts/ak_aoa/study_area"

### Raw data directory
#### This directory contains the data you wish to have processed.
raw_cultural_geopackage <- "C:/Users/Breanna.Xiong/Documents/R Scripts/ak_aoa/data/a_raw_data/cultural_resources/cultural_resources.gpkg"


### 
code_dict <- list(
  study_area = c("cordova", "craig", "juneau", "ketchikan", "kodiak", "metlakatla", "petersburg", "seward", "sitka", "valdez", "wrangell"),
  code = c("co", "cr", "ju", "ke", "ko", "me", "pe", "se", "si", "va", "wr")
)

# function to clean data
clean_data <- function(data){
  data_layer <- data %>%
    # reproject the same coordinate reference system (crs) as the study area
    sf::st_transform("ESRI:102008") %>% # EPSG WKID 102008 (https://epsg.io/102008)
    # filter for only NA values in the field 'constraints', as those are the unconstrained values
    dplyr::filter(is.na(constraints)) %>%
  return(data_layer)
}

###

for(i in 1:length(code_dict$study_area)){
  
  # floating bag
  file = file.path(study_area_dir, code_dict$study_area[i], "2_floating_bag/d_suitability_data/constraints/1_constraints.gpkg")
  
  # layer 
  data_layer = paste(code_dict$code[i], "cs_fb_suitability", sep = "_")
  
  # Read the layer from the input GeoPackage
  data <- sf::st_read(dsn = file, layer = data_layer) %>% clean_data

  # New layer name for output
  new_layer_name = paste(data_layer, "unconstrained", sep = "_")

  # Write the layer to the output GeoPackage
  sf::st_write(obj = data, dsn = file, layer = new_layer_name, append = FALSE)
}

