#!make

default: build

.PHONY: build install

build:
	@./scripts/build.sh && echo "\n\n\n\nRun 'source ~/.bashrc' to re-evaluate the completions"

install: build
	@./scripts/install.sh && echo "\n\n\n\nRun 'source ~/.bashrc' to complete the install"
