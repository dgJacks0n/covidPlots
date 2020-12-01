#' Plot windowed growth rate in days for cases or deaths by state
#' growth rates are calculated by performing a lm fit on log10(event count) over the window. 
#' Only state level data is supported - counties may not have enough cases
#' 
#' @export

plotDoublingTime <- function(eData = getUsStateCases(), event = c("cases", "deaths"), myWindow = 7,
													 usePlotly = T, hKey = "byState") {
	
	myEvent <- match.arg(event)
	
	# put doubling time in new column
	dt_col <- paste(myEvent, "doubling_rate", sep = "_")
	
	dt_colLabel <- stringr::str_to_title(gsub("_", " ", dt_col))
	
	eData[dt_col] <- eData[myEvent]
	
	# calculate doubling time
	growthRateData <- eData %>%
		dplyr::group_by(state) %>%
		dplyr::arrange(date, .by_group = T) %>%
		dplyr::mutate_at(dt_col, doublingRate, myWindow) %>%
		dplyr::ungroup() %>%
		dplyr::filter_at(dt_col, dplyr::all_vars(!is.na(.)))
	
	if(usePlotly) {
		growthRateData <- growthRateData %>% plotly::highlight_key(~state, group = hKey)
	}
	
	sPlot <- ggplot2::ggplot(growthRateData, 
													 ggplot2::aes_q(x = as.name("date"), y = as.name(dt_col))) +
		ggplot2::geom_line(ggplot2::aes(group = state)) +
		ggplot2::labs(x = "Date", y = "Doublings per Day", 
									title = dt_colLabel, 
									subtitle = paste(myWindow, "Day Window"))
	
	if(!usePlotly) { return(sPlot) }
	
	iPlot <- plotly::ggplotly(sPlot) 
	
	return(iPlot)
}


# doublingRate: calculate growth rate over window
doublingRate <- function(myData, myWindow = 7){
	zoo::rollapply(myData, myWindow, fit_series, fill = NA, align = "right")
}

# fit_series: log transform and lmfit a series of numeric values

fit_series <- function(vals) {
	# calculate grwoth rate within window
	# make sure there's some change
	if(diff(range(vals)) < 2) { return(NA)}
	
	fitdata <- data.frame(index = 1:length(vals),
												values = vals,
												logValues = log(vals, 2)) %>%
		dplyr::filter(values > 0)
	
	# check that we have enough cases and enough growth
	if(nrow(fitdata) < 3) { return(NA) }
	
	# fit log10 values vs index
	myfit <- try( lm(logValues ~ index, fitdata))
	
	if(class(myfit) != "lm") { return(NA) }
	
	# get slope
	logslope <- coef(myfit)["index"]
	
	# since we're in base 2, the doubling time is 1/logslope
	dtime <- 1/logslope
	
	return(unname(logslope))
}
