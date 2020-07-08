#!/usr/bin/Rscript
#
# File:    plotSMNetParametersSingleExample.R
# Author:  Alex Stivala
# Created: November 2016
#
# Plot parmaeter values vs iteration (precomputing and then computing)
# for Max's adapative MCMC algorhtm output PD? files.
# This version just plots a single one of the runs
# for use as example (and therefore does not require
# alpha channel [transparency] and so can use EPS and not PDF.
#
#
# Usage: Rscript plotSMNetParametersSingleExample.R 
#
# Output is EPS file parameters_single.eps
#
library(grid)
library(gridExtra)
library(ggplot2)
library(reshape)
library(doBy)

# http://stackoverflow.com/questions/10762287/how-can-i-format-axis-labels-with-exponents-with-ggplot2-and-scales
orig_scientific_10 <- function(x) {
  parse(text=gsub("e", " %*% 10^", scientific_format()(x)))
}

scientific_10 <- function(x) {
# also remove + and leading 0 in exponennt
  parse( text=gsub("e", " %*% 10^", gsub("e[+]0", "e", (x))) )
   
}



#
# label function for ggplot2 labeller
#
label_function <- function(variable, value) {
    sapply(value, FUN = function(xval) 
        if (xval == 'K-Triangle(2.00)') {
          "AT"
        } else if  (xval == 'K-star(2.00)') {
          "AS"
        }  else {
          levels(xval)[xval]
        }
    )
}


outfilename <- 'parameters_single.eps'

PD <- NULL
for (pdfile in Sys.glob("PD[0-9]*")) {
  run <- as.integer(sub("PD([0-9]+)", "\\1", pdfile))
  PDrun <- read.table(pdfile)
  PDrun$run <- run
  PD <- rbind(PD, PDrun)
}
userun <- 0 # use only run 0
PD <- PD[which(PD$run == userun),]

PDnames <- read.table('PD_names', stringsAsFactors=FALSE)
names(PD) <- c(PDnames, "run")
PD$run <- as.factor(PD$run)
idvars <- c('run', 'Iteration')
paramnames <- names(PD)[which(!(names(PD) %in% idvars))]
PD$AcceptanceRate <- NULL # remove acceptance rate column


# TODO this is specific to LIVMO output, should parse this from the
# job output file e.g. for LIVMO USI/Max_code/LIVMO/slurm-43994.out:
# iterationInStep 313000.000000
iterationInStep = 313000.000000 / 1000

PD$Iteration <- PD$Iteration * iterationInStep

PD <- melt(PD, id=idvars)
p <- ggplot(PD, aes(x=Iteration, y=value))

p <- p + theme_bw(base_size = 14)
p <- p + theme(panel.background = element_blank(),
           panel.grid.major = element_blank(),
           panel.grid.minor = element_blank(),
           plot.background = element_blank(),
           strip.background = element_blank(),
           panel.border = element_rect(color = 'black'),
           legend.key = element_blank(),
           legend.position = "none")
p <- p + theme(legend.title = element_blank())

p <- p + facet_grid(variable ~ ., labeller = label_function,
                    scales="free_y")

p <- p + geom_point(shape='.')
p <- p + xlab(expression('Iteration,'~t))
p <- p + ylab('Parameter value'~theta(t))
p <- p + scale_x_continuous(label = scientific_10,
                            limits = c(0,4e+06)#FIXME specific to LIVMO example
                            )


postscript(outfilename, onefile=FALSE, horizontal=FALSE,
           paper="special", width=9, height=6)
print(p)
dev.off()

