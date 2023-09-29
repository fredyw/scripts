#!/bin/bash

set -euxo pipefail

docker container prune
docker image prune
docker rmi test-setup