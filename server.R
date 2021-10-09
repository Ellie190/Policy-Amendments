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
    locations_nr <- select(locations(), c("city", "availability_of_water", "agricultural_potential",
                                   "mining_potential", "tourism_potential", "environmental_sensitivity",
                                   "latitude", "longitude"))
    locations_nr
  })
  
  output$dist1 <- renderUI({
    selectInput("tab1_dist", label = "Distribution Indicator",
                   choices = c("availability_of_water", 
                               "agricultural_potential",
                               "mining_potential", 
                               "tourism_potential", 
                               "environmental_sensitivity"),
                   selected = "availability_of_water")
  })
  
  output$distplt1 <- renderPlotly({
    req(input$tab1_dist)
    locations_nr() %>%
      plot_ly(
        y = as.formula(paste0('~', input$tab1_dist)),
        type = 'violin',
        box = list(visible = T),meanline = list(visible = T), x0 = paste0(input$tab1_dist)) %>%
      layout(
        yaxis = list(title = "%", zeroline = F))
  })
  
  locations_nr_scale <- reactive({
    nr_scale <- scale(select(locations_nr(),
                             c("availability_of_water", "agricultural_potential",
                               "mining_potential", "tourism_potential", 
                               "environmental_sensitivity")))
    nr_scale 
  })
  
  locations_nr_cluster <- reactive({
    req(input$clustnum1)
    locations_nr_cluster <- kmeans(locations_nr_scale(), 
                                   centers = input$clustnum1, nstart = 25)
    locations_nr_cluster
  })
  
  output$clustplt1 <- renderPlotly({
    ggplotly(fviz_cluster(locations_nr_cluster(), data = locations_nr_scale()) +
               theme_minimal() +
               theme(legend.position = "none") +
               ggtitle(""))
  })
  
  nr_clust_df <- reactive({
    locations_nr_update <- locations_nr()
    locations_nr_update$cluster <- as.factor(locations_nr_cluster()$cluster)
    locations_nr_update
  })
  
  nr_clust_table <- reactive({
    nr_clust <- select(nr_clust_df(), c("availability_of_water", "agricultural_potential",
                                         "mining_potential", "tourism_potential", 
                                         "environmental_sensitivity"))
    nr_clust_table <- aggregate(nr_clust,
                                by=list(cluster= locations_nr_cluster()$cluster),
                                mean)
    nr_clust_table[,-1] <-round(nr_clust_table[,-1],1)
    nr_clust_table
  })
  
  output$clustTbl1 <- renderDataTable(
    DT::datatable(nr_clust_table(),
                  rownames = T,
                  options = list(pageLength = 5, scrollX = TRUE, info = FALSE))
    
  )
  
  output$clustbar1 <- renderPlotly({
    ggplotly(nr_clust_df() %>%
               group_by(cluster) %>%
               summarise(No_of_Cities = n()) %>%
               arrange(No_of_Cities) %>%
               mutate(Cluster = factor(cluster, levels = unique(cluster))) %>%
               ggplot(aes(x = Cluster, y = No_of_Cities)) +
               geom_bar(stat = "identity",
                        fill = "#1f77b4") +
               geom_text(aes(label = No_of_Cities),
                         vjust = -0.25) +
               coord_flip() +
               labs(x = "Group", 
                    y = "Number of Cities/Towns") +
               theme_minimal())
  })
  
  output$clust_nr <- renderLeaflet({
    col_nr <- colorFactor("Set1", nr_clust_df()$cluster)
    
    leaflet(data = nr_clust_df()) %>% 
      addTiles(group = "OSM") %>% 
      addProviderTiles(providers$OpenTopoMap, group = "OpenTopoMap") %>% 
      addProviderTiles(providers$Esri.WorldImagery, group = "Esri.WorldImagery") %>% 
      addProviderTiles(providers$CartoDB.DarkMatter, group = "CartoDB.DarkMatter") %>% 
      addCircleMarkers(~longitude, ~latitude, color = ~col_nr(cluster),
                       stroke = FALSE,
                       fillOpacity = 1, radius = 10,
                       popup = popupTable(nr_clust_df(),
                                          zcol = c("city",
                                                   "availability_of_water",
                                                   "agricultural_potential",
                                                   "mining_potential",
                                                   "tourism_potential",
                                                   "environmental_sensitivity",
                                                   "cluster")), 
                       group = "Natural Resource") %>% 
      addLayersControl(baseGroups = c("OSM", "OpenTopoMap", "Esri.WorldImagery",
                                      "CartoDB.DarkMatter"),
                       overlayGroups = c("Natural Resource"),
                       position = "topright") %>% 
      addLegend("bottomleft", pal = col_nr, values = ~cluster,
                title = "NR Group", opacity = 1) 
  })
  
  # Human Development Index
  
  locations_hdi <- reactive({
    locations_hdi <- select(locations(), c("city", "education", "income",
                                          "occupation", "health_status", "housing",
                                          "latitude", "longitude"))
    locations_hdi
  })
  
  output$dist2 <- renderUI({
    selectInput("tab2_dist", label = "Distribution Indicator",
                choices = c("education", 
                            "income",
                            "occupation", 
                            "health_status", 
                            "housing"),
                selected = "education")
  })
  
  output$distplt2 <- renderPlotly({
    req(input$tab2_dist)
    locations_hdi() %>%
      plot_ly(
        y = as.formula(paste0('~', input$tab2_dist)),
        type = 'violin',
        box = list(visible = T),meanline = list(visible = T), x0 = paste0(input$tab2_dist)) %>%
      layout(
        yaxis = list(title = "%", zeroline = F))
  })
  
  locations_hdi_scale <- reactive({
    hdi_scale <- scale(select(locations_hdi(),
                             c("education", "income",
                               "occupation", "health_status", 
                               "housing")))
    hdi_scale 
  })
  
  locations_hdi_cluster <- reactive({
    req(input$clustnum2)
    locations_hdi_cluster <- kmeans(locations_hdi_scale(), 
                                   centers = input$clustnum2, nstart = 25)
    locations_hdi_cluster
  })
  
  output$clustplt2 <- renderPlotly({
    ggplotly(fviz_cluster(locations_hdi_cluster(), data = locations_hdi_scale()) +
               theme_minimal() +
               theme(legend.position = "none") +
               ggtitle(""))
  })
  
  hdi_clust_df <- reactive({
    locations_hdi_update <- locations_hdi()
    locations_hdi_update$cluster <- as.factor(locations_hdi_cluster()$cluster)
    locations_hdi_update
  })
  
  hdi_clust_table <- reactive({
    hdi_clust <- select(hdi_clust_df(), c("education", "income",
                                        "occupation", "health_status", 
                                        "housing"))
    hdi_clust_table <- aggregate(hdi_clust,
                                by=list(cluster= locations_hdi_cluster()$cluster),
                                mean)
    hdi_clust_table[,-1] <- round(hdi_clust_table[,-1],1)
    hdi_clust_table
  })
  
  output$clustTbl2 <- renderDataTable(
    DT::datatable(hdi_clust_table(),
                  rownames = T,
                  options = list(pageLength = 5, scrollX = TRUE, info = FALSE))
    
  )
  
  output$clustbar2 <- renderPlotly({
    ggplotly(hdi_clust_df() %>%
               group_by(cluster) %>%
               summarise(No_of_Cities = n()) %>%
               arrange(No_of_Cities) %>%
               mutate(Cluster = factor(cluster, levels = unique(cluster))) %>%
               ggplot(aes(x = Cluster, y = No_of_Cities)) +
               geom_bar(stat = "identity",
                        fill = "#1f77b4") +
               geom_text(aes(label = No_of_Cities),
                         vjust = -0.25) +
               coord_flip() +
               labs(x = "Group", 
                    y = "Number of Cities/Towns") +
               theme_minimal())
  })
  
  output$clust_hdi <- renderLeaflet({
    col_hdi <- colorFactor("Set1", hdi_clust_df()$cluster)
    
    leaflet(data = hdi_clust_df()) %>% 
      addTiles(group = "OSM") %>% 
      addProviderTiles(providers$OpenTopoMap, group = "OpenTopoMap") %>% 
      addProviderTiles(providers$Esri.WorldImagery, group = "Esri.WorldImagery") %>% 
      addProviderTiles(providers$CartoDB.DarkMatter, group = "CartoDB.DarkMatter") %>% 
      addCircleMarkers(~longitude, ~latitude, color = ~col_hdi(cluster),
                       stroke = FALSE,
                       fillOpacity = 1, radius = 10,
                       popup = popupTable(hdi_clust_df(),
                                          zcol = c("city",
                                                   "education",
                                                   "income",
                                                   "occupation",
                                                   "health_status",
                                                   "housing",
                                                   "cluster")), 
                       group = "Human Development Index") %>% 
      addLayersControl(baseGroups = c("OSM", "OpenTopoMap", "Esri.WorldImagery",
                                      "CartoDB.DarkMatter"),
                       overlayGroups = c("Human Development Index"),
                       position = "topright") %>% 
      addLegend("bottomleft", pal = col_hdi, values = ~cluster,
                title = "HDI Group", opacity = 1) 
  })
  
}