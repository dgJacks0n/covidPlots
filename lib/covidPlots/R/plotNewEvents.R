#' Plot new cases or deaths smoothed over a multi-day window
#' 
#' @param eData Event data at state or county level
#' @param event Type of event (new cases or new deaths)
#' @param group Level to group events at
#' @param window Window for rolling average in days (positive integer)
#' @param usePlotly: make plot interactive with  plotly?
#' 
#' The following options only apply if usePlotly = T
#' @param hKey (optional): value for highlightning interactive plots; 
#' off if value is NA
#' @param hGroupName (otpional): group name for highlighting interactive plots; 
#' defaults to hGroup if specified.
#' 
#' @return plot object from ggplot2 or plotly
#' 
#' @export

plotNewEvents <- function(eData, event = c("new_cases", "new_deaths"), 
													group = c("state", "county"), window = 7,
													usePlotly = T, hKey = NA, hGroupName = NA) {
	
	myEvent <- match.arg(event)
	
	myLevel <- match.arg(group)
	
	# get rolling average
	eData <- eventRollingAverage(eData, group = myLevel, event = myEvent, 
															 window = window)
	
	# set highlight group for ineractive plots
	
	
	# set X axis column
	xcol <- "date"
	
	# get new column name for y axis
	ycol <- attr(eData, "avgCol") 
	
	# make pretty labels
	xLabel <- stringr::str_to_title(gsub("_", " ", xcol))
	yLabel <- stringr::str_to_title(gsub("_", " ", ycol))
	gLabel <- stringr::str_to_title(gsub("_", " ", myEvent))
	
	pTitle <- paste(gLabel, "by", xLabel)
	pSubtitle <- paste("Average over", attr(eData, "window"), "Day Window")
	
	# set highlighting for plotly
	if(usePlotly) {
		# group by level unless specified otherwise
		hKey <- ifelse(!is.na(hKey), hKey, myLevel)
		
		if(!(hKey %in% colnames(eData))) {
			stop("Highlight key ", hKey, " is not a column in the plot data")
		}
		
		# define group name if not provided
		hGroupName <- ifelse(!is.na(hGroupName), hGroupName, hKey)
		
		eData <- eData %>% plotly::highlight_key(key = as.formula(paste0("~", hKey)), 
																						 group = hGroupName)
		
	}
	
	
	myPlot <- ggplot2::ggplot(eData, ggplot2::aes_q(x = as.name(xcol), 
																									y = as.name(ycol),
																									group = as.name(myLevel))) +
		ggplot2::geom_line() + 
		ggplot2::scale_y_log10() +
		ggplot2::labs(title = pTitle,
				 subtitle = pSubtitle,
				 x = xLabel, y = yLabel)
	
	# return ggplot object if usePlotly is false
	if(!usePlotly) {
		return(myPlot)
	}
	
	# return plotly plot
	iPlot <- plotly::ggplotly(myPlot)
	
	return(iPlot)
	
}