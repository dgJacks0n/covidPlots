#' map current cases or deaths per capita in US
#' 
#' @param eData event data from getLastCountyData
#' @param event 
#' @param map us map from getUsMap
#' 
#' @export

plotUsMap <- function(eData, event = c("cases_per_capita", "deaths_per_capita"), map = getUsMap()) {
	myEvent <- match.arg(event)
	
	myEventPretty <- stringr::str_to_title(gsub("_", " ", myEvent))
	
	# exclude cases with NA events per capita
	eData <- eData[!is.na(eData[[myEvent]]), ]
	
	p_caseMap <- plotly::plot_ly() 
	
	p_caseMap <- p_caseMap %>% plotly::add_trace(
		type= "choroplethmapbox",
		geojson = map,
		locations = eData$fips,
		z = log10(eData[[myEvent]]),
		colorscale = "Viridis",
		hoverinfo = "text",
		text = paste(eData$state, "-",
								 eData$county, "<br>",
								 myEventPretty, (1e05 * signif(eData[[myEvent]], 3)), "per 100k"),
		marker = list( opacity = 0.5)
	)
	
	
	p_caseMap <- p_caseMap %>% plotly::layout(
		mapbox = list(
			style = "carto-positron",
			zoom  = 2,
			center = list(lon =  -95.71, lat = 37.09)),
		title = paste("Map of US", myEventPretty)
	)
	
	# title attribute works but tick labels don't
	vRange <- round(range(log10(eData[[myEvent]])))
	vRangeSeq <- seq(vRange[1], vRange[2], by = 1)
	
	p_caseMap <- p_caseMap %>% 
		plotly::colorbar(
			title = paste("log10", myEventPretty),
			tickmode = "array",
			tickvalues = vRangeSeq,
			ticktext = 10^vRangeSeq
		)
	
	return(p_caseMap)
}