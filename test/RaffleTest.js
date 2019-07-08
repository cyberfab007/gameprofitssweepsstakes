const ERC20 = artifacts.require("ERC20")
const AdvancedToken = artifacts.require("AdvancedToken")
const ERC721 = artifacts.require("ERC721Full")
const Ticket = artifacts.require("Ticket")
const Raffle = artifacts.require("Raffle")
const BigNumber = require('big-number');

contract("Raffle Test", accounts => {

    /** DEPOSIT ETH **/

    it("should depositEther() 1234567890 wei from [0] to Raffle, and check receival via address.balance", () => {
        let deployed;
        return Raffle.deployed()
          .then(instance => {
              deployed = instance
              return deployed.depositEther({value: 1234567890})
           })
          .then(() => web3.eth.getBalance(deployed.address))
          .then(balance => assert.equal(balance.toString(), "1234567890", "Wrong balance"))
    })

    /** DEPOSIT ERC20 **/

    it("should approve() and transferFrom() 10000000000 ERC20 from [0] to [5]", () => {
        let deployed;
        return ERC20.deployed()
          .then(instance => {
              deployed = instance
              return deployed.approve(                                   accounts[5], 10000000000)
           })
          .then(() => deployed.balanceOf(accounts[0]))
          .then(balance => assert.equal(balance.toString(), "1000000000000000000000000", "Wrong balance"))
          .then(() => deployed.transferFrom.sendTransaction(accounts[0], accounts[5],  6000000000, {from: accounts[5]}))
          .then(() => deployed.balanceOf(accounts[0]))
          .then(balance => assert.equal(balance.toString(),  "999999999999994000000000", "Wrong balance"))
          .then(() => deployed.balanceOf(accounts[5]))
          .then(balance => assert.equal(balance.toString(),                "6000000000", "Wrong balance"))
          .then(() => deployed.transferFrom.sendTransaction(accounts[0], accounts[5],  4000000000, {from: accounts[5]}))
    })

    it("should approve() 77000009333 ERC20 from [0] to Raffle, then receiveApproval() on Raffle as [0], and check receival via prizeERC20()", () => {
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

    /** DEPOSIT ADV **/

    it("should approveAndCall() and transferFrom() 10000000000 ADV from [0] to [5]", () => {
        let deployed;
        return AdvancedToken.deployed()
          .then(instance => {
              deployed = instance
              deployed.approveAndCall.sendTransaction(                   accounts[5], 10000000000, '0x42')
           })
          .then(() => deployed.balanceOf(accounts[0]))
          .then(balance => assert.equal(balance.toString(), "1000000000000000000000", "Wrong balance"))
          .then(() => deployed.transferFrom.sendTransaction(accounts[0], accounts[5],  5000000000, {from: accounts[5]}))
          .then(() => deployed.balanceOf(accounts[0]))
          .then(balance => assert.equal(balance.toString(),  "999999999995000000000", "Wrong balance"))
          .then(() => deployed.balanceOf(accounts[5]))
          .then(balance => assert.equal(balance.toString(),             "5000000000", "Wrong balance"))
          .then(() => deployed.transferFrom.sendTransaction(accounts[0], accounts[5],  5000000000, {from: accounts[5]}))
    })

    it("should approveAndCall() 23000001111 ADV from [0] to Raffle, and check receival via prizeERC20()", () => {
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

    /** DEPOSIT ERC721 **/

    it("should mint() ERC721 token #888 for [0]", () => {
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

    it("should safeTransferFrom() ERC721 #888 from [0] to Raffle, and check receival via prizeERC721()", () => {
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

    /** DEPOSIT TICKET **/

    it("should mintAmount() 25 Tickets for [0], 35 Tickets for [1] and 40 Tickets for [2]", () => {
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

    it("should safeTransferFrom() Ticket #22 from the [0] to [5]", () => {
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

    it("should approve() Tickets #17,#22,#27,#44 from [0],[5],[1],[2] to Raffle, then runSecondRound() and claimTicket()s by numbers", () => {
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

    /** EXECUTE RAFFLE **/

    it("should execute() and check that [2] is winner(), also verifying Raffle and [2] balances before and after execution", () => {
        let erc721, erc20, adv, raffle, raffleOwner,
            initBalanceRaffleERC20, initBalanceRaffleADV, initBalanceRaffleERC721, initBalanceRaffleETH,
            initBalanceWinnerERC20, initBalanceWinnerADV, initBalanceWinnerERC721, initBalanceWinnerETH,
            finalBalanceRaffleERC20, finalBalanceRaffleADV, finalBalanceRaffleERC721, finalBalanceRaffleETH,
            finalBalanceWinnerERC20, finalBalanceWinnerADV, finalBalanceWinnerERC721, finalBalanceWinnerETH
        return ERC721.deployed()
          .then(instance => {
            erc721 = instance
            return ERC20.deployed()
          })
          .then(instance => {
            erc20 = instance
            return AdvancedToken.deployed()
          })
          .then(instance => {
            adv = instance
            return Raffle.deployed()
          })
          .then(instance => {
            raffle = instance
            return raffle.owner()
          })
          .then(owner => {
            raffleOwner = owner
            return erc721.balanceOf(accounts[2])          // check balance of [2] (the future winner) before execution
          })
          .then(balance => {
            initBalanceWinnerERC721 = balance
            return erc20.balanceOf(accounts[2])
          })
          .then(balance => {
            initBalanceWinnerERC20 = balance
            return adv.balanceOf(accounts[2])
          })
          .then(balance => {
            initBalanceWinnerADV = balance
            return web3.eth.getBalance(accounts[2])
          })
          .then(balance => {
            initBalanceWinnerETH = balance
            return erc721.balanceOf(raffle.address)       // check the raffle's balance before execution
          })
          .then(balance => {
            initBalanceRaffleERC721 = balance
            return erc20.allowance(raffleOwner, raffle.address)
          })
          .then(balance => {
            initBalanceRaffleERC20 = balance
            return adv.allowance(raffleOwner, raffle.address)
          })
          .then(balance => {
            initBalanceRaffleADV = balance
            return web3.eth.getBalance(raffle.address)
          })
          .then(balance => {
            initBalanceRaffleETH = balance
            console.log("Init Winner ERC721: " + initBalanceWinnerERC721)
            console.log("Init Winner ERC20: " + initBalanceWinnerERC20)
            console.log("Init Winner ADV: " + initBalanceWinnerADV)
            console.log("Init Winner ETH: " + initBalanceWinnerETH)
            console.log("Init Raffle ERC721: " + initBalanceRaffleERC721)
            console.log("Init Raffle ERC20: " + initBalanceRaffleERC20)
            console.log("Init Raffle ADV: " + initBalanceRaffleADV)
            console.log("Init Raffle ETH: " + initBalanceRaffleETH)
            assert.equal(initBalanceWinnerERC721, 0, "Wrong balance")
            assert.equal(initBalanceWinnerERC20, 0, "Wrong balance")
            assert.equal(initBalanceWinnerADV, 0, "Wrong balance")
            assert.isAbove(parseFloat(web3.utils.fromWei(initBalanceWinnerETH, "ether")), 0, "Wrong balance")
            assert.equal(initBalanceRaffleERC721, 1, "Wrong balance")
            assert.equal(initBalanceRaffleERC20, 77000009333, "Wrong balance")
            assert.equal(initBalanceRaffleADV, 23000001111, "Wrong balance")
            assert.equal(initBalanceRaffleETH, 1234567890, "Wrong balance")
            return raffle.execute()
          })
          .then(() => raffle.winner())
          .then(winner => {
            assert.equal(winner, accounts[2], "Wrong winner")
            return erc721.balanceOf(accounts[2])          // check balance of [2] (the winner) after execution
          })
          .then(balance => {
            finalBalanceWinnerERC721 = balance
            return erc20.balanceOf(accounts[2])
          })
          .then(balance => {
            finalBalanceWinnerERC20 = balance
            return adv.balanceOf(accounts[2])
          })
          .then(balance => {
            finalBalanceWinnerADV = balance
            return web3.eth.getBalance(accounts[2])
          })
          .then(balance => {
            finalBalanceWinnerETH = balance
            return erc721.balanceOf(raffle.address)       // check the raffle's balance after execution
          })
          .then(balance => {
            finalBalanceRaffleERC721 = balance
            return erc20.allowance(raffleOwner, raffle.address)
          })
          .then(balance => {
            finalBalanceRaffleERC20 = balance
            return adv.allowance(raffleOwner, raffle.address)
          })
          .then(balance => {
            finalBalanceRaffleADV = balance
            return web3.eth.getBalance(raffle.address)
          })
          .then(balance => {
            finalBalanceRaffleETH = balance
            console.log("Final Winner ERC721: " + finalBalanceWinnerERC721)
            console.log("Final Winner ERC20: " + finalBalanceWinnerERC20)
            console.log("Final Winner ADV: " + finalBalanceWinnerADV)
            console.log("Final Winner ETH: " + finalBalanceWinnerETH)
            console.log("Final Raffle ERC721: " + finalBalanceRaffleERC721)
            console.log("Final Raffle ERC20: " + finalBalanceRaffleERC20)
            console.log("Final Raffle ADV: " + finalBalanceRaffleADV)
            console.log("Final Raffle ETH: " + finalBalanceRaffleETH)
            assert.equal(finalBalanceWinnerERC721, 1, "Wrong balance")
            assert.equal(finalBalanceWinnerERC20, 77000009333, "Wrong balance")
            assert.equal(finalBalanceWinnerADV, 23000001111, "Wrong balance")
            assert.equal(BigNumber(finalBalanceWinnerETH).minus(BigNumber(initBalanceWinnerETH)), 1234567890, "Wrong balance")
            assert.equal(finalBalanceRaffleERC721, 0, "Wrong balance")
            assert.equal(finalBalanceRaffleERC20, 0, "Wrong balance")
            assert.equal(finalBalanceRaffleADV, 0, "Wrong balance")
            assert.equal(finalBalanceRaffleETH, 0, "Wrong balance")
          })
    })

})
