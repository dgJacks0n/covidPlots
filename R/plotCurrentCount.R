#' Plot current cases by state
#' 
#' @param pData data frame with current cumulative cases and deaths by state
#' @param xCol column to use for x axis
#' @param value column in pData with plot values
#' @param usePlotly make plot interactive using plotly?
#' @param hGroup grouping name for interactive plot
#' 
#' @return ggplot or plotly plot of
#' 
#' @export

plotCurrentCount <- function(pData, xCol = c("state", "county"),
													 value = c("cases", "cases_per_capita", "deaths", "deaths_per_capita"),
													 usePlotly = T, hGroup = as.character(NA)) {
	# get x axis column
	pGroup <- match.arg(xCol)
	
	# remove missing values and reorder state by value
	valCol <- match.arg(value)
	
	pData <- dplyr::filter_at(pData, dplyr::vars(valCol), 
														dplyr::all_vars(!is.na(.)))
	
	pData[[pGroup]] <- forcats::fct_reorder(pData[[pGroup]], pData[[valCol]], .desc = F)
	
	# set highlight key for interactive plots
	#if(usePlotly) {
		if(!is.na(hGroup)) {
			pData <- plotly::highlight_key(as.formula(paste("~", pGroup)), group = hGroup)
		}
	#}
	
	# define plot title and labels
	xLabel <- stringr::str_to_title(gsub("_", " ", pGroup))
	yLabel <- stringr::str_to_title(gsub("_", " ", valCol))
	
	pTitle <- paste(yLabel, "by", xLabel)
	
	sPlot <- ggplot2::ggplot(pData, 
													 ggplot2::aes_(x = as.name(pGroup), 
													 							y = as.name(valCol))) +
		ggplot2::geom_point() +
		ggplot2::scale_y_log10() +
		ggplot2::scale_x_discrete(expand = ggplot2::expansion(add = 1)) +
		ggplot2::labs(title = pTitle,
				 y = yLabel, x = xLabel) +
		ggplot2::theme(axis.text.x = ggplot2::element_blank(),
					axis.ticks.x = ggplot2::element_blank(),
					panel.grid.minor.x = ggplot2::element_blank(),
					panel.grid.major.x = ggplot2::element_blank())
	
	# if a static plot is needed we're done
	if(!usePlotly) { return(sPlot) }
	
	iPlot <- plotly::ggplotly(sPlot) %>%
		plotly::hide_guides() %>%
		plotly::highlight(dynamic = T, selectize = T, persistent = F,
							on = "plotly_click",
							defaultValues = highlightState)
	
	return(iPlot)
}