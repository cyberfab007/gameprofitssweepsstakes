
const Ticket = artifacts.require("Ticket")
const Raffle = artifacts.require("Raffle")

contract("Deposit Ticket Test", accounts => {

    it("should mintAmount() 25 Tickets for 0, 35 Tickets for 1 and 40 Tickets for 2", () => {
        let deployed;
        return Ticket.deployed()
          .then(instance => {
            deployed = instance
            deployed.mintAmount(accounts[0], 25)
          })
          .then(() => deployed.balanceOf(accounts[0]))
          .then(balance => assert.equal(balance, 25, "Wrong balance"))
          .then(() => deployed.mintAmount(accounts[1], 35))
          .then(() => deployed.balanceOf(accounts[1]))
          .then(balance => assert.equal(balance, 35, "Wrong balance"))
          .then(() => deployed.mintAmount(accounts[2], 40))
          .then(() => deployed.balanceOf(accounts[2]))
          .then(balance => assert.equal(balance, 40, "Wrong balance"))
    })

    it("should safeTransferFrom() Ticket #22 from the 0 to 5", () => {
        let deployed;
        return Ticket.deployed()
          .then(instance => {
            deployed = instance
            deployed.safeTransferFrom(accounts[0], accounts[5], 22)
          })
          .then(() => deployed.balanceOf(accounts[0]))
          .then(balance => assert.equal(balance, 24, "Wrong balance"))
          .then(() => deployed.balanceOf(accounts[5]))
          .then(balance => assert.equal(balance, 1, "Wrong balance"))
          .then(() => deployed.ownerOf(22))
          .then(owner => assert.equal(owner, accounts[5], "Wrong owner"))
    })

    it("should approve() Tickets #17, #22, #27 and #44 from 0, 5, 1 and 2 to Raffle, then runSecondRound() and claimTicket()s", () => {
        let ticket, raffle;
        return Ticket.deployed()
          .then(instance => {
            ticket = instance
            return Raffle.deployed()
          })
          .then(instance => {
            raffle = instance
            return raffle.ticketToken()
          })
          .then(ticketToken => {
            assert.equal(ticket.address, ticketToken, "Wrong Raffle.ticketToken")
            return    ticket.approveAndCall(raffle.address, 17, {from: accounts[0]})
          })
          .then(() => ticket.approveAndCall(raffle.address, 22, {from: accounts[5]}))
          .then(() => ticket.approveAndCall(raffle.address, 27, {from: accounts[1]}))
          .then(() => ticket.approveAndCall(raffle.address, 83, {from: accounts[2]}))
          .then(() => raffle.runSecondRound())
          .then(() => raffle.claimTicket(17, {from: accounts[0]}))
          .then(() => raffle.numbers(0))
          .then(number => assert.equal(number, 17, "Wrong number"))
          .then(() => raffle.claimTicket(22, {from: accounts[5]}))
          .then(() => raffle.numbers(1))
          .then(number => assert.equal(number, 22, "Wrong number"))
          .then(() => raffle.claimTicket(27, {from: accounts[1]}))
          .then(() => raffle.numbers(2))
          .then(number => assert.equal(number, 27, "Wrong number"))
          .then(() => raffle.claimTicket(83, {from: accounts[2]}))
          .then(() => raffle.numbers(3))
          .then(number => assert.equal(number, 83, "Wrong number"))
    })

    it("should execute() and check that 2 is winner()", () => {
        let deployed;
        return Raffle.deployed()
          .then(instance => {
            deployed = instance
            return deployed.execute()
          })
          .then(() => deployed.winner())
          .then(winner => assert.equal(winner, accounts[2], "Wrong winner"))
    })

})
