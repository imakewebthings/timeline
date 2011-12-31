build:
	coffee --compile --output lib/ src/

test:
	make build
	./node_modules/.bin/mocha --reporter spec

.PHONY: build test