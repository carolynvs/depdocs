#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
DOCS="$REPO_ROOT/docs"

# Run the hugo binary in a container, allowing for live-edits of the site's content
hugo () {
  docker run --rm -it -v $DOCS:/var/www -w /var/www -p 1313:1313 carolynvs/hugo:0.30.2 $@
}

# Serve a live preview of the site
preview() {
  hugo server --debug --baseUrl=http://localhost --bind=0.0.0.0 -d ./_preview
}

# Generate the static site's content for the current version
generate() {
  hugo -d ./_deploy
}

# Generate the entire site, all versions, and publish to the gh-pages branch
publish() {
  if [[ $(git status -s) ]]
  then
      echo "The working directory is dirty. Please commit any pending changes."
      exit 1;
  fi

  # Travis will only trigger on tags anyway, this just adds another sanity check
  VERSION=$(git describe --exact-match --tags)

  echo "Cleaning up from any previous deployments..."
  DEPLOY=$DOCS/_deploy
  rm -r $DEPLOY || true
  mkdir -p $DEPLOY
  git worktree prune
  rm -r $REPO_ROOT/.git/worktrees/_deploy || true

  echo "Checking out latest from the gh-pages branch..."
  git fetch upstream
  git worktree add -B gh-pages $DEPLOY upstream/gh-pages

  echo "Generating site..."
  rm -r $DEPLOY/*
  generate

  echo "Publishing to the gh-pages branch..."
  pushd $DEPLOY
  git add --all
  git commit --allow-empty -m "Publishing to gh-pages"
  popd
}

"$@"
