#' Get county-level case and death counts and rates
#' 
#' Load county-level data for US COVID-19 cases from New York Times git repo.
#' Add population from 'getUsCountyPopulation' and calculate per capita case and death rates
#'
#' @param dataUrl Source URL for county-level data
#' 
#' @return data frame of county-level data with attributes 'source' (dataUrl) and 'timestamp' (download time)
#' 
#' @export

getUsCountyCases <- function(dataUrl = 
														 	"https://raw.githubusercontent.com/nytimes/covid-19-data/master/us-counties.csv") {
	# read data
	countyData <- read.csv(dataUrl, header = T, stringsAsFactors = F,
												 colClasses = c("fips"="character"))
	
	# record download time
	dtime <- Sys.time()
	
	# remove cases with 'unknown' 
	countyData <- dplyr::filter(countyData, county != "Unknown")
	
	# convert date
	countyData$date <- as.Date(countyData$date, format = "%Y-%m-%d")
	
	# calculate new cases
	countyData <- newEvents(countyData, "county")
	
	# add population and calculate per capita case and deathrates

	#countyPopulations <- getUsCountyPopulation() %>% 
	drake::loadd(countyPopulations) %>%
		dplyr::select(FIPS, population = POPULATION)
	
	# merge with cases
	countyData <- dplyr::left_join(countyData, 
													countyPopulations,
													by = c("fips" = "FIPS"))
	
	countyData$cases_per_capita <- with(countyData,  (cases/population))
	
	countyData$deaths_per_capita <- with(countyData, (deaths/population))
	
	# annotate source and download time
	attr(countyData, "source") <- dataUrl
	
	attr(countyData, "timestamp") <- dtime
	
	
	return(countyData)
	
}