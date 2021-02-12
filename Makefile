SHELL:=bash

.PHONY: default
default: help

.PHONY: help
help:
	@echo available targest
	@echo
	@echo "    tag      -- make a tag"
	@echo "    push     -- push branch and tags"
	@echo "    release  -- make a Github release"
	@echo

.PHONY: tag
tag:
	if [[ -z "$$TAG" ]]; then \
		>&2 echo "ERROR: you have to set env TAG; stopping"; \
		exit 1; \
	fi; \
	git tag $$TAG -m 'Release $$TAG'

.PHONY: push
push:
	git push origin
	git push origin --tags

.PHONY: release
release: push
	TAG=$$(git describe); \
	if [[ $$? -ne 0 ]] || [[ $$(echo $$TAG | tr -cd '-' | wc -c) -gt 1 ]]; then \
		>&2 echo "ERROR: not at a clean release; stopping"; \
		exit 1; \
	fi; \
	gh release create $$TAG --title "$$TAG" --notes 'See `HISTORY.md` for the changelog and release notes.'
