
const ERC721 = artifacts.require("ERC721Full")
const Raffle = artifacts.require("Raffle")

contract("Deposit ERC721 Test", accounts => {

    it("should mint() ERC721 token #888 for 0", () => {
        let deployed;
        return ERC721.deployed()
          .then(instance => {
            deployed = instance
            deployed.mint(accounts[0], 888)
          })
          .then(() => deployed.balanceOf(accounts[0]))
          .then(balance => assert.equal(balance, 1, "Wrong balance"))
          .then(() => deployed.ownerOf(888))
          .then(owner => assert.equal(owner, accounts[0], "Wrong owner"))
    })

    it("should safeTransferFrom() ERC721 #888 from 0 to Raffle, and check receival via prizeERC721()", () => {
        let erc721, raffle;
        return ERC721.deployed()
          .then(instance => {
            erc721 = instance
            return Raffle.deployed()
          })
          .then(instance => {
            raffle = instance
            return erc721.safeTransferFrom(accounts[0], raffle.address, 888)
          })
          .then(() => erc721.balanceOf(accounts[0]))
          .then(balance => assert.equal(balance, 0, "Wrong balance"))
          .then(() => erc721.balanceOf(raffle.address))
          .then(balance => assert.equal(balance, 1, "Wrong balance"))
          .then(() => erc721.ownerOf(888))
          .then(owner => assert.equal(owner, raffle.address, "Wrong owner"))
          .then(() => raffle.prizeERC721(erc721.address, 0))
          .then((depositedTokenId) => assert.equal(depositedTokenId, 888))
    })

})
