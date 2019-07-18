#!/bin/bash

./build.sh $1
./deploy.sh $1
./test.sh $1
