.PHONY: bump release

bump:
	@current=$$(git describe --tags --abbrev=0 2>/dev/null | sed 's/^v//' || echo "0"); \
	new_version="v$$((current + 1))"; \
	git tag -a "$$new_version" -m "Release $$new_version"; \
	echo "Created tag $$new_version"

release:
	@git push origin $$(git describe --tags --abbrev=0)
	@@git push origin main