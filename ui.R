library(shiny)
library(shinydashboard)
library(leaflet)
library(plotly)

#DT::dataTableOutput()

# Idea: use CSS to create a different style
# Idea: keep everything inside a tab, but align the controls within one row at top
shinyUI(dashboardPage(skin = "black",
    dashboardHeader(title = "FDA Adverse Event Data"),
    dashboardSidebar(
      sidebarUserPanel("Marius"),
      sidebarMenu(
        menuItem("Patient Outcomes", tabName="bysex", icon=icon("ambulance")),
        menuItem("Drugs Outcomes", tabName="bydrug", icon=icon("ambulance")),
        menuItem("Occurence Map", tabName="map1", icon=icon("map")),
        menuItem("Drug Specific", tabName="drugspec", icon=icon("ambulance"))
      )
    ),
    dashboardBody(
      tabItems(
        tabItem(tabName = "drugspec", 
          fluidRow(
            column(width=3, 
              selectizeInput(inputId = "drugname", 
                             label = "Select A Drug:", 
                             choices = drugOptions())
            ), #end column 
            column(width=3,
               dateInput(inputId = "d1DateStart",
                         label = "Start FDA Report Date",
                         value = "2015-01-01",
                         min = "2001-06-07",
                         max = "2018-04-27")
            ), #end column
            column(width=3,
                   dateInput(inputId = "d1DateEnd",
                             label = "End FDA Report Date",
                             value = "2016-01-01",
                             min = "2001-06-07",
                             max = "2018-04-27")
            ) #end column
          ),
          fluidRow(
            column(width=6,DT::dataTableOutput("drugtable")),
            column(width=4, offset=2, 
                   fluidRow(plotOutput("outcomecloud")),
                   fluidRow(plotOutput("eventcloud"))
            )
          )
        ),
        tabItem(tabName = "bydrug",
          fluidRow(
            column(width=3,
                   dateInput(inputId = "chDateStart",
                             label = "Start FDA Report Date",
                             value = "2001-06-07",
                             min = "2001-06-07",
                             max = "2018-04-27"),
                   dateInput(inputId = "chDateEnd",
                             label = "End FDA Report Date",
                             value = "2016-01-01",
                             min = "2001-06-07",
                             max = "2018-04-27")
            ),
            column(width=3,
                   selectizeInput(inputId = "challenge",
                                  label = "Challenge",
                                  choices = chOptions()),
                   selectizeInput(inputId = "rechallenge",
                                  label = "Rechallenge",
                                  choices = chOptions())
            ),
            column(width=3, 
                   textOutput("explainChallenge")
            )
          ),
          fluidRow(
            plotlyOutput("challengeIncidence")
          )
        ),
        tabItem(tabName = "map1",
          fluidRow(
            column(width=3,
                   dateInput(inputId = "mapDateStart", 
                             label = "Start FDA Report Date", 
                             value = "2001-06-07", 
                             min = "2001-06-07",
                             max = "2018-04-27")
            ),
            column(width=3,
                   dateInput(inputId = "mapDateEnd", 
                             label = "End FDA Report Date", 
                             value = "2016-01-01", 
                             min = "2001-06-07",
                             max = "2016-01-01")
            )
          ),
          fluidRow(
            plotlyOutput("map1", height = "900", width="100%")
          )
        ),
        
        tabItem(tabName = "bysex", 
          fluidRow(
              column(width=3, 
                     
                dateInput(inputId = "reportDateStart", 
                          label = "Start FDA Report Date", 
                          value = "2001-06-07", 
                          min = "2001-06-07",
                          max = "2018-04-27"),
                
                dateInput(inputId = "reportDateEnd", 
                          label = "End FDA Report Date", 
                          value = "2016-01-01", 
                          min = "2001-06-07",
                          max = "2016-01-01")
                
              ),
              column(width=3,
                     
                selectizeInput(inputId = "outcome",
                               label = "Patient Outcome",
                               choices = allOutcomes()),
                
                selectizeInput(inputId = "groupBy", 
                               label = "Group By",
                               choices = allGroupBy())
                
              )
          ),  # end fluidRow
          fluidRow(column(6, plotOutput("bysex")))
        )
      )
    )
  )
)
