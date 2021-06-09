#!/usr/bin/Rscript

# make.R
# master script for use with drake package
# run 'make.R -h' for usage.

# packages
library(optparse)
library(drake)
library(here)
library(dplyr)


optList <- list(
	make_option(c("-o", "--outdir"), action = "store", 
							default = paste(here(), "results", sep = "/"),
							help = "Directory for knitted output"),
	make_option(c("-f", "--format"), action = "store", default = "html",
							help = "Format for knitted results - currently only HTML is supported.  May be overridden by specific RMD files."),
	make_option(c("-l", "--logfile"), action = "store", 
							default = paste(here(), "results", "make.log", sep = "/"),
							help = "Logfile for make; set to 'none' to suppress logging"),
	make_option(c("-u", "--update"), action = "store_true", default = F,
							help = "Updae case counts only"),
	make_option(c("-c", "--clean"), action = "store_true", default = F,
							help = "Remove previously downloaded inputs and results")
)

opt <- parse_args(OptionParser(option_list = optList))

# install covid plots if not already done
if(!require(covidPlots)) {
	install.packages(paste(here(), "lib", "covidPlots_0.0.0.9000.tar.gz", sep = "/"), 
									 type = "source", repos = NULL)
}
library(covidPlots)

# functions
# resultFile: generate output file based on input
resultFile <- function(rmdFile, resDir, resType) {
	# convert directory to relative path
	resDir <- normalizePath(resDir, winslash = "/", mustWork = F)
	
	newbase <- sub("\\.[A-Za-z]+$", "", basename(rmdFile))
	
	newbase <- paste(newbase, resType, sep = ".")
	
	resPath <- paste(resDir, newbase, sep = "/")
	
	return(resPath)
}

# do we need to suppress logfile?
logfile <- ifelse(opt$logfile == "none", NULL, opt$logfile)

# clean or update
if(opt$clean) {
	# clean removes all cached files
	clean()
} else {
	if(opt$update) {
		# update only removes case counts
		drake::clean(list = c("stateData", "countyData"))
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
		knitr_in(paste(here(), "code", "us_covid_rates.Rmd", sep = "/")),
		output_file = file_out(!! resultFile("us_covid_rates.Rmd", 
																				 opt$outdir, opt$format)),
		envir = new.env(),
		quiet = TRUE
	),
	
	rmarkdown::render(
		knitr_in(paste(here(), "code", "usCovidSlides.Rmd", sep = "/")),
		output_file = file_out(!! resultFile("usCovidSlides.Rmd",
																				 opt$outdir, "pptx")),
		envir = new.env(),
		quiet = TRUE
	)
	
)

# get graph of workflow
workGraph <- vis_drake_graph(plan)

workGraph

# run
drake::make(plan, envir = new.env(), log_make = logfile) 
