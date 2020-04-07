suppressPackageStartupMessages({ 
	library(httr)
	library(dplyr)
	library(lubridate)
	library(here)
	library(jsonlite)
})

#' getDataFilePath: path for data file
getDataFilePath <- function() {
	paste(here::here(), "covid19data.Rds", sep = "/")
}

#' downloadCovidData: get data from statworx api
downloadCovidData <- function(covidUrl = "https://api.statworx.com/covid",
															verbose = T) {
# Post to API
payload <- list(code = "ALL")
response <- httr::POST(url = covidUrl,
											 body = toJSON(payload, auto_unbox = TRUE), encode = "json")

# Convert to data frame
content <- rawToChar(response$content)
df <- data.frame(fromJSON(content),
								 stringsAsFactors = FALSE)

# convert date to date class object
df$date <- as.Date(df$date)

# calculate relative days from first case
rel_date <- df %>% 
	filter(cases_cum > 0) %>% 
	group_by(code) %>% 
	mutate(d_from_first_case = as.numeric(date - min(date))) %>%
	ungroup() %>%
	select(date, country, d_from_first_case)

# add to data frame
df <- left_join(df, rel_date, by = c("date", "country"))


# tag with URL and date
attr(df, "url") <- covidUrl

attr(df, "downloaded") <- Sys.time()


# save as RDS file
datafile <- getDataFilePath()

saveRDS(df, file = datafile)

if(verbose) {
	message("Retrieved covid19 data from ", covidUrl, 
			" and saved it to ", datafile)
}

return(TRUE)

}

#' getCovidData: retrieve covid dataset from memory or download
#' staleness: data age in hours
getCovidData <- function(staleness = 12) {
	# if loaded: feturn
	if(exists("covidData")) {
		return(covidData)
	}
	
	datafile <- getDataFilePath()
	
	# if cached file doesn't exist or is too old, download
	if(!file.exists(datafile)) {
		downloadCovidData()
	} else {
		dfage <- as.numeric(now() - file.mtime(datafile),
												units = "hours")
		
		if(dfage >= staleness) {
			downloadCovidData()
		}
	}
	
	covidData <- readRDS(datafile)
	
	return(covidData)
}
