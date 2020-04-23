#' getLastData
#' Filter case data to most recent date at state or county level
#' 
#' @param myData data frame with state or country data
#' @param level level at which to subset data (state or county)
#' 
#'
#' @return data frame with only the most recent observation for each value of level. 

getLastData <- function(myData, level = c("state", "county")) {
	# match on state for state-level but use fips for county-level
	myLevel <- ifelse((match.arg(level) == "state"), "state", "fips")
	
	# check inputs
	stopifnot(is.data.frame(myData))
	stopifnot(myLevel %in% colnames(myData))
	
	last <- myData %>%
		group_by_at(myLevel) %>%
		arrange(desc(date), .by_group = T) %>%
		slice(1) %>%
		ungroup()
	
	return(last)
}

#' @title getLastStateData
#' Filter case data to most recent date at state level
#' 
#' @param myData data frame with state data
#'
#' @return data frame with only the most recent observation for each state
#' 
#' @export 

getLastStateData <- function(myData) {
	getLastData(myData, level = "state")
}

#' @title getLastCountyData
#' Filter case data to most recent date at county level
#' 
#' @param myData data frame with state data
#'
#' @return data frame with only the most recent observation for each county
#' 
#' @export 

getLastCountyData <- function(myData) {
	getLastData(myData, level = "county")
}