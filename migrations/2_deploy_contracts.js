
const Ticket = artifacts.require("Ticket")
const ERC721Full = artifacts.require("ERC721Full")
const AdvancedToken = artifacts.require("AdvancedToken")
const ERC20 = artifacts.require("ERC20")

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


module.exports = function(deployer) {

    //iterate(deployer, '')
    const network = deployer.networks[deployer.network]
    
    web3 = new Web3(new Web3.providers.HttpProvider("http://" + network.host + ":" + network.port))
    getAccounts().then(function(accounts) {
        accs = accounts
        if (accs[0] != network.from) throw "Something is wrong with the network or web3"

        getBalance(accs[0]).then(function(balance) {
            console.log("#### accs[0] ether balance: " + balance)
        })

    })

    deployer.deploy(Ticket, "Ticket", "TICKET").then(function(instance) {
        instance.mintAmount(accs[0], 25).then(function() {
            instance.balanceOf(accs[0]).then(function(balance) {
                console.log("#### accs[0] ticket balance before transferring: " + balance + "####")
                instance.safeTransferFrom(accs[0], accs[5], 22).then(function() {
                    instance.balanceOf(accs[0]).then(function(balance) {
                        console.log("#### accs[0] ticket balance after transferring: " + balance + "####")
                        instance.ownerOf(22).then(function(owner) {
                            console.log("#### the owner of ticket #22: " + owner + "####")
                        })
                    })
                })
            })
        })
    })

    deployer.deploy(ERC721Full, "ERC-721 Standard", "ERC721");
    deployer.deploy(AdvancedToken, 1000, "Advanced Token", "ADV");
    deployer.deploy(ERC20, 1000000, "ERC-20 Standard", "ERC20");

}


