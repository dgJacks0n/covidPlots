#' Plot events (cases, deaths) over time (date) as line plots
#' 
#' @param pData data in form of one row per day per group
#' @param level value to group line plots
#' @param value value for y-axis
#' @param hKey (optional): value for highlightning interactive plots; 
#' off if value is NA
#' @param hGroupName (otpional): group name for highlighting interactive plots; 
#' defaults to hGroup if specified.
#' @param usePlotly: make plot interactive with  plotly?
#' 
#' @return plot object from ggplot2 or plotly
#' 
#' @export

plotEventVTime <- function(pData, level = c("state", "county"),
													 value = c("cases", "cases_per_capita", 
													 					"deaths", "deaths_per_capita"),
													 hKey = NA, hGroupName = NA,
													 usePlotly = T) {
	# get plot settings
	pGroup <- match.arg(level)
	
	yVal <- match.arg(value)
	
	# set X axis and label
	xCol <- "date"
	
	xLabel <- "Date"
	
	# define Y axis label and plot title
	yLabel <- stringr::str_to_title(gsub("_", " ", value))
	
	pTitle <- paste(yLabel, "vs.", xLabel, "by",
									stringr::str_to_title(pGroup))
	
	
	# set highlight key if provided
	if(!is.na(hKey)) {
		if(!(hKey %in% colnames(pData))) {
			stop("Highlight key ", hKey, " is not a data column")
		}
		
		# define group name if not provided
		hGroupName <- ifelse(!is.na(hGroupName), hGroupName, hKey)
		
		pData <- pData %>% plotly::highlight_key(key = hKey, group = hGroupName)

	}
	
	# plot growth in cases by state
	sPlot <- pData %>%
		ggplot2::ggplot(ggplot2::aes_(x = as.name(xCol), y = as.name(yVal))) +
		ggplot2::geom_line(ggplot2::aes_(group = as.name(pGroup))) +
		ggplot2::labs(title = pTitle, x = xLabel, y = yLabel) +
		ggplot2::scale_y_log10()
	
	# If a static plot is wanted we're done
	if(!usePlotly) {
		return(sPlot)
	}
	
	# make interactive
	iPlot <- plotly::ggplotly(sPlot)
	
	return(iPlot)
}