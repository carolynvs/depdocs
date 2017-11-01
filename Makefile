# DEP_VERSION and DEP_BRANCH override the information normally gleaned from git
# This is mostly used by Travis since their checkouts don't play nice with git
# Examples:
# make generate DEP_VERSION=v0.3.0
# make preview DEP_BRANCH=master

default: preview

hugo:
	docker build -t carolynvs/hugo:0.30.2 docs/hugo
	docker tag carolynvs/hugo:0.30.2 carolynvs/hugo:latest
	docker push carolynvs/hugo:0.30.2
	docker push carolynvs/hugo:latest

preview:
	./scripts/depdocs.sh preview

generate:
	./scripts/depdocs.sh generate

publish:
	./scripts/depdocs.sh publish
