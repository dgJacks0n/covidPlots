# make.R
# master script for use with drake package


# packages
library(drake)
library(here)
library(covidPlots)

# where to write reports and what format
resultDir <- paste(here(), "results", sep = "/")

resultType = "html"

# generate output file based on input
resultFile <- function(rmdFile, resDir, resType) {
	newbase <- sub("\\.[A-Za-z]+$", "", basename(rmdFile))
	
	newbase <- paste(newbase, resType, sep = ".")
	
	resPath <- paste(resDir, newbase, sep = "/")
	
	return(resPath)
}

# define analysis workflow
plan <- drake_plan(
	stateData  = getUsStateCases(),
									 
	countyData = getUsCountyCases(),

	countyPopulations = getUsCountyPopulation(),
	
	statePopulations = getUsStatePopulation(),
	
	usMap = getUsMap(),
	
	rmarkdown::render(
		knitr_in("./us_covid_rates.Rmd"),
		output_file = file_out("./us_covid_rates.html"),
		envir = new.env(),
		quiet = TRUE
	)
	
)

# get graph of workflow
workGraph <- vis_drake_graph(plan)

workGraph

# run
make(plan, lock_envir = F) # disabling lock_env is a 'bad thing'.  Need to debug
