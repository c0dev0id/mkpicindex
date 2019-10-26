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
TITLE="My Gallery"          # browser title
WIDTH=1000                  # how wide will the gallery be
ROW_HEIGHT=150              # how high will the justified rows be?
THUMB_QUALITY=83            # quality for thumbnails
THUMB_PATH="thm"            # relative path to thumbnail folder
THUMB_PADDING="6"           # image padding
DEBUG=$1                    # debug output

# GLOBAL TMP VARIABLES
G_ROW_WIDTH=0               # combined pic width   < WIDTH @ ROW_HEIGHT
G_ROW_FILES=""              # pipe separated files < WIDTH
MORE=1                      # trigger next loop

### ZE PROGAM STARTZ HERE ##############################################
cleanup() {
    # DELETE BROKEN IMAGES
    printf '%s\n' "Removing incomplete thumbnails." >&2
    find "$THUMB_PATH" -name "*_tmp.*" -exec rm -v "{}" \;
    exit 1
}
trap cleanup 1 2 3 6

# CREATE THUMBNAIL DIRECTORY
mkdir -p "$THUMB_PATH"

# OUTPUT HELPER
debug() { [ "$DEBUG" == "1" ] && printf '%s\n' "Debug: $1" >&2; }
console() { printf '%s\n' "$1" >&2; }

# CALCULATORS
get_width_by_height() {
    # returns aspect ratio calculated width
    local F="$1"  # image file
    local TH="$2" # target height
    local WH="$(identify -format ' %w %h ' "$1" | awk '{ printf("%.3f %.3f",$1,$2) }')"
    local R="$(printf "$WH" | awk -vTH=$TH '{ printf("%.0f", TH*($1/$2)) }')"
    printf '%.0f' "$R"
    debug "get_width_by_height: FILE=$F TARGET_HEIGHT=$TH FILE_WxH=$WH RET_WIDTH=$R"
}
get_height_by_width() {
    # returns aspect ratio calculated height
    local F=$1  # image file
    local TW=$2 # target width
    local WH="$(identify -format ' %w %h ' "$1" | awk '{ printf("%.3f %.3f",$1,$2) }')"
    local R="$(printf "$WH" | awk -vTW=$TW '{ printf("%.0f", TW*($2/$1)) }')"
    printf '%.0f' "$R"
    debug "get_height_by_width: FILE=$F TARGET_WIDTH=$TW FILE_WxH=$WH RET_HEIGHT=$R"
}

# CREATE THUMBNAIL
create_thumb() {
    # $F - original
    # $W - width
    # $H - height
    # $R - thumbnailpath
    local F="$1" # original
    local W="$2" # width
    local H="$3" # height
    local T="${F%%.*}-$H"
    if ! [ -f "$THUMB_PATH/$T.gif" ] || [ -f "$THUMB_PATH/$T.jpeg" ];
    then
        case $(printf '%s' "${F##*.}" | tr '[:upper:]' '[:lower:]') in
            gif) console "Creating Thumbnail: $THUMB_PATH/$T.gif"
                 convert -quality $THUMB_QUALITY -sharpen 2x2 \
                         -coalesce -resize 6000x$H\> \
                         -deconstruct "$F" \
                         "$THUMB_PATH/${T}_tmp.gif" && \
                 mv "$THUMB_PATH/${T}_tmp.gif" "$THUMB_PATH/$T.gif"
                printf '%s' "$THUMB_PATH/$T.gif" ;;
            *)   convert -quality $THUMB_QUALITY -sharpen 2x2 \
                         -resize 6000x$H\> "$F" \
                         "$THUMB_PATH/${T}_tmp.jpeg" && \
                 mv "$THUMB_PATH/${T}_tmp.jpeg" "$THUMB_PATH/$T.jpeg"
                printf '%s' "$THUMB_PATH/$T.jpeg" ;;
        esac
    fi
}

# ADD IMAGE LOOP
add_image() {
    local F="$1" # image file

    # How wide would the image be when we rescale it to $ROW_HEIGHT?
    local NW=$(get_width_by_height "$F" "$ROW_HEIGHT")
    debug "add_image: FILE=$F NW=${NW}x$ROW_HEIGHT"

    # We add images and their width to $G_ROW_WIDTH until $WIDTH will
    # be exceeded.
    if [ "$(( $G_ROW_WIDTH + $NW ))" -gt "$WIDTH" ]; then

        debug "add_image: max width reached with F=$F @ $G_ROW_WIDTH"

        # we're building a row now
        printf "<div class=\"row\">\n";

        # calculate how much we need to stretch images to fill the
        # whole row.
        local RFH=$(printf "$G_ROW_WIDTH $WIDTH $ROW_HEIGHT" \
            | awk '{ printf("%.0f",$3*($2/$1)) }')
        debug "RFH=$RFH"

        # loop through the images in this row and recalculate
        # them with their new, real height.
        local IFS='|'; for RF in $G_ROW_FILES;
        do
            local RFW=$(($(get_width_by_height "$RF" "$RFH") - 2*$THUMB_PADDING))
            debug "add_image: adding file: F=$RF with W=$RFW H=$RFH"

            local T=$(create_thumb "$RF" "$RFW" "$RFH")
            debug "add_image: created thumbnail $T"

            # output HTML for image
            console "Adding Image: $RF"
            printf '        <div class="image">\n'
            printf '            <a href="'$RF'">\n'
            printf '                <img width="'$RFW'" height="'$RFH'" src="'$T'">'
            printf '            </a>\n'
            printf '        </div>\n'
        done

        # we're done with this row now.
        printf "</div>\n";

        # set leftover file as for next iteration
        G_ROW_WIDTH="$NW"
        G_ROW_FILES="$F|"
    else
        # add more items...
        debug "add_image: width has not been reached, continue loop."
        G_ROW_WIDTH="$(( $G_ROW_WIDTH + $NW ))"
        G_ROW_FILES="$F|$G_ROW_FILES"
    fi
}

# HEADER
printf '%s\n' \
'<html>
    <head>
    <meta name="viewport" content="width=device-width">
    <title>My Gallery</title>
        <style>
        html {
            background: black;
            color: orange;
        }
        .base {
            margin-left: auto;
            margin-right: auto;
            width: min-content;
        }
        .row {
            display: block;
            float: clear;
            width: max-content;
            margin-left: auto;
            margin-right: auto;
            white-space: nowrap;
        }
        .image {
            float: left;
            width: fit-content;
            height: fit-content;
            padding: '"$THUMB_PADDING"';
        }
        </style>
    </head>
    <body>
        <div class="base">
'
### MAIN LOOP ##########################################################
for F in *.*;
do
    if [ -f "$F" ];
    then
        case "$(printf '%s' ${F##*.} | tr '[:upper:]' '[:lower:]')" in
            jpg|jpeg|png|gif) add_image "$F" ;;
            *) console "Ignoring: $F" ;;
        esac
    fi
done
### MAIN LOOP END ######################################################

# FOOTER
printf '%s\n' \
'       </div> 
    </body>
</html>'
