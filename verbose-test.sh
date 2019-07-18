#!/bin/bash
set -xe

truffle test --show-events --verbose-rpc --network $1
