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
      sidebarUserPanel("Marius Popa", image="m1.jpg"),
      sidebarMenu(
        menuItem("Introduction", tabName="intro", icon=icon("ambulance")),
        menuItem("Patient Outcomes", tabName="bysex", icon=icon("ambulance")),
        menuItem("Drugs Outcomes", tabName="bydrug", icon=icon("ambulance")),
        menuItem("Occurence Map", tabName="map1", icon=icon("map")),
        menuItem("Drug Specific", tabName="drugspec", icon=icon("ambulance"))
      )
    ),
    dashboardBody(
      tabItems(
        tabItem(tabName = "intro", 
            #fluidPage(
               #box(width=10, 
                #   title = "FDA Adverse Event Database - A Visualization",
                   tags$ul(
                     tags$li("Data: The data set was downloaded from Enimga, with the originator being the US FDA."),
                     p(""),
                     tags$li("Data Purpose: Surveillance by FDA of drugs' adverse effects after they are approved. "),
                     p(""),
                     tags$li("Data Size: 4.5 million rows by 60 fields, covering 2001-2015"),
                     p(""),
                     tags$li("Data Size: for the purpose of hosting the app, I reduced the dataset to about 200k rows, covering only Jan 2015"),
                     p(""),
                     tags$li("Aim 1: Visualizing patient demographics."),
                     p(""),
                     tags$li("Aim 2: Visualizing the correlation between drugs and adverse events (challenge/rechallenge)."),
                     p(""),
                     tags$li("Aim 3: Visualizing the events and ultimate outcomes associated with a single drug."),
                     p(""),
                     tags$li("Aim 4: Visualizing the geographic distribution of adverse event reports received by the FDA."),
                     p("")
                  )
              # ) # end box
          #  ) # end fluid page
        ),
        tabItem(tabName = "drugspec", 
          fluidRow(
            column(width=3, 
              selectizeInput(inputId = "drugname", 
                             label = "Select a Drug:", 
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
            column(width=5,DT::dataTableOutput("drugtable")),
            column(width=6, offset=1, 
                   fluidRow(plotOutput(width="100%", height = "350px", "outcomecloud")),
                   fluidRow(plotOutput(width="100%", height = "600px", "eventcloud"))
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
            column(width=4,
                  tags$ul(
                    tags$li("Positive dechallenge:stop drug, AE stops."),
                    p(""),
                    tags$li("Negative dechallenge:stop drug, AE doesn't stop."), 
                    p(""),
                    tags$li("Positive rechallenge:restart drug, AE starts."),
                    p(""),
                    tags$li("Negative rechallenge:stop drug, AE doesn't stop.")
                  )
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
