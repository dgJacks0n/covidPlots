#! Rscript
# getUsPopulation.R
# code to download population estimates by state and county
# from US census.
# Data will be serialized to RDS files under directory 'outdir'
# with separate files for state and county

suppressPackageStartupMessages(library(dplyr))

# get path for output from command line options
library(optparse)

# define command line options
option_list <- list(
	make_option(c("-o", "--outputdir"),
							type = "character",
							help = "Directory path to output RDS files",
							action = "store"),
	make_option(c("-v", "--verbose"),
							action = "store_true",
							default = FALSE,
							help = "Show verbose output (default: f)",
	)
)

opts <- parse_args(OptionParser(option_list = option_list))


# path to save output
usPopDataDir <- opts$outputdir

verbose <- opts$verbose

if(!dir.exists(usPopDataDir)) {
	dir.create(usPopDataDir)
	
	if(verbose) { message("Created Directory ", usPopDataDir)}
} else{
	stopifnot(file_test("-d", usPopDataDir))
}

usStatePopFile <- paste(usPopDataDir, "statePopulations.Rds", sep = "/")

usCountyPopFile <- paste(usPopDataDir, "countyPopulations.Rds", sep = "/")

# URL for population data NOTE - this is state only, no territories/posessions except DC
usPopUrl <- "https://www2.census.gov/programs-surveys/popest/datasets/2010-2019/counties/totals/co-est2019-alldata.csv"

usPopData <- read.csv(usPopUrl, header = T, stringsAsFactors = F)

# record download time
downloaded <- Sys.time()

# remove unneeded columns
usPopData <- select(usPopData, SUMLEV, REGION, DIVISION, STATE, STNAME,
										COUNTY, CTYNAME, POPULATION = POPESTIMATE2019)

# Extract state level data
usPopByState <- filter(usPopData, SUMLEV == 40) %>%
	select(-SUMLEV, -COUNTY, -CTYNAME)


# tag with source and download time and save
attr(usPopByState, "source") <- usPopUrl

attr(usPopByState, "downloaded") <- downloaded

saveRDS(usPopByState, file = usStatePopFile)

if(verbose) { message("Downloaded State Populations to ", usStatePopFile)}

# extract county level data, tag and save
usPopByCounty <- filter(usPopData, SUMLEV == 50)

# need to add formated concatenation of state and county code for FIPS
usPopByCounty$FIPS <- with(usPopByCounty, sprintf("%02i%03i", STATE, COUNTY))

attr(usPopByCounty, "source") <- usPopUrl

attr(usPopByCounty, "downloaded") <- downloaded

saveRDS(usPopByCounty, file = usCountyPopFile)

if(verbose) { message("Downloaded County Populations to ", usCountyPopFile) }
