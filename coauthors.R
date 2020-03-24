################################################################
# This script is intended to pull in the data that Ryan processed
# and generate some networks and/or maps from those data.
################################################################

load("data/pubmed_articles.Rda")
load("data/pubmed_authors.Rda")

# First, let's strip out everything that can't plausibly be about this particular outbreak
pma <- author_pm_long[which(author_pm_long$year>2019 | (author_pm_long$year==2019 & author_pm_long$month==12)),]
nauth <- length(unique(pma$fullname))

# Let's build a network
# We have not done any major name disambiguation. If anything that would lead to additional segmentation, *away* from the main account we're making. So I think we're on safe ground here.
library(igraph)
m <- table(pma$pmid, pma$fullname)
g <- graph.incidence(m)


auth_num <- as.data.frame(table(pma$fullname))

# Creating the author projection
t <- t(m) %*% m
ag <- graph_from_adjacency_matrix(t, mode="undirected")
V(ag)$size <- auth_num$Freq

###################################################################
# Clustering and plotting the authors graph (here we're using the 2 biggest clusters)
aclust <- clusters(ag)
csize <- table(table(aclust$membership))

alcc <- induced.subgraph(ag, V(ag)[which(aclust$membership == which.max(aclust$csize))])
alcc <- simplify(alcc) # removing multiple edges & loops
ascc <- induced.subgraph(ag, V(ag)[which(aclust$membership == which(aclust$csize==564))])
ascc <- simplify(ascc) # removing multiple edges & loops
ttcc <- union(alcc, ascc)

# Running community detection
cebc <- cluster_edge_betweenness(alcc)
cebc2 <- cluster_edge_betweenness(ttcc)
mem <- cutat(cebc,2) 
mem2 <- cutat(cebc2, 3)
gcc <- data.frame(fullname=V(alcc)$name, mem=mem)

# Optimizing the layout a little
minC <- rep(-Inf, vcount(alcc))
maxC <- rep(Inf, vcount(alcc))
minC[1] <- maxC[1] <- 0
set.seed(2019)
co <- layout_with_fr(alcc, minx=minC, maxx=maxC,
                     miny=minC, maxy=maxC, niter=3000)  
colrs <- c("skyblue2", "gold", "tomato")

V(alcc)$size
V(ascc)$size

par(mfrow=c(1,2), mar=c(0,0,0,0))
plot.igraph(alcc, layout=co,  vertex.label=NA, vertex.color=colrs[mem], edge.color="gray85")
plot.igraph(ascc,  layout=layout.fruchterman.reingold, vertex.label=NA, vertex.color="tomato", edge.color="gray85")


membs <- data.frame(fullname=V(ag)$name, comm=aclust$membership)
membs$comm3<- 0 #collapsing all of the components <100 into one group
membs$comm3[which(membs$fullname %in% V(alcc)$name[which(gcc$mem==1)])] <- 1 #first community in largest component
membs$comm3[which(membs$fullname %in% V(alcc)$name[which(gcc$mem==2)])] <- 2 #first community in largest component
membs$comm3[which(membs$fullname %in% V(ascc)$name)] <- 3 #second largest component

# all(V(ag)$name==membs$fullname) # double checking nodes are still in the same order
V(ag)$comm <- membs$comm3
saveRDS(ag, file="data/collab_net.Rds")
#save(membs, file="data/comm_membs.rda" )

###################################################################
# Some alternative graph approaches that we aren't currently using.
# # Would we want an article projection too?
# t1 <- m %*% t(m)
# pg <- graph_from_adjacency_matrix(t1, mode="undirected")
# 
# # Attaching some attributes
# V(g)$type <- bipartite.mapping(g)$type
# V(g)$shape <- "circle"
# V(g)$shape[which(V(g)$type==F)] <- "square"

# Stripping off just the giant component for the bipartite graph
#   gclust <- clusters(g)
#   lcc <- induced.subgraph(g, V(g)[which(gclust$membership == which.max(gclust$csize))])
#   
#   plot.igraph(lcc, vertex.size=2, layout=layout.fruchterman.reingold, vertex.label=NA)
#   
# # And how about for the paper graph
#   pclust <- clusters(pg)
#   plcc <- induced.subgraph(pg, V(pg)[which(pclust$membership == which.max(pclust$csize))])
#   plot.igraph(simplify(plcc), vertex.size=2, layout=layout.fruchterman.reingold, vertex.label=NA)
#   