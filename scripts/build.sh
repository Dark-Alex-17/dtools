#!/bin/bash
docker run --rm -it --user $(id -u):$(id -g) --env "BASHLY_TAB_INDENT=1" --volume "$PWD:/app" dannyben/bashly generate --upgrade
