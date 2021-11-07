library(shiny)
library(bs4Dash)
library(readxl)
library(dplyr)
library(tidygeocoder)
library(janitor)
library(leaflet)
library(plotly)
library(DT)
library(leafpop)
library(factoextra)
library(rtweet)
library(tidytext)
library(ggwordcloud)
library(tidyquant)
library(tidyverse)
library(waiter)
library(shinycssloaders)




dashboardPage(
  preloader = list(html = tagList(spin_1(), "Loading ..."), color = "#18191A"),
  fullscreen = TRUE,
  help = TRUE,
  dashboardHeader(
    title = dashboardBrand(
      title = "Policy Amendments",
      color = "warning",
      href = "https://en.wikipedia.org/wiki/Northern_Cape",
      image = "nc_logo.jpg"
    ),
    skin = "light",
    status = "white"), # end of header
  dashboardSidebar(
    skin = "light",
    status = "warning",
    sidebarUserPanel(
      image = "data_analysis.jpg",
      name = " Analysis"
    ),
    sidebarMenu(
      menuItem("NR & HDI Amount", tabName = "nha", icon = icon("map-marked")),
      menuItem("Natural Resource", tabName = "nr", icon = icon("globe-africa")),
      menuItem("Human Development Index", tabName = "hdi", icon = icon("people-carry")),
      menuItem("Policy Intelligence", tabName = "pi", icon = icon("twitter")),
      menuItem("Dashboard Info", tabName = "di", icon = icon("info"))
    )
  ), # end of sidebar
  dashboardBody(
    tabItems(
      tabItem("nha",
              fluidPage(
                fluidRow(
                  column(9,
                         box(title = "Indicator Mapping", status = "white",
                             width = 12, icon = icon("map-marked-alt"),
                             solidHeader = TRUE, maximizable = TRUE, elevation = 3,
                             withSpinner(leafletOutput("tab1_map"))
                             )),
                  column(3,
                         box(title = "View Card", status = "lightblue",
                             icon = icon("filter"),
                             width = 12, solidHeader = TRUE,
                             uiOutput("attr_sel1"),
                             strong("Cities not recognised by OpenStreetMap"),
                             p(" "),
                             withSpinner(dataTableOutput("tab1_tbl", height = 2))))
                )
              )), # end of nha tab
      tabItem("nr",
              fluidPage(
                fluidRow(
                  column(3,
                         box(title = "View Card", status = "warning",
                             icon = icon("filter"),
                             width = 12, solidHeader = FALSE, elevation = 5,
                             uiOutput("dist1"),
                             numericInput("clustnum1", "Enter Number of Groups",
                                          value = 2,
                                          min = 2, max = 8,
                                          width = "auto"))),
                  column(4,
                         box(title = "Indicator Distribution", status = "lightblue",
                             icon = icon("chart-area"),
                             width = 12, solidHeader = TRUE, maximizable = TRUE,
                             withSpinner(plotlyOutput("distplt1")))),
                  column(5,
                         box(title = "Natural Resource City Groups", status = "lightblue",
                             icon = icon("object-group"),
                             width = 12, solidHeader = TRUE, maximizable = TRUE,
                             withSpinner(plotlyOutput("clustplt1"))))
                ),
                fluidRow(
                  column(6,
                         box(title = "City Group Mapping", status = "lightblue",
                             icon = icon("map-marked-alt"),
                             width = 12, solidHeader = TRUE, maximizable = TRUE,
                             withSpinner(leafletOutput("clust_nr")))),
                  column(6,
                         tabBox(maximizable = TRUE, width = 12,
                                solidHeader = FALSE, status = "lightblue",
                                tabPanel("Group Table", icon = icon("table"),
                                         withSpinner(dataTableOutput("clustTbl1"))),
                                tabPanel("NR Group Count", icon = icon("chart-bar"),
                                         withSpinner(plotlyOutput("clustbar1")))))
                )
              )), # end of nr tab
      tabItem("hdi",
              fluidPage(
                fluidRow(
                  column(3,
                         box(title = "View Card", status = "warning",
                             icon = icon("filter"),
                             width = 12, solidHeader = FALSE, elevation = 5,
                             uiOutput("dist2"),
                             numericInput("clustnum2", "Enter Number of Groups",
                                          value = 2,
                                          min = 2, max = 8,
                                          width = "auto"))),
                  column(4,
                         box(title = "Indicator Distribution", status = "lightblue",
                             icon = icon("chart-area"),
                             width = 12, solidHeader = TRUE, maximizable = TRUE,
                             withSpinner(plotlyOutput("distplt2")))),
                  column(5,
                         box(title = "Human Development City Groups", status = "lightblue",
                             icon = icon("object-group"),
                             width = 12, solidHeader = TRUE, maximizable = TRUE,
                             withSpinner(plotlyOutput("clustplt2"))))
                ),
                fluidRow(
                  column(6,
                         box(title = "City Group Mapping", status = "lightblue",
                             icon = icon("map-marked-alt"),
                             width = 12, solidHeader = TRUE, maximizable = TRUE,
                             withSpinner(leafletOutput("clust_hdi")))),
                  column(6,
                         tabBox(maximizable = TRUE, width = 12,
                                solidHeader = FALSE, status = "lightblue",
                                tabPanel("Group Table", icon = icon("table"),
                                         withSpinner(dataTableOutput("clustTbl2"))),
                                tabPanel("HDI Group Count", icon = icon("chart-bar"),
                                         withSpinner(plotlyOutput("clustbar2")))))
                )
              )
              ), # end of hdi tab
      tabItem("pi",
              fluidPage(
                fluidRow(
                  column(5,
                         box(title = "Query Box", status = "white",
                             icon = icon("search"), elevation = 5,
                             width = 12, solidHeader = TRUE, maximizable = TRUE,
                             textInput(inputId = "query", label = "Topic/ Hashtag", value = "#water",
                                       placeholder = "Type any NR or HDI indicator, e.g, #water
                                       "),
                             sliderInput(
                               inputId = "n_tweets",
                               label = "Number of tweets:",
                               min = 1,
                               max = 2000,
                               value = 50),
                             textInput(inputId = "location", label = "Location", value = "South Africa"),
                             sliderInput(
                               inputId = "n_miles",
                               label = "Twitter Search Radius (miles)",
                               min = 1,
                               max = 2000,
                               value = 500),
                             actionButton(inputId = "submit", "Submit Query", status = "warning"))),
                  column(7,
                         box(title = "Tweet Proximity: Search Radius", status = "white",
                             icon = icon("map-marked-alt"),
                             width = 12, solidHeader = TRUE, maximizable = TRUE,
                             withSpinner(leafletOutput("tweet_prox"))))),
                fluidRow(
                  column(6,
                         box(title = "Sentiment Polarity", status = "white",
                             icon = icon("users"),
                             width = 12, solidHeader = TRUE, maximizable = TRUE,
                             withSpinner(plotlyOutput("sent_plt")))),
                  column(6,
                         box(title = "Feedback: Sentiment Word Cloud", status = "white",
                             icon = icon("comments"),
                             width = 12, solidHeader = TRUE, maximizable = TRUE,
                             withSpinner(plotOutput("word_plt"))))
                )
              )
              ), # end of pi tab
      tabItem("di",
              fluidPage(
                titlePanel("Policy Amendments"),
                h2("Introduction"),
                p("During the past decade, advances in information technology have ignited a revolution
                  in decision-making, from business to sports to policing. Previously, 
                  decisions in these areas had been heavily influenced by factors other than empirical
                  evidence, including personal experience or observation, instinct, hype, and dogma
                  or belief. The ability to collect and analyse large amounts of data, however, 
                  has allowed decision-makers to cut through these potential distortions to discover 
                  what really works."),
                p(strong("Policy - "), "A course or principle of action adopted or proposed by an 
                         organization or individual. Policy is a deliberate system of guidelines 
                         to guide decisions and achieve rational outcomes."),
                p("The purpose of this dashboard is to understand how the percentage of",
                  strong("Natural Resources (NR) and Human Development Index (HDI) "), "varies in",
                  strong("Northern Cape (NC)"), ". This is for the purpose of providing data-driven
                  policy recommendations. Policy recommendations that considers", 
                  strong("geographic mapping "), "of cities or towns and what", 
                  strong("citizens complain about "), "(policy intelligence)"),
                h2("Natural Resources"),
                p(strong("Natural Resources - "), "Natural resources are materials from the Earth
                         that are used to support life and meet people’s needs"),
                p(strong("Natural Resource Policy - "), " A program that prepares individuals to 
                  plan, develop, manage, and evaluate programs to protect and regulate 
                  natural habitats and renewable natural resources"),
                h4("Natural Resource Indicators used in Dashboard"),
                tags$ul( 
                  tags$li(strong("Availability of water: "), "Rainfall, Dams, Perennial rivers, 
                     Ground water potential, Boreholes"),
                  tags$li(strong("Agricultural Potential: "), "Crop production / Irrigated land, Grazing Capacity, 
                     Agro-processing facilities, Land capability, Aridity zones"),
                  tags$li(strong("Mining Potential: "), "Active mines, Mineral deposits, Mining applications"),
                  tags$li(strong("Tourism Potential: "), "Terrain index, Cultural and heritage sites"),
                  tags$li(strong("Environment Sensitivity: "), "Protected and Conservation Areas, Biodiversity and 
                          Geohazards, NFEPA rivers and wetlands.")),
                p(strong("Course of action/Recommendation example - "), "Improve the look
                  of the cities for more tourism attraction, supply more water to cities 
                  that need it. Identify possible short routes between Cities and Towns
                  with similar natural resources and aid where needed."),
                strong("Course of Action or Recommendation Example:"),
                img(src = "nr_policy.jpg", height = 550, width = 980),
                br(),
                br(),
                h2("Human Development Index"),
                p(strong("Human Development - "), "Human development is defined as the process of
                  enlarging people’s freedoms and opportunities and improving their well-being"),
                p(strong("Human Development Index - "), "The HDI is a summary measure of human 
                  development. The HDI is a summary composite measure of a country’s average
                  achievements in three basic aspects of human development: 
                  health, knowledge and standard of living. It is a measure of 
                  a country’s average achievements in three dimensions of human development"),
                h4("Human Development Index Indicators used in Dashboard"),
                tags$ul(
                  tags$li(strong("Education: "), "Primary education ( % > 20 years old with primary education only),
                          Matric pass rate (% Matric pass rate 2017)"),
                  tags$li(strong("Income: "), "Average per capita income (personal income), 
                          Population living below breadline
                          (% population living below national mean level of living in 2011), 
                          Social grant dependency (% population receiving social grants)"),
                  tags$li(strong("Occupation: "), "Unskilled workers (% of unskilled workers)"),
                  tags$li(strong("Health Status: "), "HIV/AIDS status (% Population with HIV/AIDS)"),
                  tags$li(strong("Housing: "), "Informal housing (% population living in informal housing units)")),
                p(strong("Course of action/Recommendation example - "), "More educators, 
                  Jobs and medical specialists to improve HDI"),
                strong("Course of Action or Recommendation Example:"),
                img(src = "hd_policy.jpg", height = 550, width = 980),
                br(),
                br(),
                h2("Policy Intelligence"),
                p(strong("Twitter For Analysis - "), "Twitter can provide key insights into
                  what citizens are saying about Natural Resources and the Human Development
                  Index. This is a great way to find out about what is happening or trending."),
                p(strong("Sentiment - "), "A sentiment is a view or opinon that is 
                  held or expressed. Similar to: View, point of view, feeling, attitude, 
                  thought. Positive and negative sentiments can be extratced from the tweets 
                  posted on twitter."),
                p(strong("Positive Sentiment - "), "This can highlight where citizens are 
                  positively responding to NR and HDI delivery."),
                p(strong("Negative Sentiment - "), "This can highlight key issues citizens 
                  care about.")
                
                
              )) # end di tab

    ) # end of tabItems 
  ) # end of body
) # end of Page 