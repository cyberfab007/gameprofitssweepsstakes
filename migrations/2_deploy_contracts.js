
const Ticket = artifacts.require("Ticket")
const ERC721Full = artifacts.require("ERC721Full")
const AdvancedToken = artifacts.require("AdvancedToken")
const ERC20 = artifacts.require("ERC20")

const Web3 = require("web3")
let web3

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


module.exports = function(deployer) {

    //iterate(deployer, '')
    const network = deployer.networks[deployer.network]
    
    web3 = new Web3(new Web3.providers.HttpProvider("http://" + network.host + ":" + network.port))
    getAccounts().then(function(accounts) {
        getBalance(accounts[0]).then(function(balance) {
            console.log("Promised: " + balance)
        })
    })

    deployer.deploy(Ticket, "Ticket", "TICKET").then(function(instance) {
        instance.mintAmount(network.from, 25).then(function() {
            instance.balanceOf(network.from).then(function(balance) {
                console.log("Promised Ticket Balance: " + balance)
            })
        })
    })
    deployer.deploy(ERC721Full, "ERC-721 Standard", "ERC721");
    deployer.deploy(AdvancedToken, 1000, "Advanced Token", "ADV");
    deployer.deploy(ERC20, 1000000, "ERC-20 Standard", "ERC20");
}


