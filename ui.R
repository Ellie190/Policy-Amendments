library(shiny)
library(bs4Dash)

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
      name = "Analysis"
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
                         box(title = "Attribute Mapping", status = "white",
                             width = 12,
                             solidHeader = TRUE, maximizable = TRUE)),
                  column(3,
                         box(title = "Select Attribute", status = "primary",
                             width = 12, solidHeader = TRUE))
                )
              )) # end of nha tab
    )
  ) # end of body
) # end of Page 