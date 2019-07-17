#!/bin/bash
set -xe

rm -rf build/
npm run merge
truffle compile --all --network dev
