#!/bin/bash
set -xe

rm -rf build/
npm run merge
truffle compile
#mv build/contracts/Ticket.sol build/contracts/TicketLight.sol
#mv build/contracts/Raffle.sol build/contracts/RaffleLight.sol

