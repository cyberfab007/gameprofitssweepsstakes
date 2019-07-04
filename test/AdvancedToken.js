
const AdvancedToken = artifacts.require("AdvancedToken")

contract("AdvancedToken Test", accounts => {

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
})
