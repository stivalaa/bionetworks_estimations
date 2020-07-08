#!/usr/bin/Rscript
#
# File:    plotSMNetDegreeDistribution.R
# Author:  Alex Stivala
# Created: November 2016
#
# Plot degree distribution for observed and simulated networks from
# for Max's adapative MCMC algorhtm output DegreeCor? files.
#
#
# Usage: Rscript plotSMNetDegreeDistribution.R 
#
# Output is postscrpt file degree_distribution.eps 
#
library(ggplot2)

outfilename <- 'degree_distribution.eps'

observed <- read.table('DegreeCorr')
simulated <- read.table('DegreeCors')

names(observed)[names(observed) == 'V1'] <- 'degree'
names(observed)[names(observed) == 'V2'] <- 'count'
names(simulated)[names(simulated) == 'V1'] <- 'degree'
names(simulated)[names(simulated) == 'V2'] <- 'count'

D <- data.frame(degree = observed$degree, count = observed$count,
                datasource = 'observed')
D <- rbind(D, data.frame(degree = simulated$degree, count = simulated$count,
                 datasource = 'simulated'))

# eliminate rows for degrees higher than the largest nonzero count
maxdegree <- max(D[which(D$count > 0), 'degree'])
D <- D[which(D$degree <= maxdegree), ]

p <- ggplot(D, aes(x = degree, y = count, linetype = as.factor(datasource),
                                          colour = as.factor(datasource)))
p <- p + geom_point()
p <- p + geom_line()
p <- p + scale_linetype("")
p <- p + scale_colour_discrete("")
  
postscript(outfilename, onefile=FALSE,
           paper="special", horizontal=FALSE, width=9, height=6)
print(p)
dev.off()
