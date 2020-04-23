#' Calculate new deaths and cases from cumulative values
#' 
#' @param myData state or county-level data
#' @param level level to group data at
#' 
#' @return input data with additional columns 'new_cases' and 'new_deaths'

newEvents <- function(myData, level = c("state", "county")) {
	# use on state for state-level but use fips for county-level
	myLevel <- ifelse((match.arg(level) == "state"), "state", "fips")
	
	# check inputs
	stopifnot(is.data.frame(myData))
	stopifnot(myLevel %in% colnames(myData))
	
	# calculate change from previous day by level
	# calculate new cases
	newData <- myData %>%
		dplyr::group_by_at(myLevel) %>%
		dplyr::arrange(date, .by_group = T) %>%
		dplyr::mutate(new_cases = cases - 
										dplyr::lag(cases, default = dplyr::first(cases)),
									new_deaths = deaths - 
										dplyr::lag(deaths, default = dplyr::first(deaths))) %>%
		dplyr::ungroup()
	
	return(newData)
}