Types of Deposits that can be made to the Raffle contract:

1) Ticket (an extended ERC-721 token):..............................................Players call Ticket.approveAndCall()
2) Standard ERC-721:................................................................Owner calls the standard method ERC721.safeTransferFrom()
3) AdvancedToken (an extended ERC-20 token implementing approveAndCall()):..........Owner calls TokenERC20.approveAndCall()
4) Standard ERC-20:.................................................................Owner calls the standard ERC20.approve() and Raffle.receiveApproval()
5) Ether:...........................................................................Owner calls Raffle.depositEther() payable function

=========================================================

Details:

1) Ticket (an extended ERC-721 token): Players call Ticket.approveAndCall()

1a) Players call

    Ticket.approveAndCall(
      address to = <raffle contract address>
      uint256 tokenId = <deposited ticket token id>
    )

1b) The Ticket contract _automatically_ notifies the Raffle contract about the deposit via

    Ticket._checkOnTicketReceived(
      address to = <raffle contract address>
      uint256 tokenId = <deposited ticket token id>
    )

    which calls

    ITicketReceiver(to).onTicketReceived(
      address operator = <ticket contract address>
      bytes32 hash = <keccak256 hash of token sender and token id (for security reasons)>
    )

Accepted Tickets are stored as hashes (playerToHash map) in the 1st round and as numbers array and numberToPlayer map in the 2nd round.

Check https://medium.com/@promentol/lottery-smart-contract-can-we-generate-random-numbers-in-solidity-4f586a152b27 article for more details.

2) Standard ERC-721: Raffle owner calls the standard method ERC721.safeTransferFrom()

2a) Owner calls the standard method

    ERC721.safeTransferFrom(
      address from = <raffle owner address>
      address to = <raffle contract address>
    )

2b) The standard ERC721 contract _automatically_ notifies Raffle contract about the deposit via 

    ERC721(to)._checkOnERC721Received(
      address from = <raffle owner address>
      address to = <raffle contract address>
      uint256 tokenId = <deposited token id>
      bytes memory data = <some extra data>
    )

    which calls

    IERC721Receiver(to).onERC721Received(
      address operator  = <ticket contract address>
      address from  = <raffle owner address>
      uint256 tokenId = <deposited token id>
      bytes memory data = <some extra data>
    )

Accepted ERC721 deposits are stored as prizeERC721 map.

Check the description of safeTransferFrom(address, address, uint256, bytes) at erc721.org for more details.

3) AdvancedToken (an extended ERC-20 token implementing approveAndCall()): Raffle owner calls TokenERC20.approveAndCall()

3a) Owner calls

    TokenERC20.approveAndCall(
      address to = <raffle contract address>
      uint256 value = <amount of tokens to deposit>
      bytes memory data = <some extra data>
    )

3b) AdvancedToken contract _automatically_ notifies Raffle contract about the deposit via 

    IExtERC20Receiver(to).receiveApproval(
      address from = <raffle owner address>
      uint256 value = <amount of tokens to deposit>
      address operator = <ticket contract address>
      bytes memory data = <some extra data>
    )

Check https://ethereum.stackexchange.com/a/43163/50769 for more details.

4) Standard ERC-20: Raffle owner calls the standard ERC20.approve(), then the owner calls Raffle.receiveApproval()

4a) Owner calls the standard method

    ERC20.approve(
      address to = <raffle contract address>
      uint256 value = <amount of tokens to deposit>
    )

4b) In order to manually notify the Raffle contract about an ERC20 deposit, owner should call

    Raffle.receiveApproval(
      address operator = <ERC20 token contract address>
      uint256 value = <amount of tokens to deposit>
    )

Accepted ERC20 and AdvancedToken deposits are stored as prizeERC20 map.

5) Ether: Raffle owner calls Raffle.depositEther() payable function

   There is no need to additionally notify the Raffle contract about ETH deposits.

   Accepted deposits can be checked using web3.eth.getBalance(<raffle contract address>) once they are done.


