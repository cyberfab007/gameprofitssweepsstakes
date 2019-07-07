
const AdvancedToken = artifacts.require("AdvancedToken")
const Raffle = artifacts.require("Raffle")

contract("Deposit AdvancedToken Test", accounts => {

    it("should approveAndCall() and transferFrom() 10000000000 ADV from 0 to 5", () => {
        let deployed;
        return AdvancedToken.deployed()
          .then(instance => {
              deployed = instance
              deployed.approveAndCall.sendTransaction(                   accounts[5], 10000000000, '0x42')
           })
          .then(() => deployed.balanceOf(accounts[0]))
          .then(balance => assert.equal(balance.toString(), "1000000000000000000000", "Wrong balance"))
          .then(() => deployed.transferFrom.sendTransaction(accounts[0], accounts[5],  5000000000))
          .then(() => deployed.balanceOf(accounts[0]))
          .then(balance => assert.equal(balance.toString(),  "999999999995000000000", "Wrong balance"))
          .then(() => deployed.balanceOf(accounts[5]))
          .then(balance => assert.equal(balance.toString(),             "5000000000", "Wrong balance"))
          .then(() => deployed.transferFrom.sendTransaction(accounts[0], accounts[5],  5000000000))
    })

    it("should approveAndCall() 23000001111 ADV from 0 to Raffle, and check receival via prizeERC20()", () => {
        let adv, raffle;
        return AdvancedToken.deployed()
          .then(instance => {
            adv = instance
            return Raffle.deployed()
          })
          .then(instance => {
            raffle = instance
            return adv.approveAndCall(raffle.address, 23000001111, '0x42')
           })
          .then(() => raffle.prizeERC20(adv.address))
          .then((depositedAmount) => assert.equal(depositedAmount, 23000001111))
    })
})
