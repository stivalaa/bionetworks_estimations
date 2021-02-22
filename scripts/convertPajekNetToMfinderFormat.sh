#!/bin/sh
#
# File:    convertPajekNetToMfinderFormat.sh
# Author:  Alex Stivala
# Created: December 2020
#
# Convert Pajek .net format for directed network to Mfinder 
# (https://www.weizmann.ac.il/mcb/UriAlon/download/network-motif-software)
# format:
# 3 columns: first to are soure and dest nodes (respectively),
# intergers from 1..N; 3rd is edge weight (unused always 1)
#
# Input is on stdin
# Output is to stdout
#

sed -n '/^[*][Aa]rcs/,$p' | fgrep -iv arcs | awk '{print $1, $2, 1}'
