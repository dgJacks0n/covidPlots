#' Get state-level case and death counts and rates
#' 
#' Load state-level data for US COVID-19 cases from New York Times git repo.
#' Add population from 'getUsCountyPopulation' and calculate per capita case and death rates
#' 
#' @param dataUrl Source URL for data
#' @param popData state-level population data from getUsStatePopulation
#' 
#' @return Data frame of case numbers and dates with attributes 'source' (dataUrl) and 'timestamp' (download time)
#' 
#' @export


getUsStateCases <- function(dataUrl = 
								"https://raw.githubusercontent.com/nytimes/covid-19-data/master/us-states.csv",
								popData = getUsStatePopulation()) {

	# load state-level data
	stateData <- read.csv(dataUrl, header = T, stringsAsFactors = F)
	
	# record download time
	dtime <- Sys.time()
	
	# convert date
	stateData$date <- as.Date(stateData$date, format = "%Y-%m-%d") 
	
	# Values for cases and deaths are cumulative, need to get new
	stateData <- newEvents(stateData, "state") 
	
	# add population estimates
	# statePopulations <- getUsStatePopulation() %>% 
	popData <- dplyr::select(popData, STATE, population = POPULATION)
	
	stateData <- dplyr::left_join(stateData, popData, 
												 by = c("fips" = "STATE"))
	
	# calculate per capita case rates
	stateData$cases_per_capita <- with(stateData, (cases/population))
	
	stateData$deaths_per_capita <-with(stateData, (deaths/population))
	
	# record source and download time as attributes
	attr(stateData, "source") <- dataUrl
	
	attr(stateData, "timestamp") <- dtime
	
	
	return(stateData)
}

