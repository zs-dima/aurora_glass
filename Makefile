SHELL := /bin/bash -e -o pipefail

.DEFAULT_GOAL := all
.PHONY: all
all: format check test ## format, check, test

.PHONY: help
help: ## list targets
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-16s\033[0m %s\n", $$1, $$2}'

.PHONY: get
get: ## resolve dependencies
	@flutter pub get

.PHONY: format
format: ## format sources
	@dart format .

.PHONY: fix
fix: ## apply analyzer fixes
	@dart fix --apply

.PHONY: analyze
analyze: get ## format check and analyzer, infos and warnings fatal
	@git ls-files '*.dart' | grep -vE '\.(g|freezed|gen)\.dart$$' | xargs -r dart format --set-exit-if-changed -o none
	@flutter analyze --fatal-infos --fatal-warnings

.PHONY: dcm
dcm: ## DCM with the lints_tool rule set
	@dcm analyze .

.PHONY: test
test: get ## run the tests
	@flutter test
	@cd example && flutter test

.PHONY: publish-check
publish-check: ## pub.dev dry run
	@flutter pub publish --dry-run

.PHONY: check
check: analyze publish-check ## everything CI runs except the tests

.PHONY: outdated
outdated: get ## outdated dependencies
	@flutter pub outdated

.PHONY: publish
publish: check test ## publish to pub.dev
	@flutter pub publish

.PHONY: clean
clean: ## remove build output
	@rm -rf .dart_tool build coverage reports

.PHONY: gallery
gallery: ## run the gallery app
	@cd example && flutter run

.PHONY: tokens
tokens: ## regenerate the shared tokens and the gallery palette from the design workspace
	@dart run bin/gen_tokens.dart --design-root $(DESIGN)
	@cd example && dart run aurora_glass:gen_brand --design-root ../$(DESIGN) --app-json tool/gallery.json --out lib/gallery_tokens.g.dart

.PHONY: tokens-check
tokens-check: ## fail when a committed generated file is stale
	@dart run bin/gen_tokens.dart --check --design-root $(DESIGN)
	@cd example && dart run aurora_glass:gen_brand --check --design-root ../$(DESIGN) --app-json tool/gallery.json --out lib/gallery_tokens.g.dart

DESIGN ?= ../../../app/design/tokens
