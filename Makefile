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
