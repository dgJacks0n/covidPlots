#' Download Mapbox file for US counties to support US chlorpleth maps
#' 
#' @param mapUrl URL for US county map indexed by FIPS codes
#' 
#' @return mapData annotated with attributes 'source' (mapUrl) and 'timestamp' (download time)
#' 
#' @export

getUsMap <- function(mapUrl = 
										 	'https://raw.githubusercontent.com/plotly/datasets/master/geojson-counties-fips.json') {

	countyMapData<- rjson::fromJSON(file = mapUrl)
	
	# tag with info on date and time of download 
	attr(countyMapData, "source") <- mapUrl
	
	attr(countyMapData, "timestamp") <- Sys.time()
	
	return(countyMapData)
}


