all:
	./mkpicindex.sh > index.html.tmp && mv index.html.tmp index.html
clean:
	rm -rf index.html.tmp index.html style.css justify.js LICENSE
