#!/bin/bash

find . -name '*.tmx' -exec  bash -c './tiled --export-map lua "$1" "${1/\.tmx/\.lua}"' -- {} \;

