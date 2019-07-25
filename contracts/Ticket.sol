pragma solidity >=0.4.22 <0.6.0;

import "./Owned.sol";
import "./ERC721Full.sol";
import "./ITicketReceiver.sol";

contract Ticket is Owned, ERC721Full {

    uint256 public sellPrice;
    uint256 public buyPrice;

    mapping (address => bool) public frozenAccount;

    /**
     * @notice This generates a public event on the blockchain that will notify clients
     */
    event FrozenFunds(address target, bool frozen);

    constructor(uint256 initialSupply, string memory tokenName, string memory tokenSymbol)
      ERC721Full(tokenName, tokenSymbol) public {
        _ownedTokensCount[owner].set(initialSupply);
        for (uint256 tokenId = 0; tokenId < initialSupply; tokenId++) {
            _tokenOwner[tokenId] = owner;
            _addTokenToOwnerEnumeration(owner, tokenId);
            _addTokenToAllTokensEnumeration(tokenId);
        }
    }

    /**
     * @notice Internal transfer, only can be called by this contract
     */
    function _transfer(address from, address to, uint256 tokenId) internal {
        require(!frozenAccount[from]);     // check if sender is frozen
        require(!frozenAccount[to]);       // check if recipient is frozen
        bytes memory data = abi.encodePacked(keccak256(abi.encodePacked(from, tokenId)));
        safeTransferFrom(from, to, tokenId, data);
    }

    /**
     * @notice Set allowance for other address and notify
     *         
     *         Allows `spender` to spend a token in sender's behalf, 
     *         and if spender is a contract ping the contract about it
     *
     * @param spender Address authorized to spend
     * @param tokenId Identifier of token they can spend
     */
    function approveAndCall(address spender, uint256 tokenId) public returns (bool success) {
        approve(spender, tokenId);
        require(_checkOnTicketReceived(spender, tokenId), "Transfer to non ITicketReceiver implementer");
        return true;
    }

    /**
     * @dev Internal function to invoke `onTicketReceived` on a target address.
     * The call is not executed if the target address is not a contract.
     * @param spender target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnTicketReceived(address spender, uint256 tokenId) internal returns (bool) {
        if (!spender.isContract()) return true;
        bytes32 hash = keccak256(abi.encodePacked(msg.sender, tokenId));
        ITicketReceiver ticketReceiver = ITicketReceiver(spender);
        bytes4 retval = ticketReceiver.onTicketReceived(msg.sender, hash);
        return (retval == ticketReceiver.onTicketReceived.selector);
    }

    /**
     * @notice Create `amount` number of tokens and send it to `target`
     * @param target Address to receive the tokens
     * @param amount Amount of tokens it will receive
     */
    function mintAmount(address target, uint256 amount) onlyOwner public {
        for (uint256 tokenId = 0; tokenId < 2**256-1 && amount > 0; tokenId++) {
            if (!_exists(tokenId)) {
                _mint(target, tokenId);
                amount--;
            }
        }
    }

    /**
     * @notice `freeze? Prevent | Allow` `target` from sending & receiving tokens
     * @param target Address to be frozen
     * @param freeze Either to freeze it or not
     */
    function freezeAccount(address target, bool freeze) onlyOwner public {
        frozenAccount[target] = freeze;
        emit FrozenFunds(target, freeze);
    }

    /**
     * @notice Allow users to buy tokens for `newBuyPrice` eth and sell tokens for `newSellPrice` eth
     * @param newSellPrice Price the users can sell to the contract
     * @param newBuyPrice Price users can buy from the contract
     */
    function setPrices(uint256 newSellPrice, uint256 newBuyPrice) onlyOwner public {
        sellPrice = newSellPrice;
        buyPrice = newBuyPrice;
    }

    /**
     * @notice Buy tokens from contract by sending ether
     */
    function buy() payable public {
        uint amount = msg.value / buyPrice;                        // calculates the amount
        require(balanceOf(address(this)) >= amount);
        for (uint256 i = 0; i < amount; i++) {
            _transfer(address(this), msg.sender, tokenByIndex(i)); // makes the transfers
        }
    }

    /**
     * @notice Sell token identified by `tokenId` to contract
     * @param tokenId Identifier of token to be sold
     */
    function sell(uint256 tokenId) public {
        _transfer(msg.sender, address(this), tokenId);      // makes the transfers
        msg.sender.transfer(sellPrice);                     // sends ether to the seller. It's important to do this last to avoid recursion attacks
    }
}
