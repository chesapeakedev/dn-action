SHELL := bash

ifeq ($(shell uname),Darwin)
    SED_INPLACE := sed -i ''
else
    SED_INPLACE := sed -i
endif

.PHONY: bump release

bump:
	@current=$$(grep -o '"version": "[^"]*"' package.json | cut -d'"' -f4); \
	major=$$(echo $$current | cut -d'.' -f1); \
	new_version="$$((major + 1)).0.0"; \
	$(SED_INPLACE) "s/\"version\": \"$$current\"/\"version\": \"$$new_version\"/" package.json; \
	echo "Bumped version from $$current to $$new_version"

release:
	@VERSION=$$(grep -o '"version": "[^"]*"' package.json | cut -d'"' -f4); \
	dn release create "v$$VERSION" --title "v$$VERSION"
