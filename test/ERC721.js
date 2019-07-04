
const ERC721 = artifacts.require("ERC721Full")

contract("ERC721 Test", accounts => {

    it("should mint ERC721 token #777 for the first account", () => {
        let deployed;
        return ERC721.deployed()
          .then(instance => {
            deployed = instance
            deployed.mint(accounts[0], 777)
          })
          .then(() => deployed.balanceOf(accounts[0]))
          .then(balance => assert.equal(balance, 1, "Wrong balance"))
          .then(() => deployed.ownerOf(777))
          .then(owner => assert.equal(owner, accounts[0], "Wrong owner"))
    })

    it("should transfer ERC721 #777 from the first to the fifth account", () => {
        let deployed;
        return ERC721.deployed()
          .then(instance => {
            deployed = instance
            deployed.safeTransferFrom(accounts[0], accounts[5], 777)
          })
          .then(() => deployed.balanceOf(accounts[0]))
          .then(balance => assert.equal(balance, 0, "Wrong balance"))
          .then(() => deployed.balanceOf(accounts[5]))
          .then(balance => assert.equal(balance, 1, "Wrong balance"))
          .then(() => deployed.ownerOf(777))
          .then(owner => assert.equal(owner, accounts[5], "Wrong owner"))
    })
})
