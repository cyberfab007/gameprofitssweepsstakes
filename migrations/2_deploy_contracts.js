
const Util = artifacts.require("Util")
const Ticket = artifacts.require("Ticket")
const ERC721 = artifacts.require("ERC721Full")
const AdvancedToken = artifacts.require("AdvancedToken")
const ERC20 = artifacts.require("ERC20")
const Raffle = artifacts.require("Raffle")

module.exports = function(deployer) {
    let util, ticket, erc721, adv, erc20, raffle, prizeTokens = []
    deployer.deploy(Util).then(instance => {
        util = instance
        deployer.link(Util, Ticket);
        deployer.link(Util, ERC721);
        deployer.link(Util, AdvancedToken);
        deployer.link(Util, ERC20);
        deployer.link(Util, Raffle);
        return deployer.deploy(Ticket, "Ticket", "TICKET").then(instance => {
            ticket = instance
            return deployer.deploy(ERC721, "ERC-721 Standard", "ERC721").then(instance => {
                erc721 = instance
                prizeTokens.push(erc721.address)
                return deployer.deploy(AdvancedToken, 1000, "Advanced Token", "ADV").then(instance => {
                    adv = instance
                    prizeTokens.push(adv.address)
                    return deployer.deploy(ERC20, 1000000, "ERC-20 Standard", "ERC20").then(instance => {
                        erc20 = instance
                        prizeTokens.push(erc20.address)
                        return deployer.deploy(Raffle, "My First Raffle", ticket.address, prizeTokens, true, 101, 4, 1562620000, 1, "Our Good Sponsor").then(instance => {
                            raffle = instance
                        })                 
                    })
                })
            })
        })
    })
}

/*
const Web3 = require("web3")
let web3, accs

function iterate(obj, stack) {
    for (var property in obj) {
        if (obj.hasOwnProperty && obj.hasOwnProperty(property)) {
            if (typeof obj[property] == "object") {
                iterate(obj[property], stack + '.' + property)
            } else {
                console.log(stack + '.' + property + ": " + obj[property])
            }
        }
    }
}

async function getAccounts() {
    const result = await web3.eth.getAccounts()
    console.log("getAccounts(): " + result)
    return result
}

async function getBalance(addr) {
    const result = await web3.eth.getBalance(addr)
    console.log("getBalance(" + addr + "): " + result)
    return result
}

    iterate(deployer, '')
    console.log(deployer)

    const network = deployer.networks[deployer.network]
    
    web3 = new Web3(new Web3.providers.HttpProvider("http://" + network.host + ":" + network.port))
    getAccounts().then(function(accounts) {
        accs = accounts
        if (accs[0] != network.from) throw "Something is wrong with the network or web3"

        getBalance(accs[0]).then(function(balance) {
            console.log("#### accs[0] ether balance: " + balance)
        })

    })
*/




