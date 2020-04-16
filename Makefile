# Makefile for covid19 visualizations
# This is the master file to update data sets and generate COVID data visualizations

# Define variables used in analysis

# paths
PROJ_DIR=.
CODE_DIR=$(PROJ_DIR)/code
DATA_DIR=$(PROJ_DIR)/data
US_DATA_DIR=$(DATA_DIR)/nyt_us
US_POP_DIR=$(DATA_DIR)/usPopulation2019
RESULT_DIR=$(PROJ_DIR)/results

SUBDIRS= $(DATA_DIR) $(RESULT_DIR) $(US_DATA_DIR) $(US_POP_DIR)

# commands
LINK=ln -s $@ $<

RENDER='Rscript -e "rmarkdown::render($@)"'

# define aliases

all: data # analysis

# subdirs: make sure destination directories are available
$(SUBDIRS):
	mkdir -p $@

.PHONY: all data #analysis clean

# data: download data sets
data: $(SUBDIRS) \
$(DATA_DIR)/usCountyMap.Rds \
$(US_POP_DIR)/countyPopulations.Rds \
$(US_POP_DIR)/us-statesPopulations.Rds
# $(US_DATA_DIR)/us-counties.csv \
# $(US_DATA_DIR)/us-states.csv

# download mapfile
$(DATA_DIR)/usCountyMap.Rds: $(CODE_DIR)/getUsMap.R
	Rscript $(CODE_DIR)/getUsMap.R -o $@
	
$(US_POP_DIR)/countyPopulations.Rds $(US_POP_DIR)/us-statesPopulations.Rds: \
$(CODE_DIR)/getUsPopulation.R
	Rscript $(CODE_DIR)/getUsPopulation.R -o $(@D)


