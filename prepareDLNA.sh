#!/bin/bash
# Author : Nacos
# License : do what the fuck you want with it

# Depends on ffmpeg and subliminal(https://pypi.python.org/pypi/subliminal/)

# My TV has a shitty implementation of DLNA and cannot handle .srt subtitle located next to my episodes
# For each file matching *.mp4, I execute the following steps :
# First, I try to download the right subtitle using subliminal if I don't have it
# Then I use ffmpeg to "merge" the video file and the softsub into a single mkv file

# Subtitle should still be a softsub (it's not "burned" into the video file"), so be sure your media player is capable is reading it

# usage : ./prepareDLNA.sh /path/to/series/folder


# Script below
# Bear with me, code is far from being perfect

sublang="en"
orig_extension=".mp4"
target_extension=".mkv"
sub_extension=".srt"

echo "** Target $1*$orig_extension"

for file in `ls $1/*$orig_extension`
do
	#echo $file
	filepath="${file%/*}/"
	filename=$(basename "$file")
	extension="${filename##*.}"
	filename="${filename%.*}"
	fichiervideo=$filename$orig_extension
	fichiersub=$filepath$filename"."$sublang$sub_extension
	fichiertarget=$filepath$filename$target_extension
	#echo $filename " " $fichiervideo " " $fichiersub " " $fichiertarget
	
	echo "** Episode $filename"
	
	echo -n " * Original video file                             "
	if [ -e $file ]
	then
		echo -e "\e[1m\e[32m[  OK  ]\e[0m"
	else
		echo -e "\e[1m\e[31m[  KO  ]\e[0m"
		continue
	fi
	
	echo -n " * Subtitle file                                   "
	if [ -e $fichiersub ]
	then
		echo -e "\e[1m\e[32m[  OK  ]\e[0m"
	else
		echo -ne "\e[1m\e[31m[  KO  ]\e[0m\r"
		sleep 1
		echo -n " * Subtitle file                                   "
		echo -ne "\e[1m\e[33m[  DL  ]\e[0m\r"
		subliminal -l $sublang -- $file 1> /dev/null 2> /dev/stdout
		sleep 1
		EXIT_CODE=$?
		if [ $EXIT_CODE -ne 0 ]
		then
			echo -n " * Subtitle file                                   "
			echo -ne "\e[1m\e[31m[  KO  ]\e[0m\r"
			continue
		else
			echo -n " * Subtitle file                                   "
			echo -ne "\e[1m\e[32m[  OK  ]\e[0m\r"
		fi
		
		if [ -e $fichiersub ]
		then
			echo -n " * Subtitle file                                   "
			echo -ne "\e[1m\e[32m[  OK  ]\e[0m\n"
		else
			echo -n " * Subtitle file                                   "
			echo -ne "\e[1m\e[31m[  KO  ]\e[0m\n"
		fi
	fi
	
	echo -n " * Merging $orig_extension and $sub_extension to $target_extension file              "
	ffmpeg -i $file -i $fichiersub -c:s srt -c:v copy -c:a copy $fichiertarget 1>/dev/null 2>/dev/stdout
	EXIT_CODE=$?
	if [ $EXIT_CODE -ne 0 ]
	then
		echo -e "\e[1m\e[31m[  KO  ]\e[0m"
		continue
	else
		echo -e "\e[1m\e[32m[  OK  ]\e[0m"
	fi
done
