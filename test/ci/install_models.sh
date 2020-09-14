#!/usr/bin/env bash

set -e

CACHE_DIR=$HOME/MITIE-models/$MITIE_MODELS_VERSION

mkdir $HOME/MITIE-models

if [ ! -d "$CACHE_DIR" ]; then
  cd /tmp
  wget https://github.com/mit-nlp/MITIE/releases/download/v0.4/MITIE-models-v$MITIE_MODELS_VERSION.tar.bz2
  tar xvfj MITIE-models-v$MITIE_MODELS_VERSION.tar.bz2
  mv MITIE-models $CACHE_DIR
else
  echo "Models cached"
fi
