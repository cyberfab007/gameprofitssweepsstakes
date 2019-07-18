#!/bin/bash
set -xe

ganache-cli --networkId 2030 \
  --host 127.0.0.1 --port 8545 \
  --gasLimit 1000000000 \
  --gasPrice 15000000000 \
  --deterministic \
  --defaultBalanceEther 100 \
  --unlock \
    0x90f8bf6a479f320ead074411a4b0e7944ea8c9c1,\
    0xffcf8fdee72ac11b5c542428b35eef5769c409f0,\
    0x22d491bde2303f2f43325b2108d26f1eaba1e32b,\
    0xe11ba2b4d45eaed5996cd0823791e0c93114882d,\
    0xd03ea8624c8c5987235048901fb614fdca89b117
