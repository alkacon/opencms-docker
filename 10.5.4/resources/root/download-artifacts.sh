#!/bin/bash

mkdir -p /artifacts

while read line || [[ -n "$line" ]]; do
	if [[ $line == "#"* ]]; then
		echo "Skipping comment."
	else
		line=( ${line//,/ } )
		echo "."
		if [ ${#line[@]} == 2 ]; then
			target="${line[0]}"
			source="$(echo ${line[1]} | envsubst)"
			if [ -f "$target" ]; then
				echo "Using local file directly from the context."
			else
				echo "Downloading using curl"
				echo "   from: \"$source\""
				echo "     to: \"$target\""                    
				curl --show-error "$source" --create-dirs --fail -o "$target"
			fi
			if [ ! -f "$target" ]; then
				# File was not downloaded 
				echo "ERROR: Unable to download ${target}"
				echo "."
				exit 1 
			fi
		else
			echo "WARNING: Wrong format. Use TARGET , SOURCE. Skipping line \"$line\"."
		fi
	fi
done < $1