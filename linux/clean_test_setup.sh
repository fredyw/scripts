#!/bin/bash

set -euxo pipefail

yes | docker container prune
yes | docker image prune
docker rmi test-setup