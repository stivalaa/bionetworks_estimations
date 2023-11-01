#!/bin/sh
#
# File:    renameLologDirectedEffects.sh
# Author:  Alex Stivala
# Created: November 2023
#
# Rename directed LOLOG effects for better LaTeX table presentation.
#
# Input is stdin, output is stdout.
#
# Usage: renameLologDirectedEffects.sh < infile > outfile
#

if [ $# -ne 0 ]; then
    echo "Usage: $0 < in > out" >&2
    exit 1
fi

sed 's/edges/Edges/g;s/out-gwdegree[.]\([0-9.]*\)/GW out-degree ($\\alpha = \1$)/g;s/in-gwdegree[.]\([0-9.]*\)/GW in-degree ($\\alpha = \1$)/g;s/mutual/Reciprocity/g;s/nodematch[.]\(.*\)/Nodematch \1/g;s/0[.]693147180559945/0.693/g;s/nodecov[.]\(.*\)/Nodecov \1/g;s/twoPath/Two-paths/g;s/triangles/Triangles/g'
