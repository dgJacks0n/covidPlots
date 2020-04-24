#' Plot current cases by state
#' 
#' @param pData data frame with current cumulative cases and deaths by state
#' @param xCol column to use for x axis
#' @param value column in pData with plot values
#' @param usePlotly make plot interactive using plotly?
#' @param hKey column for interactive data grouping
#' @param hGroupName grouping name for interactive plot
#' 
#' @return ggplot or plotly plot of current total cases
#' 
#' @export

plotCurrentCount <- function(pData, xCol = c("state", "county"),
													 value = c("cases", "cases_per_capita", "deaths", "deaths_per_capita"),
													 usePlotly = T, hKey = NA, hGroupName = NA) {
	# get x axis column
	pGroup <- match.arg(xCol)
	
	# remove missing values and reorder state by value
	valCol <- match.arg(value)
	
	pData <- dplyr::filter_at(pData, dplyr::vars(valCol), 
														dplyr::all_vars(!is.na(.)))
	
	pData[[pGroup]] <- forcats::fct_reorder(pData[[pGroup]], pData[[valCol]], .desc = F)
	
	# set highlight key for interactive plots
	if(usePlotly) {
		# group by level unless specified otherwise
		hKey <- ifelse(!is.na(hKey), hKey, pGroup)
		
		if(!(hKey %in% colnames(pData))) {
			stop("Highlight key ", hKey, " is not a column in the plot data")
		}
		
		# define group name if not provided
		hGroupName <- ifelse(!is.na(hGroupName), hGroupName, hKey)
		
		pData <- pData %>% plotly::highlight_key(key = hKey, group = hGroupName)
		
	}
	
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
	
	iPlot <- plotly::ggplotly(sPlot) 
	
	return(iPlot)
}