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
		z = eData[[myEvent]],
		colorscale = "Viridis",
		hoverinfo = "text",
		text = paste(eData$state, "-",
								 eData$county, "<br>",
								 myEventPretty, (1e05 * signif(eData[[myEvent]], 3)), "per 100k"),
		marker = list(line = list(
			width = 0),
			opacity = 0.5
		)
	)
	
	
	p_caseMap <- p_caseMap %>% plotly::layout(
		mapbox = list(
			style = "carto-positron",
			zoom  = 2,
			center = list(lon =  -95.71, lat = 37.09)),
		title = paste("Map of US", myEventPretty)
	)
	
	# title attribute works but tick labels don't
	p_caseMap <- p_caseMap %>% 
		plotly::colorbar(
			title = myEventPretty
			# tickmode = "array",
			# tickvalues = seq(min_caserate, max_caserate, by = 1),
			# ticktext = 10^seq(min_caserate, max_caserate, by = 1)
		)
	
	return(p_caseMap)
}