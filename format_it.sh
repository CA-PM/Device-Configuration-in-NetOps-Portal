#!/bin/bash

#######################################################################
#
# This script will take input from the watch_it.sh script,
# format the file by prepending and appending html,
# and moving it to the directory specified in the browser view of PC.
#
#######################################################################
#
# Author: Brian Jackson, Broadcom (brian.jackson@broadcom.com)
#
#######################################################################

# Setup variables for explict paths

prepend_file="/opt/ca/spectrum/NCM_Exports/format/prepend_html"
append_file="/opt/ca/spectrum/NCM_Exports/format/append_html"
config_dir="/opt/ca/spectrum/NCM_Exports"

# Take input from watcher script (router config file name)
input_file=$1

# Grab device name from NCM Export filename - this is used in the browser view
# to automatically determine the correct router config to use

device_name=`echo $input_file | awk -F _ '{print $1}'`
final_file="index."$device_name".html"

# Format by prepending and appending HTML to the router config

cat $prepend_file $config_dir/$input_file $append_file > $final_file

# Move the file to the directory the browser view expects

mv $final_file $config_dir/ 

# Clean up

rm $config_dir/$input_file

exit 0
