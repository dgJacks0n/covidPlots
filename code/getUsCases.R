#! Rscript

#' getUsCases: download US case and death data from New York Times repo on github
#'
#' 
#' Download state and county data, convert dates and filter
#' Save an RDS file (determined by outputfile option) with a list 
#' contianing 2 items: state (all state data) and county (all county data)
#' Each item has attributes: source (URL) and downlooaded (download time)

library(optparse)

# define command line options
option_list <- list(
	make_option(c("-o", "--outputfile"),
							type = "character",
							help = "Path to output RDS files",
							action = "store"),
	make_option(c("-a", "--age"),
							type = "integer",
							help = "Maximum data age for local cache in hours, 0 to force reload",
							action = "store",
							default = 12
							),
	make_option(c("-v", "--verbose"),
							action = "store_true",
							default = FALSE,
							help = "Show verbose output (default: f)",
	)
)

opts <- parse_args(OptionParser(option_list = option_list))

outfile <- opts$outputfile

verbose <- opts$verbose

staleness <- opts$age

# URLs for data
dataUrls <- c("county" = 
								"https://raw.githubusercontent.com/nytimes/covid-19-data/master/us-counties.csv",
							"state" = 
								"https://raw.githubusercontent.com/nytimes/covid-19-data/master/us-states.csv")

# make sure we can write data before we download
outdir <- dirname(outfile)

stopifnot(dir.exists(outdir))

stopifnot(file.access(outdir, 2) == 0)

# make sure path ends in Rds
stopifnot( grepl("\\.Rds$", outfile, ignore.case = T) )

# do we need to download data?
# assume not.
download <- FALSE

# check whether file exists
if(!file.exists(outfile)) {
	download <- TRUE
} else{
	age <- as.numeric(Sys.time() - file.mtime(outfile),
										units = "hours")
	
	if(age >= staleness) {
		download <- TRUE
	}
}

# download the data
if(download) {
	if(verbose) { message("Downloading US datasets")}
	
	timestamp <- Sys.time()

	# load state-level data
	stateData <- read.csv(dataUrls["state"], header = T, stringsAsFactors = F)
	
	# convert date
	stateData$date <- as.Date(stateData$date, format = "%Y-%m-%d") 
	
	# record source and download time as attributes
	attr(stateData, "source") <- dataUrls["state"]
	
	attr(stateData, "downloaded") <- timestamp
	
	countyData <- read.csv(dataUrls["county"], header = T, stringsAsFactors = F,
												 colClasses = c("fips"="character"))
	
	countyData$date <- as.Date(countyData$date, format = "%Y-%m-%d")
	
	attr(countyData, "source") <- dataUrls["county"]
	
	attr(countyData, "downloaded") <- timestamp
	
	# write to file
	saveRDS(list(state = stateData,
							 county = countyData),
					file = outfile)
	
	if(verbose) { message("Downloaded data and saved to ", outfile) }
		
} else {
	if(verbose) { message("Previously downloaded data in ", outfile, 
												" does not need update, age ", 
												signif(age, 1), " hours") }
}
