library(RCurl)
library(XML)
library(stringr)
library(RSelenium)
library(tidyverse)
remDr <- rsDriver(verbose = T,
                  remoteServerAddr = "localhost",
                  port = 4443L,
                  browser=c("firefox"))
rm <- remDr$client


#register
rm$navigate("https://meine.zeit.de") 



#list storing articles

url_collected <- c()

for(index in seq(1,268)){
  
  article_list_tmp <- paste0("https://www.zeit.de/thema/coronavirus?p=", index)
  rm$navigate(article_list_tmp) 
  page <- unlist(rm$getPageSource())
  tpage <- htmlParse(page)
  results <- xpathSApply(tpage, "//section/article", xmlAttrs)
  urls_tmp <- as.vector(list.unzip(results)$`data-unique-id`)
  url_collected <- append(url_collected, urls_tmp)
  print(length(urls_tmp))
  
  
}




#close selenium
rm$close()
rm(remDr)
rm(rm)
gc()




articles_data_frame <- data.frame()
 
for(index in seq(1,length(url_collected))){

  
if(!grepl("video", url_collected[index])){  

try(page <- xmlParse(url_collected[index]))
xml_data <- xmlToList(page)



keywords <- as.vector(list.unzip(xml_data$head$rankedTags)$text)
headline <-   xml_data$head$image$.attrs[3]
publication_date <- xml_data$head$image$.attrs[4]





article_data_frame <-  as.data.frame(t(keywords))
article_data_frame$headline <- headline
article_data_frame$date <-   publication_date
article_data_frame$url <- url_collected[index]

articles_data_frame <- dplyr::bind_rows(articles_data_frame, article_data_frame) 
print(nrow(articles_data_frame))
}

}