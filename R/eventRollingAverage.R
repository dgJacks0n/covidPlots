#' Calculate rolling average of new cases or deaths
#' 
#' @param eData Event data at state or county level
#' @param event Type of event
#' @param group Level to group events at
#' @param window Window for rolling average in days (positive integer)
#' @param dropNAs Exclude NA values from zoo::rollmean
#' 
#' @return data frame with new collumn for rolling average.  
#'  Window size and new column with rolling average are recorded as 
#'  attributes 'window' and 'avgCol' of the data frame
#' 
#' @export

eventRollingAverage <- function(eData, event = c("new_cases", "new_deaths"), 
																group = c("state", "county"), window = 7,
																dropNAs = T) {

	# check that window is a positive integer
	stopifnot(is.numeric(window) & window > 0)
	
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
	
	# remove na's unless requested to keep
	if(dropNAs) {
		eData <- dplyr::filter_at(eData, newColName,  dplyr::all_vars(!is.na(.)))
	}
	
	attr(rollingAvg, "avgCol") <- newColName
	attr(rollingAvg, "window") <- window
	
	return(rollingAvg)
}

