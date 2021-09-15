#
# Wrapper for calling NetMODE in R.
#
#
# The theory of network motifs has been subject to some
# criticism.  This extension allows the user to perform their
# own statistical analyses.  It returns all of the subgraph
# counts, so can return a lot of data.
#
#

## Citation for NetMODE is:
##   Li, X., Stones, R. J., Wang, H., Deng, H., Liu, X., & Wang, G. (2012).
##   NetMODE: Network motif detection without nauty. PloS One, 7(12), e50093.
##
## and is available from:
##  https://sourceforge.net/projects/netmode/files/NetMODE%201.04/
##
## fixed bugs (using lowercase g not uppercase G in some checks
## in NetMODE so it only worked if g is in the environment) ADS 13/9/2021.

#
# Updates since the last version:
#
# - igraph indices have changed from {0,1,..,n-1} to {1,2,..,n};
#   this code has changed accordingly
# - code now calls system(..) rather than shell(..) so to be
#   functional on Linux systems.
#
#

#
# There are three steps to take to get this to work:
#
#
# Step 1: Firstly, edit this text file so that the following function
# calls your NetMODE execuatble.  You can include a directory if necessary.
#

##NetMODECommand <- "c:/NetMODE/NetMODE_win_console.exe"
NetMODECommand <- "/home/stivala/NetMODE104/NetMODE"

#
#
# Step 2: Ensure igraph library is installed.
# If not, it is available from: http://igraph.sourceforge.net/
# In the graphical user interface, it can be installed via the menu:
# 
#   Packages/Install package(s)...
#
#
# Step 3: Read this text file in NetMODE, e.g. by:
#
#   source("NetMODER.txt")
#
# or
#
#   source("c:/NetMODE/NetMODER.txt")
#
#

# -------------------------------------------------------------

#
#
# NetMODE can be called using the function: NetMODE(G,k,c,b,e,t)
#
# The required inputs are:
#
# G is the input network (in igraph format)
# k for k-node subgraph census (k=3,4,5,6)
# c is the number of comparison graphs (e.g. 1000)
# b is the burnin number (number of discarded comparison graphs (e.g. 100)
# e is the method used in switching bidirectional edges (e=1,2,3,4)
# t is the number of threads (for multi-core systems)
#
#

# -------------------------------------------------------------

#
# Sample usage:
#
#
# > g <- KavoshToIGraph("c:/NetMODE/networks/ecoli")
# Read 2553 items
# > z <- NetMODE(g,3,10,0,1,1)
# > z
# [[1]]
#  [1]   6  12  14  36  38  46  74  78  98 102 110 238
# 
# [[2]]
#  [1] 196 322 553 167  12   1 536 758   2   3  17  23
# 
# [[3]]
# [[3]][[1]]
#  [1] 1379 1480 1556 1589 1589 1512 1573 1583 1583 1537
#
# [[3]][[2]]
#  [1] 3451 3672 3821 3901 3876 3702 3854 3875 3866 3768
#
# [[3]][[3]]
#  [1] 218 122  54  18  21  91  29  31  30  72
#
# <snip>
#
#

# -------------------------------------------------------------

#
#
# What the data stored in z is:
#
# z[[1]][j] contains the GraphID of the j-th graph in g.
# We can look at this graph with:
#
#
# > GraphIDToGraph(3,z[[1]][2])
# IGRAPH D--- 3 2 --
# > GraphIDToAdjacencyMatrix(3,z[[1]][2])
#      [,1] [,2] [,3]
# [1,]    0    0    0
# [2,]    0    0    1
# [3,]    1    0    0
# > m <- GraphIDToGraph(3,z[[1]][2])
# > plot(m,layout=layout.fruchterman.reingold)
#
#
#
# z[[2]][j] contains the number of copies (up to isomorphism)
# of the j-th graph in g.
#
#
# z[[i]][[j]] contains the number of copies (up to isomorphism)
# of the j-th graph in g in the i-th comparison network.
#
# We can check whether or not the normal approximation is
# appropriate visually via:
#
#
# > z <- NetMODE(g,3,10000,0,3,4)
# > t <- z[[3]][[2]]
# > plot(table(t))
#
#
# Or we could use qqnorm():
#
#
# > qqnorm(t)
#
#
# Or we could perform a normality test:
#
#
# > shapiro.test(t[1:5000])
# 
#         Shapiro-Wilk normality test
# 
# data:  t[1:5000] 
# W = 0.0635, p-value < 2.2e-16
# 
# >
#
#
#

