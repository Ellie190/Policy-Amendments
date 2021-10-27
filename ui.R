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




dashboardPage(
  fullscreen = TRUE,
  help = TRUE,
  dashboardHeader(
    title = dashboardBrand(
      title = "Policy Amendments",
      color = "warning",
      href = "https://en.wikipedia.org/wiki/Northern_Cape",
      image = "https://southafrica.co.za/images/northern-cape-province-arms-786x633.jpg"
    ),
    skin = "light",
    status = "white"), # end of header
  dashboardSidebar(
    skin = "light",
    status = "warning",
    sidebarUserPanel(
      image = "https://image.flaticon.com/icons/svg/1149/1149168.svg",
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
                             solidHeader = TRUE, maximizable = TRUE,
                             leafletOutput("tab1_map")
                             )),
                  column(3,
                         box(title = "View Card", status = "lightblue",
                             icon = icon("filter"),
                             width = 12, solidHeader = TRUE,
                             uiOutput("attr_sel1"),
                             strong("Cities not recognised by OpenStreetMap"),
                             p(" "),
                             dataTableOutput("tab1_tbl", height = 2)))
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
                             plotlyOutput("distplt1"))),
                  column(5,
                         box(title = "Natural Resource City Groups", status = "lightblue",
                             icon = icon("object-group"),
                             width = 12, solidHeader = TRUE, maximizable = TRUE,
                             plotlyOutput("clustplt1")))
                ),
                fluidRow(
                  column(6,
                         box(title = "City Group Mapping", status = "lightblue",
                             icon = icon("map-marked-alt"),
                             width = 12, solidHeader = TRUE, maximizable = TRUE,
                             leafletOutput("clust_nr"))),
                  column(6,
                         tabBox(maximizable = TRUE, width = 12,
                                solidHeader = FALSE, status = "lightblue",
                                tabPanel("Group Table", icon = icon("table"),
                                         dataTableOutput("clustTbl1")),
                                tabPanel("NR Group Count", icon = icon("chart-bar"),
                                         plotlyOutput("clustbar1"))))
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
                             plotlyOutput("distplt2"))),
                  column(5,
                         box(title = "Human Development City Groups", status = "lightblue",
                             icon = icon("object-group"),
                             width = 12, solidHeader = TRUE, maximizable = TRUE,
                             plotlyOutput("clustplt2")))
                ),
                fluidRow(
                  column(6,
                         box(title = "City Group Mapping", status = "lightblue",
                             icon = icon("map-marked-alt"),
                             width = 12, solidHeader = TRUE, maximizable = TRUE,
                             leafletOutput("clust_hdi"))),
                  column(6,
                         tabBox(maximizable = TRUE, width = 12,
                                solidHeader = FALSE, status = "lightblue",
                                tabPanel("Group Table", icon = icon("table"),
                                         dataTableOutput("clustTbl2")),
                                tabPanel("HDI Group Count", icon = icon("chart-bar"),
                                         plotlyOutput("clustbar2"))))
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
                             textInput(inputId = "query", label = "Topic/ Hashtag", value = "#covid19"),
                             sliderInput(
                               inputId = "n_tweets",
                               label = "Number of tweets:",
                               min = 1,
                               max = 2000,
                               value = 10),
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
                             leafletOutput("tweet_prox"))),
),
                fluidRow(
                  column(6,
                         box(title = "Sentiment Polarity", status = "white",
                             icon = icon("users"),
                             width = 12, solidHeader = TRUE, maximizable = TRUE,
                            plotlyOutput("sent_plt"))),
                  column(6,
                         box(title = "Feedback: Sentiment Word Cloud", status = "white",
                             icon = icon("comments"),
                             width = 12, solidHeader = TRUE, maximizable = TRUE,
                             plotOutput("word_plt")))
                )
              )
              ) # end of pi tab
    ) # end of tabItems 
  ) # end of body
) # end of Page 