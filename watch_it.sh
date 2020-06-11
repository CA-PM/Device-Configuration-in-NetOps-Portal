#!/bin/bash

#######################################################################
#
# This script will watch a directory for new files
# When new files appear, it will call a script to format the files
# and move them to where the browser view expects them
#
#######################################################################
#
# Author: Brian Jackson, Broadcom (brian.jackson@broadcom.com)
#
#######################################################################

# Setup variables for explicit paths. Change as neccessary.

watch_dir=/opt/ca/spectrum/NCM_Exports
backup_dir=/opt/ca/spectrum/NCM_Exports/backup/
bin_dir=/opt/ca/spectrum/NCM_Exports/bin

# Main loop to watch for files

while : ; do
	inotifywait -e create $watch_dir|while read path action file; do
		echo "found file: $file"
		echo

		echo "copying $file to $backup_dir"
		cp $watch_dir/$file $backup_dir

		echo "running command: $bin_dir/format_it.sh $file"
		$bin_dir/format_it.sh $file

	done
done

exit 0
