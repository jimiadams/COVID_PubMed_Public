library(easyPubMed)
my.query <- "\"SARS-COV-2\" 
      OR \"covid-19\" 
      OR \"COVID-19\" 
      OR \"novel corona virus\" 
      OR \"novel coronavirus\"
      OR \"severe acute respiratory syndrome coronavirus 2\"
      OR \"2019-nCoV\"
      OR \"COVID19 virus\"
      OR \"Wuhan coronavirus\"
      OR \"coronavirus disease 2019 virus\"
      OR \"Wuhan seafood market pneumonia virus\"
      OR \"2019 novel coronavirus\"
      OR \"SARS2"
my.idlist <- get_pubmed_ids(my.query)
my.idlist$Count

# I'm not convinced the novel corona virus terms are going to uniquely capture things post 2019, and I'm not getting the delimiter to constrain by date to work properly. So, we'll want to clean this up below.

# This grabs pubmed as text files
pm_text <- batch_pubmed_download(pubmed_query_string = my.query,
                               dest_file_prefix = "COVID_PM_",
                               encoding = "ASCII")


# Then we can read them by author ... note that the abstract is only being read up to
#1024 characters. This is annoying but perhaps OK for something that is obviously expedited.
#There is still a lot of data if we wanted to work with words.

# Too lazy to write a function...feel free to make nicer

new_PM_file <- pm_text[[1]]

new_PM_df <- table_articles_byAuth(pubmed_data = new_PM_file, 
                                   included_authors = "all", 
                                   max_chars = 10000,
                                   autofill=TRUE,
                                   getKeywords=TRUE,
                                   encoding = "UTF-8")


new_PM_file2 <- pm_text[[2]]

new_PM_df2 <- table_articles_byAuth(pubmed_data = new_PM_file2, 
                                   included_authors = "all", 
                                   max_chars = 10000,
                                   autofill=TRUE,
                                   getKeywords=TRUE,
                                   encoding = "UTF-8")


new_PM_file3 <- pm_text[[3]]

new_PM_df3 <- table_articles_byAuth(pubmed_data = new_PM_file3, 
                                   included_authors = "all", 
                                   max_chars = 10000,
                                   autofill=TRUE,
                                   getKeywords=TRUE,
                                   encoding = "UTF-8")


new_PM_file4 <- pm_text[[4]]

new_PM_df4 <- table_articles_byAuth(pubmed_data = new_PM_file4, 
                                   included_authors = "all", 
                                   max_chars = 10000,
                                   autofill=TRUE,
                                   getKeywords=TRUE,
                                   encoding = "UTF-8")


library(dplyr)
library(reshape2)

author_pm_long <- bind_rows(new_PM_df, new_PM_df2, new_PM_df3, new_PM_df4)

author_pm_long <- author_pm_long %>% unite(fullname, lastname:firstname, sep=".", remove=FALSE)

author_pm_long <- author_pm_long %>% group_by(pmid) %>% mutate(nauth=seq_along(pmid))

author_pm_long$whichauth <-  sub("^", "au", author_pm_long$nauth )

author_pm_long$whichauth <- as.factor(author_pm_long$whichauth ) 

article_df <- dcast(author_pm_long, pmid ~ whichauth, value.var="fullname")

library(gtools)

article_df <- article_df[mixedorder(colnames(article_df))]

art_dat <- author_pm_long[match(unique(author_pm_long$pmid), author_pm_long$pmid),]

article_df <- left_join(article_df, art_dat)

#save the article file
#save(article_df, file="data/pubmed_articles.Rda")

#save the long file
#save(author_pm_long, file="data/pubmed_authors.Rda")

######After this isn't used####################################################################################################


library(bibliometrix)

cov.D <- readFiles("COVID_PM_01.txt","COVID_PM_02.txt","COVID_PM_03.txt", "COVID_PM_04.txt") 

cov.D

my_PM_list <- article_to_df(pubmed_data = cov.D)

M <- convert2df(cov.D, dbsource="pubmed")

#######################################################
# This version grabs them "on the fly"
batch.size <- 1000
my.seq <- seq(1, as.numeric(my.idlist$Count), by = batch.size)
pm_xml <- lapply(my.seq, (function(ret.start){
  batch.xml <- fetch_pubmed_data(my.idlist, retstart = ret.start, retmax = batch.size, encoding="ASCII")
}))

#######################################################
