all:
	./mkpicindex.sh > index.html
clean:
	rm -rf index.html style.css justify.js LICENSE
