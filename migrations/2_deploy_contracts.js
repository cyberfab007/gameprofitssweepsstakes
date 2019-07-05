
const Ticket = artifacts.require("Ticket")
const ERC721Full = artifacts.require("ERC721Full")
const AdvancedToken = artifacts.require("AdvancedToken")
const ERC20 = artifacts.require("ERC20")
const Raffle = artifacts.require("Raffle")

module.exports = function(deployer) {
    let ticketToken, prizeTokens = []
    deployer.deploy(Ticket, "Ticket", "TICKET").then(instance => {
        ticketToken = instance.address
        return deployer.deploy(ERC721Full, "ERC-721 Standard", "ERC721").then(instance => {
            prizeTokens.push(instance.address)
            return deployer.deploy(AdvancedToken, 1000, "Advanced Token", "ADV").then(instance => {
                prizeTokens.push(instance.address)
                return deployer.deploy(ERC20, 1000000, "ERC-20 Standard", "ERC20").then(instance => {
                    prizeTokens.push(instance.address)
                    return deployer.deploy(Raffle, "My First Raffle", ticketToken, prizeTokens, true, 101, 102, 103, 104, "Our Good Sponsor")
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




