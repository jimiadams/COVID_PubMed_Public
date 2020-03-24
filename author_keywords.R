#This checks keywords for groups

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

pma_kw <- pma %>% drop_na(keywords)

pma_kw <- pma_kw %>% group_by(fullname) %>% mutate(nkw=seq_along(fullname))

pma_kw$whichkw <-  sub("^", "kw", pma_kw$nkw)

kw_df <- dcast(pma_kw, fullname ~ whichkw, value.var="keywords")

kw_df <- kw_df %>% unite(keyfull, matches("^kw"), sep=";", na.rm=TRUE, remove=FALSE)

#let's get rid of words

mesh_list <- c("SARS-COV-2", "covid-19" , "COVID-19" , "novel corona virus", 
"novel coronavirus" , "severe acute respiratory syndrome coronavirus 2" , "2019-nCoV",
"COVID19 virus" , "Wuhan coronavirus", "coronavirus disease 2019 virus",
"Wuhan seafood market pneumonia virus" , "2019 novel coronavirus", "SARS2")

mesh_list <- tolower(mesh_list)

library("tm")

kw_df$keyfull <- tolower(kw_df$keyfull)

kw_df$keyfull <- removeWords(kw_df$keyfull, mesh_list)

library(splitstackshape)

au_kw <- cSplit(kw_df, "keyfull", ";")

#merge with author by groups file

membs <- rename(membs, groups=comm3)

amerge <- left_join(membs, au_kw)

amerge <- amerge %>% select(groups, starts_with("keyfull"))

along <- amerge %>% gather(keyword, gwrds, `keyfull_01`:`keyfull_36`)

along <- along %>% drop_na(gwrds)

along <- along %>% select(groups, gwrds)

library("stringr")

along$cv <- str_count(along$gwrds, "coronavirus")

along <- along %>% filter(cv==0)

along <- along %>% na_if("") %>% drop_na(gwrds)

kw_count <- along %>% group_by(groups) %>% count(gwrds)

kw_count <- arrange(kw_count, groups, desc(n)) 

kw_top<- kw_count %>% filter(n>19)

#save the top keywords file
#save(kw_top, file="data/top_keywords.Rda")


#####BELOW NOT USED################################

#generate list of authors on multiple papers


au.freq <- as.data.frame(table(pma$fullname))
au.freq <- mutate(au.freq, auid = rownames(au.freq))
au.freq <- rename(au.freq, fullname = Var1)



pma <- left_join(pma, au.freq)

multi <- pma %>% filter(Freq>1)

write.csv(multi, file="multi_auth.csv")