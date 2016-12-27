#!/bin/bash

# Reads image files (.JPG and .PNG) in the current directory and
# copy them under new directory with new EXIF information.
# Datestamp is extracted from file name ( IMG_20150223_WA001.jpg ).
# If no time can be extracted from name, th default time is 00:00:00
# Optionally, latitude and longitude coordinates can be added from 
# command line.
#
# This script does not modify or delete original files.
#

BASE_NAME="IMG"
TIME_START="00:00:00"
OUTPUT_DIR="output"
SEPARATOR="_"
GPS_LATITUDE=""
GPS_LONGITUDE=""
regex="[0-9]{6}" # Regular expresion to match time in format HHMMSS

function printusage {
    echo "whatssfix 1.0"
    echo " "
    echo "Usage: whatssfix [options]"
    echo "Options:"
    echo "    -lat Specify latitude"
    echo "    -lon Specify longitude"
    echo "    -h   Display usage"
    exit 1
}

function checkexiftool {
    if ! (hash exiftool 2>/dev/null); then
        echo "exiftool not found. Please install before use this script."
        exit 1
    fi
}

function copyfiles {
    # Check if OUTPUT_DIR exists
    if ! [ -d "$OUTPUT_DIR" ]; then
        mkdir "$OUTPUT_DIR"
    fi;

    # Copy all image files in current directory to OUTPUT_DIR
    # and changes "-" to "_" in the file name
    for file in *
    do
        if [ "${file##*.}" == "jpg" ] || [ "${file##*.}" == "png"  ]
    	then
            cp "$file" "$OUTPUT_DIR"/
            mv "$OUTPUT_DIR/$file" "$OUTPUT_DIR"/"${file//-/_}" > /dev/null
    	fi
    done
}

function updateexif {
    for file in $OUTPUT_DIR/*
    do
    	if [ "${file##*.}" == "jpg" ] || [ "${file##*.}" == "png"  ]
    	then
            # Creates an array with file name using "_" as separator
            IFS='_' read -a array <<< ${file}
            #FILE_NAME="${array[0]}"
            FILE_DATE="${array[1]}"
            TIME_START="${array[2]}"

            # Format date and GPS values
            DATE=${FILE_DATE:0:4}:${FILE_DATE:4:2}:${FILE_DATE:6:2}
            TIME=${TIME_START:0:2}:${TIME_START:2:2}:${TIME_START:4:2}

            if [[ $TIME_START =~ $regex ]]
            then
                TIME=$TIME
            else
                TIME=00:00:00
            fi

            if [[ $GPS_LATITUDE > 0 ]]
            then
                GPSLatitudeRef=N
            else
                GPSLatitudeRef=S
            fi

            if [[ $GPS_LONGITUDE > 0 ]]
            then
                GPSLongitudeRef=E
            else
                GPSLongitudeRef=W
            fi

            GPS="-GPSLongitudeRef=$GPSLongitudeRef  -GPSLatitudeRef=$GPSLatitudeRef -GPSLatitude=$GPS_LATITUDE -GPSLongitude=$GPS_LONGITUDE"

            # Overwrite all date EXIF tags in the file
            exiftool -overwrite_original ${file} "-datetimeoriginal=${DATE} ${TIME}" $GPS
        fi
    done
}

function main {
    checkexiftool
    copyfiles
    updateexif
}

# Read script options
while (( $# )); do
    if   [ $1 = "-h" ];  then printusage; shift
    elif [ $1 = "-lat" ]; then GPS_LATITUDE=$2; shift
    elif [ $1 = "-lon" ]; then GPS_LONGITUDE=$2; shift
    fi; shift
done

main
