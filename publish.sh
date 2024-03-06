#!/bin/bash

BUILD_DIR="build"
RELEASE_BRANCH="gh-pages"

# Script
git fetch origin $RELEASE_BRANCH
git add -f $BUILD_DIR
tree=$(git write-tree --prefix=$BUILD_DIR)
git reset -- $BUILD_DIR
identifier=$(git describe --dirty --always)
commit=$(git commit-tree -p refs/remotes/origin/$RELEASE_BRANCH -m "Deploy $identifier" $tree)
git update-ref refs/heads/$RELEASE_BRANCH $commit
git push origin refs/heads/$RELEASE_BRANCH
