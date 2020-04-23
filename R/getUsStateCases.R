#' Get state-level case and death counts and rates
#' 
#' Load state-level data for US COVID-19 cases from New York Times git repo.
#' Add population from 'getUsCountyPopulation' and calculate per capita case and death rates
#' 
#' @param dataUrl Source URL for data
#' 
#' @return Data frame of case numbers and dates with attributes 'source' (dataUrl) and 'timestamp' (download time)
#' 
#' @export


getUsStateCases <- function(dataUrl = 
								"https://raw.githubusercontent.com/nytimes/covid-19-data/master/us-states.csv") {

	# load state-level data
	stateData <- read.csv(dataUrl, header = T, stringsAsFactors = F)
	
	# convert date
	stateData$date <- as.Date(stateData$date, format = "%Y-%m-%d") 
	
	# record source and download time as attributes
	attr(stateData, "source") <- dataUrl
	
	attr(stateData, "timestamp") <- Sys.time()
	
	# Values for cases and deaths are cumulative, need to get new
	stateData <- stateData %>%
		dplyr::group_by(state) %>%
		dplyr::arrange(date, .by_group = T) %>%
		dplyr::mutate(new_cases = cases - lag(cases, default = first(cases)),
					 new_deaths = deaths - lag(deaths, default = first(deaths))) %>%
		dplyr::ungroup()
	
	# add population estimates
	statePopulations <- getUsStatePopulation()
	
	stateData <- dplyr::left_join(stateData, 
												 statePopulations %>% select(STATE, population = POPULATION),
												 by = c("fips" = "STATE"))
	
	# calculate per capita case rates
	stateData$cases_per_capita <- with(stateData, (cases/population))
	
	stateData$deaths_per_capita <-with(stateData, (deaths/population))
	
	
	return(stateData)
}

