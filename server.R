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
        leaflet::addLegend("bottomleft", pal = col_nr, values = ~natural_resources,
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
        leaflet::addLegend("bottomleft", pal = col_hdi, values = ~human_development_index,
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
      leaflet::addLegend("bottomleft", pal = col_nr, values = ~cluster,
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
      leaflet::addLegend("bottomleft", pal = col_hdi, values = ~cluster,
                title = "HDI Group", opacity = 1) 
  })
  
  # Twitter Analysis
  
  # create token named "twitter_token"
  token <- create_token(
    app = Sys.getenv("app"),
    consumer_key = Sys.getenv("key"),
    consumer_secret = Sys.getenv("secret"),
    access_token = Sys.getenv("access_token"),
    access_secret = Sys.getenv("access_secret")
  )
  
  rv <- reactiveValues()
  
  observeEvent(input$submit, {
    geocode_ES <- function(loc, mil) {
      geo_loc <- tidygeocoder::geo(loc, method = 'osm', lat = latitude, long = longitude)
      paste0(paste0(paste0(geo_loc$latitude[1], ","), paste0(geo_loc$longitude[1], ",")),
             paste0(mil, "mi"))
      }
    
    rv$geocode <- geocode_ES(input$location,input$n_miles)
    
    rv$data <- search_tweets(
      q = input$query,
      n = input$n_tweets,
      include_rts = FALSE,
      geocode = rv$geocode,
      langs = "en",
      token = token
    )
    
    rv$tweet_sentiment <- rv$data %>% 
      select(text) %>% 
      rowid_to_column() %>% 
      unnest_tokens(word, text) %>% 
      inner_join(get_sentiments("bing"))
    
  }, ignoreNULL = FALSE)
  
  output$tweet_prox <- renderLeaflet({
    
    data_prepared <- tibble(
      location = rv$geocode 
    ) %>% 
      separate(location, into = c("lat", "lon", "distance"), sep = ",", remove = FALSE) %>% 
      mutate(distance = distance %>% str_remove_all("[^0-9.-]")) %>% 
      mutate_at(.vars = vars(-location),as.numeric)
    
    data_prepared %>% 
      leaflet() %>% 
      setView(data_prepared$lon, data_prepared$lat, zoom = 4) %>% 
      addTiles() %>% 
      addMarkers(~lon, ~lat, popup = ~as.character(location), label = ~as.character(location)) %>% 
      addCircles(lng = ~lon, lat = ~lat, weight = 1, radius = ~distance/0.000621371)
  })
  
  output$sent_plt <- renderPlotly({

    #Sentiment by user
    Sentiment_by_row_id_tbl <- rv$tweet_sentiment %>% 
      select(-word) %>% 
      count(rowid, sentiment) %>%
      pivot_wider(names_from = sentiment, values_from = n, values_fill = list(n = 0)) %>% 
      mutate(sentiment = positive - negative) %>% 
      left_join(
        rv$data %>% select(screen_name, text) %>% rowid_to_column()
      )
    
    label_wrap <- label_wrap_gen(width = 60)
    
    data_formatted <- Sentiment_by_row_id_tbl %>% 
      mutate(text_formatted = str_glue("Row ID: {rowid}
                                    Screen Name: {screen_name}
                                   Text: {label_wrap(text)}"))
    
    g <- data_formatted %>% 
      ggplot(aes(rowid,sentiment)) + 
      geom_line(color = "#2c3e50", alpha = 0.5) +
      geom_point(aes(text = text_formatted), color = "#2c3e50") +
      geom_hline(aes(yintercept = mean(sentiment)), color ="blue") +
      geom_hline(aes(yintercept = median(sentiment) + 1.96*IQR(sentiment)), color = "red") +
      geom_hline(aes(yintercept = median(sentiment) - 1.96*IQR(sentiment)), color = "red") +
      theme_tq() +
      labs(title = "", x = "Twitter user", y = "Sentiment")
    
    ggplotly(g, tooltip = "text") %>% 
      layout(
        xaxis = list(rangeslider = list(type = "date")
        )
      )
  })
  
  output$word_plt <- renderPlot({
    sentiment_by_word_tbl <- rv$tweet_sentiment %>% 
      count(word, sentiment, sort = TRUE)
    
    sentiment_by_word_tbl %>% 
      slice(1:100) %>% 
      mutate(sentiment = factor(sentiment,levels = c("positive","negative"))) %>% 
      ggplot(aes(label = word, color =sentiment, size =n)) +
      geom_text_wordcloud_area() +
      facet_wrap(~sentiment, ncol = 2) +
      theme_tq() +
      scale_color_tq() +
      scale_size_area(max_size = 16)
  })
  
  # output$test_tbl <- renderDataTable({
  #   DT::datatable(rv$tweet_sentiment,
  #                 rownames = T,
  #                 options = list(pageLength = 5, scrollX = TRUE, info = FALSE))
  # 
  # })
  # dataTableOutput("test_tbl")
  
}