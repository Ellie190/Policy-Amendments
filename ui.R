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
                             width = 12,
                             solidHeader = TRUE, maximizable = TRUE,
                             leafletOutput("tab1_map")
                             )),
                  column(3,
                         box(title = "View Card", status = "primary",
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
                             width = 12, solidHeader = FALSE, elevation = 5,
                             uiOutput("dist1"),
                             numericInput("clustnum1", "Enter Number of Groups",
                                          value = 7,
                                          min = 2, max = 8,
                                          width = "auto"))),
                  column(4,
                         box(title = "Distribution", status = "white",
                             width = 12, solidHeader = TRUE, maximizable = TRUE,
                             plotlyOutput("distplt1"))),
                  column(5,
                         box(title = "City/Town Groups", status = "white",
                             width = 12, solidHeader = TRUE, maximizable = TRUE,
                             plotlyOutput("clustplt1")))
                ),
                fluidRow(
                  column(6,
                         box(title = "City Group Mapping", status = "warning",
                             width = 12, solidHeader = FALSE, maximizable = TRUE,
                             leafletOutput("clust_nr"))),
                  column(6,
                         tabBox(maximizable = TRUE, width = 12,
                                solidHeader = FALSE, status = "warning",
                                tabPanel("Group Table",
                                         dataTableOutput("clustTbl1")),
                                tabPanel("Group Count",
                                         plotlyOutput("clustbar1"))))
                )
              )),
      tabItem("hdi",
              fluidPage(
                fluidRow(
                  column(3,
                         box(title = "View Card", status = "warning",
                             width = 12, solidHeader = FALSE, elevation = 5,
                             uiOutput("dist2"),
                             numericInput("clustnum2", "Enter Number of Groups",
                                          value = 7,
                                          min = 2, max = 8,
                                          width = "auto"))),
                  column(4,
                         box(title = "Distribution", status = "white",
                             width = 12, solidHeader = TRUE, maximizable = TRUE,
                             plotlyOutput("distplt2"))),
                  column(5,
                         box(title = "City/Town Groups", status = "white",
                             width = 12, solidHeader = TRUE, maximizable = TRUE,
                             plotlyOutput("clustplt2")))
                ),
                fluidRow(
                  column(6,
                         box(title = "City Group Mapping", status = "warning",
                             width = 12, solidHeader = FALSE, maximizable = TRUE,
                             leafletOutput("clust_hdi"))),
                  column(6,
                         tabBox(maximizable = TRUE, width = 12,
                                solidHeader = FALSE, status = "warning",
                                tabPanel("Group Table",
                                         dataTableOutput("clustTbl2")),
                                tabPanel("Group Count",
                                         plotlyOutput("clustbar2"))))
                )
              ))
    ) # end of tabItems 
  ) # end of body
) # end of Page 