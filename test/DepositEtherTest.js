
const Raffle = artifacts.require("Raffle")

contract("Deposit Ether Test", accounts => {

    it("should depositEther() 1234567890 wei from 0 to Raffle, and check receival via address.balance", () => {
        let deployed;
        return Raffle.deployed()
          .then(instance => {
              deployed = instance
              return deployed.depositEther({value: 1234567890})
           })
          .then(() => web3.eth.getBalance(deployed.address))
          .then(balance => assert.equal(balance.toString(), "1234567890", "Wrong balance"))
    })
})
