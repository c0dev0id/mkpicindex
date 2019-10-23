
include config.mk

all:
	./mkpicindex.sh > index.html
clean:
	rm -rf ${THUMBNAIL_PATH} index.html style.css justify.js
