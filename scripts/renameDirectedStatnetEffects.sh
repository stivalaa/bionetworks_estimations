#!/bin/sh
#
# File:    renameDirectedStatnetEffects.sh
# Author:  Alex Stivala
# Created: August 2019
#
# Rename the effects in LaTeX table generated from statnet output by
# statnetEstimation2textableMultiModels.sh, so that
# gwdsp.fixed.0.2 becomes GWDSP (\alpha = 0.2) etc.
#
# Input is stdin, output is stdout.
#
# Usage: renameEffectsStatnetGreysAnatomy.sh < infile > outfile
#

if [ $# -ne 0 ]; then
    echo "Usage: $0 < in > out" >&2
    exit 1
fi

sed 's/edges/Edges/g;s/[.]decay/ decay/g;s/gwesp.fixed.\([0-9.]*\)/GWESP ($\\alpha = \1$)/g;s/gwdsp.fixed.\([0-9.]*\)/GWDSP ($\\alpha = \1$)/g;s/absdiff[.]\([a-z]*\)/Heterophily \1/g;s/gwidegree/GW out-degree/g;s/gwodegree/GW in-degree/g;s/[.]alpha/ $\\alpha$/g;s/gwesp/GWESP/g;s/class/Class/g;s/mutual/Reciprocity/g'

