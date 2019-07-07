
const ERC20 = artifacts.require("ERC20")
const Raffle = artifacts.require("Raffle")

contract("ERC20 Test", accounts => {

    it("should approve() and transferFrom() 10000000000 ERC20 from 0 to 5", () => {
        let deployed;
        return ERC20.deployed()
          .then(instance => {
              deployed = instance
              deployed.approve.sendTransaction(                          accounts[5], 10000000000)
           })
          .then(() => deployed.balanceOf(accounts[0]))
          .then(balance => assert.equal(balance.toString(), "1000000000000000000000000", "Wrong balance"))
          .then(() => deployed.transferFrom.sendTransaction(accounts[0], accounts[5],  6000000000))
          .then(() => deployed.balanceOf(accounts[0]))
          .then(balance => assert.equal(balance.toString(),  "999999999999994000000000", "Wrong balance"))
          .then(() => deployed.balanceOf(accounts[5]))
          .then(balance => assert.equal(balance.toString(),             "6000000000", "Wrong balance"))
          .then(() => deployed.transferFrom.sendTransaction(accounts[0], accounts[5],  4000000000))
    })

    it("should approve() 77000009333 ERC20 from 0 to Raffle, then receiveApproval() on Raffle as 0, and check receival via prizeERC20()", () => {
        let erc20, raffle;
        return ERC20.deployed()
          .then(instance => {
            erc20 = instance
            return Raffle.deployed()
          })
          .then(instance => {
            raffle = instance
            return erc20.approve(raffle.address, 77000009333)
           })
          .then(() => raffle.receiveApproval(accounts[0], 77000009333, erc20.address, '0x42'))
          .then(() => raffle.prizeERC20(erc20.address))
          .then((depositedAmount) => assert.equal(depositedAmount, 77000009333))
    })
})
