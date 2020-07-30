#!/bin/sh
#
# File:    renameEffects.sh
# Author:  Alex Stivala
# Created: March 2014
#
# Rename the effects in LaTeX table to shorter form used in manuscript
#
# Input is stdin, output is stdout.
#
# Usage: renameEffects.sh < infile > outfile
#

if [ $# -ne 0 ]; then
    echo "Usage: $0 < in > out" >&2
    exit 1
fi

sed 's/A2P-T(2.00)/A2P/g;s/AKT-T(2.00)/AT/g;s/K-Star(2.00)/AS/g;s/R\\_Attribute1/$\\rho$/g;s/Rb\\_Attribute1/$\\rho_B$/g;s/Differences of Continuous Attribute1/Difference/g;s/Same Category Edge Attribute1/Match/g;s/R_Attribute1/$\\rho$/g;s/Rb_Attribute1/$\\rho_B$/g;s/edge/Edge ($\\theta_L$)/g;s/\bas\b/AS/g;s/\bat\b/AT/g;s/a2p/A2P/g;s/binaryAttribute_interaction/$\\rho_B$/g;s/binaryAttribute_activity/$\\rho$/g;s/SameCategory_\([A-Za-z0-9]*\)/Match \1/g;s/Rb_\([A-Za-z0-9.]*\)/\1 Interaction/g;s/R_\([A-Za-z0-9.]*\)/\1 Activity/g;s/DifferentCategory_\([A-Za-z0-9]*\)/Mismatch \1/g'

