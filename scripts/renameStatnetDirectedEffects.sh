#!/bin/sh
#
# File:    renameStatnetDirectedEffects.sh
# Author:  Alex Stivala
# Created: August 2019
#
# Rename directed statnet effects for better LaTeX table presentation.
#
# Input is stdin, output is stdout.
#
# Usage: renameStatnetDirectedEffects.sh < infile > outfile
#

if [ $# -ne 0 ]; then
    echo "Usage: $0 < in > out" >&2
    exit 1
fi

sed 's/edges/Edges/g;s/gwesp[.]OTP[.]fixed[.]\([0-9.]*\)/GWESP OTP ($\\alpha = \1$)/g;s/gwdsp[.]OTP[.]fixed[.]\([0-9.]*\)/GWDSP OTP ($\\alpha = \1$)/g;s/absdiff[.]\([a-z]*\)/Heterophily \1/g;s/gwodeg[.]fixed[.]\([0-9.]*\)/GW out-degree ($\\alpha = \1$)/g;s/gwideg[.]fixed[.]\([0-9.]*\)/GW in-degree ($\\alpha = \1$)/g;s/mutual/Reciprocity/g;s/nodematch[.]\(.*\)/Nodematch \1/g;s/0[.]693147180559945/0.693/g'

