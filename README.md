# Exif-fix
Writes exif tags (date, time and coordinates) to an image file.

This bash script reads all image files (JPG and PNG) in the current directory
and copy them under new directory with new EXIF information.

Datestamp is extracted from file name ( IMG_20150223_WA001.jpg ). 
If no time can be extracted from file name, th default time is 00:00:00.
Optionally, latitude and longitude coordinates can be added from 
command line.

This script does not modify or delete original files.
