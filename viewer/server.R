# Viewer for covid 19 data
#
 
library(shiny)
library(drake)
library(plotly)
library(covidPlots) # should be installed from ../lib/covidPlots
library(ggToys)

# load data
loadd(stateData)
loadd(countyData)
loadd(usMap)

lastStateData <- getLastStateData(stateData)

lastCountyData <- getLastCountyData(countyData)

ggplot2::theme_set(theme_dj())

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
    eventChoice <- reactive({ input$event })
    
    selectedStates <- reactive({ 
      sPoints <- event_data("plotly_click")
      
      return(sPoints$key)
    })
    
    output$eventPlot <- renderPlotly({
        
        p_casesByState <- plotCurrentCount(lastStateData, xCol = "state",
                                           value = eventChoice(),
                                           hGroupName = "byState")
        
        p_caseGrowthByState <- plotEventVTime(stateData, 
                                              value = eventChoice(),
                                              hGroupName = "byState")

       comboPlot <-  plotly::subplot(p_casesByState, p_caseGrowthByState,
                        widths = c(0.25, 0.75),
                        shareX = F, shareY = T,
                        which_layout = 1) %>%
            plotly::highlight(dynamic = F, 
                              selectize = T, 
                              color = c("red", "green", "blue"),
                              persistent = T,
                              on = "plotly_click")
                          
            
      
    
    })
    
    output$eventMap <- renderPlotly({
      # works but horribly slow...
      eventMap <- plotUsMap(lastCountyData, event = eventChoice(), map = usMap)
    })
    
    output$info <- renderPrint({
      event_data("plotly_click")
    })
    
    output$dataAnnotation <- renderText({
      paste("Data was downloaded from",
            attr(stateData, "source"),
            "at", attr(stateData, "timestamp"),
            "and includes cases through",
            max(stateData$date))
    })
    
    output$selectedStates <- renderText({
      req(selectedStates())
      paste("Selected States:", selectedStates())
    })
})
