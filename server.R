server <- function(input, output, session) {
  set.seed(122)
  
  data <- reactive({
    data <- read_excel("geo_NCdata.xlsx")
    data <- clean_names(data)
    data
  })

  # NR & HDI Amount Tab 
  
  output$attr_sel1 <- renderUI({
    selectInput('sel_attribute1',
                label = "Select Mapping Indicator",
                choices = c("Natural Resources" = TRUE,
                            "Human Development Index" = FALSE),
                selected = TRUE)
  })
  
  output$tab1_tbl <- renderDataTable({
    City <- data()[rowSums(is.na(data())) > 0,]$city
    City <- substr(City,1,regexpr(",",City)-1)
    osm_na_df <- as.data.frame(City)
    DT::datatable(osm_na_df,
                  rownames = T,
                  options = list(pageLength = 1, scrollX = TRUE, info = FALSE))
  })
  
  locations <- reactive({
    locations <- subset(data(), !is.na(data()$longitude) & !is.na(data()$latitude))
    locations
  })
  
  output$tab1_map <- renderLeaflet({
    req(input$sel_attribute1)
    if(input$sel_attribute1){
      col_nr <- colorNumeric("RdYlBu", locations()$natural_resources)
      
      leaflet(data = locations()) %>% 
        addTiles(group = "OSM") %>% 
        addProviderTiles(providers$OpenTopoMap, group = "OpenTopoMap") %>% 
        addProviderTiles(providers$Esri.WorldImagery, group = "Esri.WorldImagery") %>% 
        addProviderTiles(providers$CartoDB.DarkMatter, group = "CartoDB.DarkMatter") %>% 
        addCircleMarkers(~longitude, ~latitude, color = ~col_nr(natural_resources),
                         stroke = FALSE,
                         fillOpacity = 1, radius = 10,
                         popup = popupTable(locations(),
                                            zcol = c("city", "natural_resources")), 
                         group = "NR & HDI Amount") %>% 
        addLayersControl(baseGroups = c("OSM", "OpenTopoMap", "Esri.WorldImagery",
                                        "CartoDB.DarkMatter"),
                         overlayGroups = c("NR & HDI Amount"),
                         position = "topright") %>% 
        addLegend("bottomleft", pal = col_nr, values = ~natural_resources,
                  title = "Natural Resource %", opacity = 1) 
    } else {
      col_hdi <- colorNumeric("RdYlBu", locations()$human_development_index)
      
      leaflet(data = locations()) %>% 
        addTiles(group = "OSM") %>% 
        addProviderTiles(providers$OpenTopoMap, group = "OpenTopoMap") %>% 
        addProviderTiles(providers$Esri.WorldImagery, group = "Esri.WorldImagery") %>% 
        addProviderTiles(providers$CartoDB.DarkMatter, group = "CartoDB.DarkMatter") %>% 
        addCircleMarkers(~longitude, ~latitude, color = ~col_hdi(human_development_index),
                         stroke = FALSE,
                         fillOpacity = 1, radius = 10,
                         popup = popupTable(locations(),
                                            zcol = c("city", "human_development_index")), 
                         group = "NR & HDI Amount") %>% 
        addLayersControl(baseGroups = c("OSM", "OpenTopoMap", "Esri.WorldImagery",
                                        "CartoDB.DarkMatter"),
                         overlayGroups = c("NR & HDI Amount"),
                         position = "topright") %>% 
        addLegend("bottomleft", pal = col_hdi, values = ~human_development_index,
                  title = "Human Development Index %", opacity = 1) 
    } })
  
  
  # Natural Resources 
  
  locations_nr <- reactive({
    locations_nr <- select(data(), c("city", "availability_of_water", "agricultural_potential",
                                   "mining_potential", "tourism_potential", "environmental_sensitivity",
                                   "latitude", "longitude"))
    locations_nr
  })
  
  output$dist1 <- renderUI({
    varSelectInput("tab1_dist", label = "Distribution Indicator",
                   locations_nr()[, c(2:6)],
                   selected = "availability_of_water")
  })
}