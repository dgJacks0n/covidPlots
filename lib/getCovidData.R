suppressPackageStartupMessages({ 
	library(httr)
	library(dplyr)
	library(lubridate)
	library(jsonlite)
})


#' downloadCovidData: get data from statworx api
downloadCovidData <- function(covidUrl = "https://api.statworx.com/covid") {
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

# tag with URL and date
attr(df, "url") <- covidUrl

attr(df, "downloaded") <- Sys.time()



return(df)
}

#' getCovidData: retrieve covid dataset from memory or download
#' note- add arg for data age
getCovidData <- function(...) {
	if(!exists("covidData")) {
		covidData <- downloadCovidData(...)
	}
	return(covidData)
}
