#!/bin/bash

set -euxo pipefail

docker container prune -f
docker image prune -f
docker rmi test-setup