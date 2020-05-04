# Shiny Viewer for US Covid data

library(shiny)
library(plotly)
library(DT)

# Define UI for application that draws a histogram
shinyUI(fluidPage(

    # Application title
    titlePanel("US Covid-19 Case and Death Data"),

    # Sidebar with a slider input for number of bins
    sidebarLayout(
        sidebarPanel(
            selectInput("event", "Event to plot",
                        choices = c("Cases" = "cases",
                                    "Cases per Capita" = "cases_per_capita",
                                    "Deaths" = "deaths",
                                    "Deaths per Capita" = "deaths_per_capita"),
                        multiple = F),
            textOutput("dataAnnotation")
        ),

        # Show a plot of the generated distribution
        mainPanel(
            tabsetPanel(
                tabPanel("Events", plotlyOutput("eventPlot"),
                         textOutput("selectedStates"),
                         DT::dataTableOutput("eventTable")
                         #verbatimTextOutput("info")
                         ),
                tabPanel("Map", plotlyOutput("eventMap"))
            )
        )
    )
))
