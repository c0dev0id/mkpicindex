#!/bin/sh

printf '%s' \
'/*!
 * mkpicindex.sh - v0.1
 * https://codevoid.de
 * Copyright (c) 2019 Stefan Hagen
 * Licensed under the ISC license.
 */
' > LICENSE

# CONFIGURE
GALLERY_TITLE="My Gallery" # browser title
GALLERY_WIDTH=1000         # how wide will the gallery be
GALLERY_ROW_HEIGHT=150     # how high will the justified rows be?
GALLERY_RANDOMIZE=false     # enable random sorting (true,false)
BODY_STYLE="color:orange; background:black;" # <body style="?">
THUMBNAIL_QUALITY=83       # quality for thumbnails
THUMBNAIL_PATH="thm"       # relative path to thumbnail folder
INCLUDE_HEADER="HEADER"    # file with html to include before gallery
INCLUDE_FOOTER="FOOTER"    # file with html to include after gallery

### ZE PROGAM STARTZ HERE ##############################################
cleanup() {
    # DELETE BROKEN IMAGES
    printf '%s\n' "Removing incomplete thumbnails." >&2
    find $THUMBNAIL_PATH -name "*_tmp.*" -exec rm -v "{}" \;
    exit 1
}
trap cleanup 1 2 3 6

# CREATE THUMBNAIL DIRECTORY
mkdir -p $THUMBNAIL_PATH

# INCLUDE CUSTOM HEADER & FOOTER
FOOTER=$([ -f $INCLUDE_FOOTER ] && cat $INCLUDE_FOOTER | sed 's/^/        /g')
HEADER=$([ -f $INCLUDE_HEADER ] && cat $INCLUDE_HEADER | sed 's/^/        /g')

# PRINT HEADER
printf '%s%s%s%s%s\n' \
"<html>
    <head>
        <title>$GALLERY_TITLE</title>
        <meta name=\"viewport\" content=\"width=device-width\">
    </head>
    <body style=\"$BODY_STYLE\">
$HEADER"


# take one image
  # resize to $ROW_HEIGHT
    # check if width exceeds $GALLERY_WIDTH
      # if not: take next picture
        # resize to $ROW_HEIGHT
          # check if first picture width + second picture width exceeds $GALLERY_WIDTH
      # if yes: 



# $1 - Width
# $2 - Height
# <  - Ratio (f)
get_aspect_ratio() {
    W=$1 # Width
    H=$2 # Height
    printf '%f' "$(printf "$FILE_WH" | awk -vTH=$TARGET_H '{ printf("%f", TH*($2/$1)) }')"
}

# CALCULATE ASPECT RATIO WITH FOR TARGET ROW HEIGHT
# $1 - path to image
# $2 - target row height
# ret - calculated width for target height
get_width() {
    local FILE="$1";
    local TARGET_H="$2";
    local FILE_WH="$(identify -format ' %w %h ' "$FILE" | awk '{ print $1" "$2 }')"
    printf '%.0f' "$(printf "$FILE_WH" | awk -vTH=$TARGET_H '{ printf("%f", TH*($2/$1)) }')"
}

get_streched_height() {
    printf "$GALLERY_HEIGHT $CURRENT_ROW_WIDTH $GALLERY_WIDTH" \
        | awk '{ printf("%f", ($2/$1)*$3) }'
}

# ADD NEXT IMAGE AND DECIDE
# $1 - path to image
CURRENT_ROW_WIDTH=0
CURRENT_ROW_FILES=""
add_image() {
    local FILE=$1
    local NEXT_W=$(get_width "$FILE" "$GALLERY_ROW_HEIGHT")
    # when the next item with is too much for the current row..
    if [ $(( $CURRENT_ROW_WIDTH + $NEXT_W )) > $GALLERY_WIDTH ];
        # build gallery

        # calculate aspect ratio of row_height and all items
        # calculate target image height with gallery_width
        get_streched_height;
        # loop at images and resize to streched height
        # resize items
        # output souce

        # set leftover file as for next iteration
        CURRENT_ROW_WIDTH="$NEXT_W"
        CURRENT_ROW_FILES="|$FILE"
    else
        # add more items...
        CURRENT_ROW_WIDTH=$(( $CURRENT_ROW_WIDTH + $NEXT_W ))
        CURRENT_ROW_FILES="$CURRENT_ROW_FILES|$FILE"
    fi


}



for file in *.*;
do
    if [ -f "$file" ];
    then
        case $(printf '%s' ${file##*.} | tr '[:upper:]' '[:lower:]') in
            jpg|jpeg|png) 



            *) printf '%s\n' "Ignoring: $file" >&2 ;;
        esac
    fi
done






## RESCALE AND ADD IMAGE
## PARAM 1: original
##       2: thumbnail_basename
##       3: thumbnail_format (extension)
#add_image() {
#    local FILE="$1"
#    get_width "$1" 300
#    local THUMB="$THUMBNAIL_PATH/$2-$GALLERY_ROW_HEIGHT"
#    local EXT="$3"
#    printf '%s\n' "Adding image: $FILE" >&2
#    if ! [ -f "$THUMB.$EXT" ] && [ "$FILE" != "$THUMB.$EXT" ];
#        then convert -quality $THUMBNAIL_QUALITY -sharpen 2x2 \
#                     -coalesce -resize 6000x$GALLERY_ROW_HEIGHT\> \
#                     -deconstruct "$FILE" "${THUMB}_tmp.$EXT" && \
#        mv "${THUMB}_tmp.$EXT" "$THUMB.$EXT"
#    fi
#    local WH="$(identify -format ' %w %h ' "$THUMB.$EXT" \
#                | awk '{ print "width="$1" height="$2 }')"
#    printf '            %s\n' "<a href=\"$FILE\">"
#    printf '                %s\n' "<img $WH src=\"$THUMB.$EXT\">"
#    printf '            %s\n' '</a>'
#}

### MAIN LOOP ##########################################################

#for file in *.*;
#do
#    if [ -f "$file" ];
#    then
#        case $(printf '%s' ${file##*.} | tr '[:upper:]' '[:lower:]') in
#            jpg|jpeg|png) 
#                add_image "$file" "${file%%.*}" "jpeg" ;;
#            gif)
#                add_image "$file" "${file%%.*}" "gif" ;;
#            *) printf '%s\n' "Ignoring: $file" >&2 ;;
#        esac
#    fi
#done

### MAIN LOOP END ######################################################

# PRINT FOOTER
printf '%s%s\n' \
"        </div>
$FOOTER
    </body>
</html>"
