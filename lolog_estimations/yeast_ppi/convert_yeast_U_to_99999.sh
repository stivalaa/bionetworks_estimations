#!/bin/sh
#
# convert_yeast_U_to_99999.sh - convert categorical attribute value 13
# encoding "U" (uncharacterized) to 99999 the value used for NA in the SMNet
# code.
#
# Need to do it this way as, as of March 2017, the igraph Nexus graph
# repository seems to have disappeared so can no longer get data and use
# scripts such as getYeastEdgeListWithNodeAttr.R etc.
# Fortunately had the foresight to save all the output of those scripts
# (see  getYeastEdgeListWithNodeAttr.out) so from that file can read
# that "U" is encoded as 13, so change 13 to 99999 in the attributes file.
#
# Alex Stivala
# March 2017
#

cat yeast_actors.txt | sed 's/^\([0-9]*\) 13/\1 99999/' > yeast_actors_with_NA.txt
