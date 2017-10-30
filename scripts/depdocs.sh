DOCS=`pwd`/docs

echo $DOCS

hugo () {
  docker run --rm -it -v $DOCS:/var/www -w /var/www -p 1313:1313 carolynvs/hugo:0.30.2 $@
}

preview() {
  hugo server --baseUrl=http://localhost --bind=0.0.0.0
}

generate() {
  hugo -d ./_deploy
}

"$@"