# -------------------------------------------------------------


#
# Note that igraph stores directed and undirected graphs differently
# so these need to be treated separately
#
# Since NetMODE allows multi-core computing, we need to return the
# subgraph counts for each comparison network together as a single
# string, otherwise the cores will return results simultaneously,
# and the inputs will clash.  However, strings returned by
# system(..) calls are truncated at length 8095.  This needs to be
# accounted for.
#

require(igraph)

NetMODE <- function(G,k=3,N=100,b=0,e=3,threads=1) {
  if(!is.igraph(G)) { return(NA) }
  if(k<3 || k>6) { return(k) }
  if(N<0) { return(NA) }
  if(b<0) { return(NA) }
  if(e<0 || e>4) { return(NA) }
  if(threads<1) { return(NA) }

  input_str <- paste(NetMODECommand,"-k",k,"-c",N,"-b",b,"-e",e,"-v 1 -t",threads)
  data_set <- vcount(G)

  if(is.directed(G)) {
    for(i in 1:ecount(G)) {
      edge <- get.edge(G,i)
      data_set <- c(data_set,paste(edge[1],edge[2],sep=" "))
    }
  }
  else {
    for(i in 1:ecount(G)) {
      edge <- get.edge(G,i)
      data_set <- c(data_set,paste(edge[1],edge[2],edge[2],edge[1],sep=" "))
    }
  }

  a <- system(input_str,intern=TRUE,input=data_set)

  i <- 1
  nr_subgraphs <- as.integer(strtrim(a[i],nchar(a[i])-2))

  i <- i + 1
  x <- a[i]
  while(substr(x,nchar(x),nchar(x))!=";") {
    i <- i + 1
    x <- paste(x,a[i],sep="")
  }
  x <- strtrim(x,nchar(x)-2)
  x <- strsplit(x,split=" ")
  x <- unlist(x)
  x <- as.double(x)
  GraphID <- x

  i <- i + 1
  x <- a[i]
  while(substr(x,nchar(x),nchar(x))!=";") {
    i <- i + 1
    x <- paste(x,a[i],sep="")
  }
  x <- strtrim(x,nchar(x)-2)
  x <- strsplit(x,split=" ")
  x <- unlist(x)
  x <- as.integer(x)
  in_count <- x

  out_count <- vector("list", nr_subgraphs)

  if(N>0) { for(t in 1:N) {
    i <- i + 1
    x <- a[i]
    while(substr(x,nchar(x),nchar(x))!=";") {
      i <- i + 1
      x <- paste(x,a[i],sep="")
    }
    x <- strtrim(x,nchar(x)-2)
    x <- strsplit(x,split=" ")
    x <- unlist(x)
    x <- as.integer(x)
    for(j in 1:nr_subgraphs) {
      out_count[[j]][t] <- x[j]
    }
  } }

  return(list(GraphID,in_count,out_count))
}

KavoshToIGraph <- function(filename) {
  a <- scan(filename)
  G <- graph.empty(n=a[1], directed=TRUE)
  for(i in 1:((length(a)-1)/2)) {
    G <- add.edges(G,c(a[2*i],a[2*i+1]))
  }
  return(G)
}

GraphIDToAdjacencyMatrix <- function(k,ID) {
  adj <- array(0, dim=c(k,k))
  i <- 0
  while(ID>0) {
    adj[k-(i %/% k),k-(i %% k)] <- ID %% 2
    ID <- (ID %/% 2)
    i <- i+1
  }
  return(adj)
}

GraphIDToGraph <- function(k,ID) {
  G <- graph.empty(k)
  i <- 0
  while(ID>0) {
    if(ID %% 2==1) { G <- add.edges(G,c(k-(i %/% k),k-(i %% k))) }
    ID <- (ID %/% 2)
    i <- i+1
  }
  return(G)
}
