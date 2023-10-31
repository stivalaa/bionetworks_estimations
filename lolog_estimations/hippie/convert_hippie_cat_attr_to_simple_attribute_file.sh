#!/bin/sh
#
# convert_hippie_cat_attr_to_simple_attribute_file.sh - convert categorical attribute
# in SMNet format to simple list of attribute values for easy use in R
#
#

cat hippie_ppi_high_actors_NA99999.txt |  sed -n  '/^Categorical Attributes:$/,$p'| tail -n+2  > hippie_ppi_high_cellular_component_attribute.txt


