
const Ticket = artifacts.require("Ticket")

contract("Ticket Test", accounts => {

    it("should mint 25 Tickets for the first account", () => {
        let deployed;
        return Ticket.deployed()
          .then(instance => {
            deployed = instance
            deployed.mintAmount(accounts[0], 25)
          })
          .then(() => deployed.balanceOf(accounts[0]))
          .then(balance => assert.equal(balance, 25, "Wrong balance"))
    })

    it("should transfer Ticket #22 from the first to the fifth account", () => {
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
})
