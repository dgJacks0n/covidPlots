#' Calculate rolling average of new cases or deaths
#' 
#' @param event Type of event
#' @param group Level to group events at
#' @param window Window for rolling average in days (positive integer)
#' 
#' @return data frame with new collumn for rolling average.  Rolling average will be NA
#'  for rows with fewer than window  prior days.  Window size is recorded as a column attribute
#' 
#' @export

eventRollingAverage <- function(eData, event = c("new_cases", "new_deaths"), 
																group = c("state", "county"), window = 7) {

	# check that window is a positive integer
	stopifnot(is.integer(window) & window > 0)
	
	# get event selection 
	myEvent <- match.arg(event)
	
	# check that event is present and numeric
	stopifnot(myEvent %in% colnames(eData))
	stopifnot(is.numeric(eData[[myEvent]]))
	
	
	# new column name for rolling average
	newColName <- paste("average", myEvent, sep = "_")
	
	# duplicate column for average; new column will get overwritten
	eData[newColName] <- eData[myEvent]
	
	# convert group level: use state for state and fips for county
	myLevel <- ifelse(match.arg(group) == "state", "state", "fips")
	
	stopifnot(myLevel %in% colnames(eData))
	
	# calculate rolling average
	rollingAvg <- eData %>%
		dplyr::group_by_at(myLevel) %>%
		dplyr::arrange(date, .by_group = T) %>%
		dplyr::mutate_at(dplyr::vars(newColName),  
										 zoo::rollmean, window, fill = NA, align = "right") %>%
		dplyr::ungroup() 
	
	attr(rollingAvg, avgCol) <- myEvent
	attr(rollingAvg, window) <- window
	
	return(rollingAvg)
}

