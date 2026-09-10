#!/bin/bash

ORIG_GOPATH="/agent-go"

NEW_GOPATH="/agent/go"
GOPATH="$NEW_GOPATH"
GOCACHE="$GOPATH/.cache"
GOBIN="$GOPATH/bin"
PATH="$PATH:$GOBIN"
GOLANGCI_LINT_CACHE=$GOCACHE

# Check if /agent/go exists, and create it if not
if [ ! -d "${GOPATH}" ]; then
  mkdir -p ${GOPATH}
  mkdir -p ${GOBIN}
fi

cp --recursive $ORIG_GOPATH/bin/* $GOBIN

export GOPATH
export GOCACHE
export GOBIN
export PATH
export GOLANGCI_LINT_CACHE

# Rust/cargo environment
CARGO_HOME="/usr/local/cargo"
RUSTUP_HOME="/usr/local/rustup"

# Check if cargo/rustup dirs exist, and create them if not
if [ ! -d "${CARGO_HOME}" ]; then
  mkdir -p ${CARGO_HOME}/bin
fi
if [ ! -d "${RUSTUP_HOME}" ]; then
  mkdir -p ${RUSTUP_HOME}
fi

PATH="$PATH:$CARGO_HOME/bin"

export CARGO_HOME
export RUSTUP_HOME
export PATH

git config --global --add safe.directory /agent

# Run the actual command (e.g., bash or other processes)
exec $@
