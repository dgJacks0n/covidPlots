#!Rscript

# getUsMap.R
# download Mapbox file for US counties to support US chlorpleth maps
library(rjson)
library(optparse)


# define command line options
option_list <- list(
	make_option(c("-o", "--outputfile"),
							type = "character",
							help = "Path to output RDS file",
							action = "store"),
	make_option(c("-v", "--verbose"),
							action = "store_true",
							default = FALSE,
							help = "Show verbose output (default: f)",
	)
)

opts <- parse_args(OptionParser(option_list = option_list))
	
outFile <- opts$outputfile
verbose <- opts$verbose

if(verbose) { message("Writing US map to ", outFile) }



# load county map
countyMapUrl = 'https://raw.githubusercontent.com/plotly/datasets/master/geojson-counties-fips.json'

countyMapData<- rjson::fromJSON(file=countyMapUrl)

# tag with info on date and time of download 
attr(countyMapData, "source") <- countyMapUrl

attr(countyMapData, "downloaded") <- Sys.time()

# write output file
saveRDS(countyMapData, file = outFile)

if(verbose) {
	message("Downloaded US map from ", countyMapUrl,
					" at ", attr(countyMapData, "downloaded"),
					" and serialized to ", outFile)
}

