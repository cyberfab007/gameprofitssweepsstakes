
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
        return deployer.deploy(Ticket, 8000, "Ticket", "TICKET").then(instance => {
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
                        return deployer.deploy(Raffle, "My First Raffle", ticket.address, prizeTokens, true, 2, 4, 0, 0, "Our Good Sponsor").then(instance => {
                            raffle = instance
                        })                 
                    })
                })
            })
        })
    })
}


