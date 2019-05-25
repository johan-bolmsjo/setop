INSTALL_ARGS := $(if $(PREFIX),--prefix $(PREFIX),)								       

.PHONY: build
build:
	dune build

.PHONY: install
install:
	dune install $(INSTALL_ARGS)

.PHONY: uninstall
uninstall:
	dune uninstall $(INSTALL_ARGS)

.PHONY: test
test:
	dune runtest

.PHONY: clean
clean:
	rm -rf _build *.install
