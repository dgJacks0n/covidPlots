# Makefile for covid19 visualizations
# This is the master file to update data sets and generate COVID data visualizations

# Define variables used in analysis

# paths
PROJ_DIR=.
CODE_DIR=$(PROJ_DIR)/code
DATA_DIR=$(PROJ_DIR)/data
US_POP_DIR=$(DATA_DIR)/usPopulation2019
RESULT_DIR=$(PROJ_DIR)/results

SUBDIRS= $(DATA_DIR) $(RESULT_DIR) $(US_POP_DIR)

# commands
LINK=ln -s $@ $<

#RENDER='Rscript -e "rmarkdown::render($@)"'

# define aliases

all: data analysis

# subdirs: make sure destination directories are available
$(SUBDIRS):
	mkdir -p $@

# data: download data sets
data: $(SUBDIRS) \
$(DATA_DIR)/usCountyMap.Rds \
$(DATA_DIR)/usCases.Rds \
$(US_POP_DIR)/countyPopulations.Rds \
$(US_POP_DIR)/us-statesPopulations.Rds

# download cases.  Code isn't a pre-req because I want it to update daily
# using logic in getUsCases.R
$(DATA_DIR)/usCases.Rds:
	$(CODE_DIR)/getUsCases.R -o $@

# download mapfile
$(DATA_DIR)/usCountyMap.Rds: $(CODE_DIR)/getUsMap.R
	Rscript $(CODE_DIR)/getUsMap.R -o $@
	
$(US_POP_DIR)/countyPopulations.Rds $(US_POP_DIR)/us-statesPopulations.Rds: \
$(CODE_DIR)/getUsPopulation.R
	Rscript $(CODE_DIR)/getUsPopulation.R -o $(@D)

# analysis: run analyses
analysis: $(RESULT_DIR)/us_covid_rates.html \
$(RESULT_DIR)/world_covid_rates.html


$(RESULT_DIR)/us_covid_rates.html: $(PROJ_DIR)/us_covid_rates.Rmd \
$(DATA_DIR)/usCases.Rds $(DATA_DIR)/usCountyMap.Rds \
$(US_POP_DIR)/countyPopulations.Rds $(US_POP_DIR)/us-statesPopulations.Rds
	Rscript -e "rmarkdown::render('$(PROJ_DIR)/us_covid_rates.Rmd', output_dir = '$(RESULT_DIR)', intermediates_dir = '$(RESULT_DIR)', knit_root_dir = '$(PROJ_DIR)', envir = new.env())" 

$(RESULT_DIR)/world_covid_rates.html: $(PROJ_DIR)/world_covid_rates.Rmd 
	Rscript -e "rmarkdown::render('$(PROJ_DIR)/world_covid_rates.Rmd', output_dir = '$(RESULT_DIR)', intermediates_dir = '$(RESULT_DIR)', knit_root_dir = '$(PROJ_DIR)', envir = new.env())" 


.PHONY: all data analysis # clean
