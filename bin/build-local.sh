#!/usr/bin/env bash

PROJECT_DIR=$(readlink -f $(dirname $(readlink -f "$0"))/..)
cd $PROJECT_DIR

docker build -t bmst/jenkins2 .


