# make.R
# master script for use with drake package
# run 'Rscript make.R -h' for usage.

# packages
library(optparse)

optList <- list(
	make_option(c("-o", "--outdir"), action = "store", 
							default = "./results",
							help = "Directory for knitted output"),
	make_option(c("-f", "--format"), action = "store", default = "html",
							help = "Format for knitted results - currently only HTML is supported"),
	make_option(c("-u", "--update"), action = "store_true", default = F,
							help = "Updae case counts only"),
	make_option(c("-c", "--clean"), action = "store_true", default = F,
							help = "Remove previously downloaded inputs and results")
)

opt <- parse_args(OptionParser(option_list = optList))



# load additional packages
library(drake)
library(here)
library(covidPlots)
library(optparse)
library(dplyr)

# functions
# resultFile: generate output file based on input
resultFile <- function(rmdFile, resDir, resType) {
	# convert directory to relative path
	resDir <- normalizePath(resDir, winslash = "/")
	
	newbase <- sub("\\.[A-Za-z]+$", "", basename(rmdFile))
	
	newbase <- paste(newbase, resType, sep = ".")
	
	resPath <- paste(resDir, newbase, sep = "/")
	
	return(resPath)
}


# clean or update
if(opt$clean) {
	# clean removes all cached files
	clean()
} else {
	if(opt$update) {
		clean(list = c("stateData", "countyData"))
	}
}

# define analysis workflow
plan <- drake_plan(
	stateData  = getUsStateCases(popData = readd(statePopulations)),
									 
	countyData = getUsCountyCases(popData = readd(countyPopulations)),
	
	countyPopulations = getUsCountyPopulation(),
	
	statePopulations = getUsStatePopulation(),
	
	usMap = getUsMap(),

	rmarkdown::render(
		knitr_in("./us_covid_rates.Rmd"),
		output_file = file_out(!! resultFile("us_covid_rates.Rmd", 
																				 opt$outdir, opt$format)),
		envir = new.env(),
		quiet = TRUE
	)
	
)

# get graph of workflow
workGraph <- vis_drake_graph(plan)

workGraph

# run
make(plan, lock_envir = F) # disabling lock_env is a 'bad thing'.  Need to debug
