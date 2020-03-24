#This makes a map

library(dplyr)
library(tidyr)
library(reshape2)
library(tmap)

load("data/pubmed_articles.Rda")
load("data/pubmed_authors.Rda")

# First, let's strip out everything that can't plausibly be about this particular outbreak
pma <- author_pm_long[which(author_pm_long$year>2019 | (author_pm_long$year==2019 & author_pm_long$month==12)),]
npap <- length(unique(pma$pmid))
nauth <- length(unique(pma$fullname))

auth1 <- pma %>% filter(whichauth=="au1")

auth1$lwrd <- sub('.*\\,', '', auth1$address)

pm_country <- auth1 %>% select(pmid, address, lwrd)

pm_country$lwrd <- trimws(pm_country$lwrd, which = "both") 

pm_country_smoosh <- as.data.frame(table(pm_country$lwrd))

#spit this out to edit by hand

#write.csv(pm_country_smoosh,"country_hand.csv", row.names = FALSE)

library(readr)
country_hand <- read_csv("country_hand.csv")

mcountry.df <- left_join(pm_country, country_hand)

clean_country_freq <- as.data.frame(table(mcountry.df$name))

clean_country_freq <-rename(clean_country_freq, name=Var1, artnum=Freq)

# make map

data("World")

World <- left_join(World, clean_country_freq)

art_map <- tm_shape(World) +
  tm_polygons("artnum", title = "Number of Articles", 
          breaks=c(1, 5, 10, 50, 100, 200, 600),
          palette = "Blues",
          textNA = "0 articles",
          colorNA = "white")

#tmap_save(art_map, "figs/artmap_fin.pdf")