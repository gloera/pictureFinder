#!/bin/bash

counter=0

usage() { echo "Usage: $0 [-s search path ] [ -d destination path ]  <-w <min width>> <-h <min height> <-m search by model>" 1>&2; exit 1; }

while getopts ":s:d:mw::h::" o; do
    case "${o}" in
        s)
            SEARCHPATH=${OPTARG}
            ;;
        d)
            IMAGEPATH=${OPTARG}
            ;;
        w)
            WIDTH=${OPTARG}
            ;;
        h)
            HEIGHT=${OPTARG}
            ;;
        m)
            MODELSEARCH=1
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

if [ -z "${SEARCHPATH}" ] || [ -z "${IMAGEPATH}" ]; then
    usage
fi

TMP=`find $SEARCHPATH -type f -print 2> /dev/null | egrep -i "\.(jpg|png|gif)$"`
if [ $? -eq 0 ] ; then
   echo "${TMP}" | while read x
   do
      if [ ! -z "${MODELSEARCH}" ] && [ $MODELSEARCH -eq 1 ] ; then
         FILETYPE=`identify -format '%[EXIF:MODEL]' "${x}" 2> /dev/null`
         if [ $? -eq 0 ] && [ ! -z "${FILETYPE// }" ]  ; then
            mv "${x}"  $IMAGEPATH
            ((counter++))
            printf "."
         fi
      else 
         if [ ! -z "${WIDTH}" ] && [ ! -z "${HEIGHT}" ]; then
            FILETYPE=`identify -format "%w %h" "${x}" 2> /dev/null`
	    if [ $? -eq 0 ] && [ ! -z "${FILETYPE// }" ]  ; then
	       x_width=`echo $FILETYPE | awk '{print $1}'`
	       x_height=`echo $FILETYPE | awk '{print $2}'`
	       if [ $x_width -ge $WIDTH ] && [ $x_height -ge $HEIGHT ] ; then
	          mv "${x}"  $IMAGEPATH
		  (( counter++ ))
		  printf "."
	       fi
            fi
	 fi
      fi
   done 
else
   echo "NOTHING FOUND"
fi
echo "DONE"
echo "Moved $counter files"

