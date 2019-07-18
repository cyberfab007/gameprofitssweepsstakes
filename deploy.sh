#!/bin/bash
set -xe

truffle migrate --reset --network $1
