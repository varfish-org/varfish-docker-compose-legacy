SHELL:=bash

.PHONY: default
default: help

.PHONY: help
help:
	@echo available targest
	@echo
	@echo "    push     -- push branch and tags"
	@echo "    release  -- make a Github release"

	@echo

.PHONY: push
push:
	git push origin
	git push origin --tags

.PHONY: release
release: push
	TAG=$$(git 	describe); \
	if [[ $$? -ne 0 ]] || [[ "$$TAG" = *-* ]]; then \
		>&2 echo "ERROR: not at a clean release; stopping"; \
		exit 1; \
	fi; \
	gh release create $$TAG
