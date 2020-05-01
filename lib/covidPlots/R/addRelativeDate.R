#' Calculate days relative to first case by group
#' 
#' @param myData state or county dataset
#' @param group level to group dataset
#'

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