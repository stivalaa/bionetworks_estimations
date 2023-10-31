#!/bin/sh
#
# convert_yeast_U_to_simple_attribute_file9.sh - convert categorical attribute
# in SMNet format to simple list of attribute values for easy use in R
#
# Need to do it this way as, as of March 2017, the igraph Nexus graph
# repository seems to have disappeared so can no longer get data and use
# scripts such as getYeastEdgeListWithNodeAttr.R etc.
# Fortunately had the foresight to save all the output of those scripts
# (see  getYeastEdgeListWithNodeAttr.out) so from that file can read
# that "U" is encoded as 13, so change 13 to NA in the attributes file.
#
# Alex Stivala
# June 2021
#

cat yeast_actors.txt |  sed -n  '/^Categorical Attributes:$/,$p'| tail -n+2 | sed 's/^\([0-9]*\) 13/\1 NA/' > yeast_class_attribute.txt
