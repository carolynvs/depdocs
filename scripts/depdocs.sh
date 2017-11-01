#!/usr/bin/env bash
set -xeuo pipefail

REPO_ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
DOCS="$REPO_ROOT/docs"

# Run the hugo binary in a container, allowing for live-edits of the site's content
hugo () {
  # carolynvs/hugo comes from docs/hugo/Dockerfile
  docker run --rm -it -v $DOCS:/var/www -w /var/www -p 1313:1313 carolynvs/hugo:0.30.2 $@
}

# Serve a live preview of the site
preview() {
  hugo server --debug --baseUrl=http://localhost --bind=0.0.0.0 -d $DOCS/_preview
}

# Generate the static site's content for the current version
# master is dumped into the root
# tags are placed under root/releases/VERSION
generate() {
  # Try overridden DEP_VERSION/BRANCH values before retrieving from git
  VERSION=${DEP_VERSION:-$(git describe --exact-match --tags 2> /dev/null || echo "")}
  BRANCH=${DEP_BRANCH:-$(git symbolic-ref --short HEAD 2> /dev/null || echo "")}
  DOCSRC=${VERSION:-$BRANCH}

  if [[ "$VERSION" != "" ]]; then
    DEST=$DOCS/_deploy/releases/$VERSION

    # Start fresh so that removed files are picked up
    rm -r $DEST 2> /dev/null || true

    # Set the dep version in the doc's config
    sed -i.bak -e 's/depver = ""/depver = "'"$VERSION"'"/' $DOCS/config.toml
  else
    DEST=$DOCS/_deploy/

    # Start fresh so that removed files are picked up
    # Only nuke the main site, don't kill .git or other releases
    find $DEST -type f ! -path "*/.git/*" ! -path "*/releases/*" -delete
  fi

  echo "Generating site @ $DOCSRC into $DEST ..."
  hugo -d $DEST
}

# Generate the current version's docs and push to the gh-pages branch
publish() {
  if [[ $(git status -s) ]]
  then
      echo "The working directory is dirty. Please commit any pending changes."
      exit 1;
  fi

  echo "Cleaning up from any previous deployments..."
  DEPLOY=$DOCS/_deploy
  rm -r $DEPLOY 2> /dev/null || true
  mkdir -p $DEPLOY
  git worktree prune
  rm -r $REPO_ROOT/.git/worktrees/_deploy 2> /dev/null || true

  echo "Checking out latest from the gh-pages branch..."
  git fetch --depth=1 origin gh-pages:gh-pages
  git worktree add -B gh-pages $DEPLOY gh-pages

  generate

  pushd $DEPLOY
  if git diff-index --quiet HEAD -- ; then
    echo "Skipping site deployment, no changes found"
  else
    echo "Publishing to the gh-pages branch..."
    git add --all
    git commit -m "Automagic site deployment 🎩✨"
  fi
  popd
}

"$@"
