SHELL := /bin/bash

install:
	npm install -g unfluff

wget:
	wget -v --recursive --no-clobber -A html new.artsmia.org

index = $(ES_index)

deleteIndex:
	curl -XDELETE $(ES_URL)/$(index)

pages:
	find new.artsmia.org -name '*.html' | while read page; do \
		file=bulk/$$page.json; \
		url=$$(sed 's/new.artsmia.org//; s/index.html//' <<<$$page); \
		[[ -f $$file ]] || mkdir -p $$(dirname $$file) && unfluff $$page | jq --arg url $$url '. + {url: $$url}' > $$file; \
		curl -XPOST "$(ES_URL)/$(index)/page" --data-binary @$$file; \
	done

removeJson:
	find bulk -name '*.json' | xargs rm

reindex: deleteIndex pages
