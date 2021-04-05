#' Return event data filtered by state or county
#' Filtering is done by matching on a vector of values
#' 
#' 
#' @param eData event data
#' @param values one or more values to filter
#' @param level level to filter
#' @param pretty format column names and values
#' @param sigFigs number of sigfigs to show in data (only applys if pretty==T)
#' 
#' @note For county level data either fips code  or county name are supported
#' but must be specified to match query.  Fips code is recommended as county
#' name may not be unique.
#' 
#' @return Filtered data frame
#' 
#' @export

filterEventData <- function(eData, values = NA, level = c("state", "county", "fips"),
														pretty = T, sigFigs = 3) {
	
	filtCol <- match.arg(level)
	
	stopifnot(filtCol %in% colnames(eData))
	
	fData <- dplyr::filter_at(eData, filtCol, dplyr::all_vars(. %in% values))
	
	if(nrow(fData)< 1) { warning("No rows matched filter criteria")}
		
	fData <- select(fData, date, contains(c(filtCol, "deaths", "cases")))
	
	if(pretty) {
		fData <- dplyr::rename_all(fData, 
															 function(cn){ 
															 	stringr::str_to_title(gsub("_", " ", cn))}
															 )
		
		fData <- dplyr::mutate_if(fData, is.numeric, signif, sigFigs)
	}
	

	
	return(fData)
}

