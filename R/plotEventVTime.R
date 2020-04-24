#' Plot events (cases, deaths) over time (date) as line plots
#' 
#' @param pData data in form of one row per day per group
#' @param level value to group line plots
#' @param value value for y-axis
#' @param relativeDate use actual date (F) or days from first case (T) on x-axis
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
													 relativeDate = F,
													 hKey = NA, hGroupName = NA,  usePlotly = T) {
	# get plot settings
	pGroup <- match.arg(level)
	
	yVal <- match.arg(value)
	
	# use actual date or days from first case on X axis?
	if(relativeDate) {
		pData <- addRelativeDate(pData)
		
		xCol <- "days_from_first_case"
	} else {
	# set X axis and label
		xCol <- "date"
	}

	# define axis labels and plot title
	xLabel <- stringr::str_to_title(gsub("_", " ", xCol))
	yLabel <- stringr::str_to_title(gsub("_", " ", value))
	
	pTitle <- paste(yLabel, "vs.", xLabel, "by",
									stringr::str_to_title(pGroup))
	
	
	# set highlight key for plotly plots
	if(usePlotly) {
		# group by level unless specified otherwise
		hKey <- ifelse(!is.na(hKey), hKey, pGroup)
		
		if(!(hKey %in% colnames(pData))) {
			stop("Highlight key ", hKey, " is not a column in the plot data")
		}
		
		# define group name if not provided
		hGroupName <- ifelse(!is.na(hGroupName), hGroupName, hKey)
		
		pData <- pData %>% plotly::highlight_key(key = as.formula(paste0("~", hKey)), 
																						 group = hGroupName)

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

# relativeDate: calculate days relative to first case by group.
addRelativeDate <- function(myData, group = c("state", "county")) {
	# use fips to group by county
	groupCol <- ifelse(match.arg(group) == "state", "state", "fips")
	
	# get first case for each group
	firstCase <- myData %>% 
		dplyr::filter(cases > 0) %>%
		dplyr::group_by_at(groupCol) %>%
		dplyr::summarise(first_case_date = min(date)) %>%
		dplyr::ungroup()
	
	# add to myData
	myData <- dplyr::left_join(myData, firstCase, by = groupCol)
	
	# calculate days from first case
	myData$days_from_first_case <- 
		as.integer(myData$date - myData$first_case_date, unit = "days")
	
	myData$first_case_date <- NULL
	
	return(myData)
	
}