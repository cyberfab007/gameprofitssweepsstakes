
const Ticket = artifacts.require("Ticket")
const Raffle = artifacts.require("Raffle")

contract("Ticket Test", accounts => {

    it("should mintAmount() 25 Tickets for 0", () => {
        let deployed;
        return Ticket.deployed()
          .then(instance => {
            deployed = instance
            deployed.mintAmount(accounts[0], 25)
          })
          .then(() => deployed.balanceOf(accounts[0]))
          .then(balance => assert.equal(balance, 25, "Wrong balance"))
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

    it("should approve() Ticket #17 from the 0 to Raffle, then runSecondRound() and claimTicket() #17", () => {
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
            return ticket.approveAndCall(raffle.address, 17)
          })
          .then(() => raffle.runSecondRound())
          .then(() => raffle.claimTickets(17))
          .then(() => raffle.numbers(0))
    })

})
