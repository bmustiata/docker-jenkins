#!/usr/bin/env bash

PROJECT_DIR=$(readlink -f $(dirname $(readlink -f "$0"))/..)
cd $PROJECT_DIR

set -e

JENKINS_VERSION=$(cat Dockerfile | head -1 | cut -f2 -d:)

git checkout master
git tag $JENKINS_VERSION
git checkout blueocean
git tag "blueocean-$JENKINS_VERSION"
git checkout ansible
git tag "ansible-$JENKINS_VERSION"
git checkout master
git push --all -f
git push --tags

