#' Load state-level data for US COVID-19 cases from New York Times git repo
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
	
	return(stateData)
}

