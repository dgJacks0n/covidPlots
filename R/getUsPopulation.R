#' @title getUsPopulation
#' Download population estimates by state and county from US census.
#' 
#' @param dataUrl URL to download data
#' 
#' @return list of 2 data frames for city and state level data

#suppressPackageStartupMessages(library(dplyr))

getUsPopulation <- function(dataUrl = 
															"https://www2.census.gov/programs-surveys/popest/datasets/2010-2019/counties/totals/co-est2019-alldata.csv") {
	
	usPopData <- read.csv(dataUrl, header = T, stringsAsFactors = F)
	
	# record download time
	downloaded <- Sys.time()
	
	# remove unneeded columns
	usPopData <- dplyr::select(usPopData, SUMLEV, REGION, DIVISION, STATE, STNAME,
														 COUNTY, CTYNAME, POPULATION = POPESTIMATE2019)
	
	# Extract state level data
	usPopByState <- dplyr::filter(usPopData, SUMLEV == 40) %>%
		dplyr::select(-SUMLEV, -COUNTY, -CTYNAME)
	
	
	# tag with source and download time and save
	attr(usPopByState, "source") <- dataUrl
	
	attr(usPopByState, "downloaded") <- downloaded
	
	
	# extract county level data, tag and save
	usPopByCounty <- dplyr::filter(usPopData, SUMLEV == 50) %>%
		dplyr::select(-SUMLEV)
	
	# need to add formated concatenation of state and county code for FIPS
	usPopByCounty$FIPS <- with(usPopByCounty, sprintf("%02i%03i", STATE, COUNTY))
	
	# move population to last column
	usPopByCounty <- dplyr::select(usPopByCounty, -POPULATION, POPULATION)
	
	attr(usPopByCounty, "source") <- dataUrl
	
	attr(usPopByCounty, "downloaded") <- downloaded
	
	return(list(state = usPopByState,
							county = usPopByCounty))
	
}


#' @title getUsStatePopulation
#' 
#' Get state-level population estimates from US census
#' 
#' @param ... Passed through to getUsPopulation
#' 
#' @return Data frame with population by state (no posessions) with columns:
#' REGION numeric code for region (time zone?)
#' DIVISION numeric code for division (e.g. New England?)
#' STATE numeric FIPS code for state
#' STNAME full name of state
#' POPULATION population estimate
#' 
#' @export

getUsStatePopulation <- function(...) {
	# get state and county data
	allPopData <- getUsPopulation(...)
	
	return(allPopData[["state"]])
}

#' @title getUsCountyPopulation
#' 
#' Get county-level population estimates from US census
#' 
#' @param ... Passed through to getUsPopulation
#' 
#' @return Data frame with population by county (no cities) with columns:
#' REGION numeric code for region (time zone?)
#' DIVISION numeric code for division (e.g. New England?)
#' STATE numeric FIPS code for state
#' STNAME full name of state
#' COUNTY numeric code for county (nested within STATE)
#' CTYNAME Full name of county
#' FIPS fips code for county (aggregation of state and county codes)
#' POPULATION population estimate
#' 
#' @export

getUsCountyPopulation <- function(...) {
	allPopData <- getUsPopulation(...)
	
	return(allPopData[["county"]])
}