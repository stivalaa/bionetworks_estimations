#!/usr/bin/env python
##############################################################################
#
# convertEdgeListBinAttrToSMNetFormat.py - edgelist+binary attr to SMNet format
#
#
# File:    convertEdgeListBinAttrToSMNetFormat.py
# Author:  Alex Stivala
# Created: Feburary 2017
#
##############################################################################

"""
Convert (newer version) PNet edgelist network and binary attributes to
and write in format for SMNet estimation with binary node attributes.

NB convertMatrixBinAttrToSMNetFormat.R also does this (can read network in
matrix or edgelist format) but cannot be used on Piz Daint as R no longer
works there after upgrade so have to use Python scripts instead.

Usage:
    converEdgeListBinAttrToSMNetFormat.py edgelistfile binattrfile
    
 Output files are (WARNING: overwritten in cwd):

    sampledesc.txt		- referred to in setting.txt, names other files
    edgelist.txt          - edge list Pajek format
    zones.txt            - snowball sample zones (all 0 full network)
    actors.txt           - node attributes
   

"""

import sys
import getopt

#-----------------------------------------------------------------------------
#
# Functions
#
#-----------------------------------------------------------------------------

def write_subactors_file_with_attr(filename, binattr):
    """
    Write subactors file in SMNet format (also parallel SPNet)

    Parameters:
       filename - filename to write (warning: overwritten)
       binattr - list of binary attribute values

    See documetnation of this file in snowball.c readSubactorsFile()
    (format written by showActorsFile()).
 
    TODO specific to binattr data, make this a reusable function
    """
    num_bin_attr = 1
    num_cont_attr = 0
    num_cat_attr = 0
    n = len(binattr)
    f = open(filename, 'w')
    f.write("* Actors %d\n" % n)
    f.write("* Number of Binary Attributes = %d\n" % num_bin_attr)
    f.write("* Number of Continuous Attributes = %d\n" % num_cont_attr)
    f.write("* Number of Categorical Attributes = %d\n" % num_cat_attr)
    f.write("Binary Attributes:\n")
    f.write("id binaryAttribute\n")
    for i in xrange(n):
        f.write("%d %d\n" %( i+1, binattr[i]))
    f.write("Continuous Attributes:\n")
    f.write("id\n")
    for i in xrange(n):
        f.write("%d\n" %( i+1))
    f.write("Categorical Attributes:\n")
    f.write("id\n")
    for i in xrange(n):
        f.write("%d\n" %( i+1))
    f.close()


def write_zone_file(filename, zones):
    """
    write_zone_file() -write zone file in parallel spnet (Pajek .clu) file format
    
    Parameters:
      filename - filename to write to (warning: overwritten)
      zones  - vector of snowball zones (waves) 0..n (0 for seed node)
      elemetn i of the vector corresponds to node i of graph (1..N)

    Return value:
      None.
    """
    f = open(filename, 'w')
    f.write("*vertices %d\n" % len(zones))
    f.write('\n'.join([str(z) for z in zones]))
    f.close()
    
#-----------------------------------------------------------------------------
#
# main
#
#-----------------------------------------------------------------------------

def usage(progname):
    """
    print usage msg and exit
    """
    sys.stderr.write("usage: " + progname + " edgelistfile binattrfile\n")
    sys.exit(1)

def main():
    """
    See usage message in module header block
    """
    
    try:
        opts,args = getopt.getopt(sys.argv[1:], "")
    except:
        usage(sys.argv[0])
    for opt,arg in opts:
        usage(sys.argv[0])

    if len(args) != 2:
        usage(sys.argv[0])

    edgelistfile = args[0]
    binattrfile = args[1]

    edgelist = open(edgelistfile).read()
    binattrs = open(binattrfile).read().splitlines()[1:] # skip header
    binattrs = [int(x) for x in binattrs]
    
    n = int(edgelist.splitlines()[0].split()[1])
    print edgelistfile, "vertices:", n
    assert(n == len(binattrs))

    open("sampledesc.txt","w").write("%d zones.txt edgelist.txt actors.txt\n" % n)
    write_zone_file("zones.txt", n*[0])
    edgelist = edgelist.splitlines()
    f = open("edgelist.txt","w")
    for i in xrange(len(edgelist)):
        if (len(edgelist[i]) < 1):  # end at first blank line
            break
        f.write(edgelist[i]+'\n')
    write_subactors_file_with_attr("actors.txt", binattrs)

    
if __name__ == "__main__":
    main()


