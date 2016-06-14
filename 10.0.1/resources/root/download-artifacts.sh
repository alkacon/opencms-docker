#!/bin/bash

while read line || [[ -n "$line" ]]; do
	if [[ $line == "#"* ]]; then
		echo "Skipping comment."
	else
		line=( ${line//,/ } )
		echo "${#line[@]}"
		if [ ${#line[@]} == 2 ]; then
			target=${line[0]}
			source=${line[1]}
			if [ -f "$target" ]; then
				echo "Using local file directly from the context."
			else
				echo "Downloading from \"$source\" to \"$target\"."
				curl --show-error "$source" --create-dirs -o "$target"
			fi
		else
			echo "WARNING: Wrong format. Use TARGET , SOURCE. Skipping line \"$line\"."
		fi
	fi
done < $1