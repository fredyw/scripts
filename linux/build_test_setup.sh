#!/bin/bash

set -euxo pipefail

cp -rf $HOME/.ssh .
docker build -t test-setup .