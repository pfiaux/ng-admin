.PHONY: build

install:
	npm install

run: examples/blog/build
	cp node_modules/fakerest/dist/FakeRest.min.js examples/blog/build/fakerest.js
	cp node_modules/sinon/pkg/sinon-server-1.14.1.js examples/blog/build/sinon-server.js
	./node_modules/webpack-dev-server/bin/webpack-dev-server.js --colors --inline --hot --devtool cheap-module-inline-source-map --content-base examples/blog --port 8000

examples/blog/build:
	mkdir examples/blog/build

transpile:
	mkdir -p lib/
	rm -rf lib/*
	./node_modules/.bin/babel src/javascripts -d lib/javascripts --source-maps > /dev/null
	cd src && rsync -R `find . -name *.html` ../lib # copy all HTML files keeping structure from src to lib
	cp -Rf ./src/sass/ lib/

build:
	make transpile
	NODE_ENV=production ./node_modules/webpack/bin/webpack.js -p --optimize-minimize --optimize-occurence-order --optimize-dedupe --progress --devtool --source-map
	cp -Rf build examples/blog/
	@echo "Files build/ng-admin.min.css and build/ng-admin.min.js updated (with minification)"

test: test-unit test-e2e

test-unit:
	./node_modules/.bin/karma start src/javascripts/test/karma.conf.js --single-run

test-e2e: prepare-test-e2e
	./node_modules/.bin/protractor src/javascripts/test/protractor.conf.js

prepare-test-e2e:
	@echo "Preparing files for e2e tests"
	NODE_ENV=test ./node_modules/webpack/bin/webpack.js -p --optimize-minimize --optimize-occurence-order --optimize-dedupe
	cp examples/blog/*.js src/javascripts/test/fixtures/examples/blog
	cp examples/blog/*.html src/javascripts/test/fixtures/examples/blog
	sed -i.bak 's|http://localhost:8000/|/|g' src/javascripts/test/fixtures/examples/blog/index.html
	cp node_modules/fakerest/dist/FakeRest.min.js src/javascripts/test/fixtures/examples/blog/build/fakerest.js
	cp node_modules/sinon/pkg/sinon-server-1.14.1.js src/javascripts/test/fixtures/examples/blog/build/sinon-server.js

publish: build
	npm publish
