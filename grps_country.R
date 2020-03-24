#This checks groups for countries

library(dplyr)
library(tidyr)
library(reshape2)

load("data/pubmed_articles.Rda")
load("data/pubmed_authors.Rda")
load("data/comm_membs.Rda")


# First, let's strip out everything that can't plausibly be about this particular outbreak
pma <- author_pm_long[which(author_pm_long$year>2019 | (author_pm_long$year==2019 & author_pm_long$month==12)),]
npap <- length(unique(pma$pmid))
nauth <- length(unique(pma$fullname))
auth1 <- pma %>% filter(whichauth=="au1")

auth1$lwrd <- sub('.*\\,', '', auth1$address)

pm_country <- auth1 %>% select(pmid, address, lwrd)

pm_country$lwrd <- trimws(pm_country$lwrd, which = "both") 


library(readr)
country_hand <- read_csv("country_hand.csv")

mcountry.df <- left_join(pm_country, country_hand)

pma_mem <- left_join(membs, pma)

mem_cntry <- left_join(pma_mem, mcountry.df)

mem_cntry <- mem_cntry %>% select(comm3, name)

mem_cntry <- mem_cntry %>% drop_na(name)

#note some authors are double counted here.

cntry_cnt <- mem_cntry %>% group_by(comm3) %>% count(name)

cntry_cnt <- arrange(cntry_cnt, comm3, desc(n)) 

cntry_top<- cntry_cnt %>% filter(n>4)


#save the top countries file
save(cntry_top, file="data/top_countries_grp.Rda")


