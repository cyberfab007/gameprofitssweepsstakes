pragma solidity >=0.4.22 <0.6.0;

import "./Owned.sol";
import "./ERC721Full.sol";

contract Ticket is Owned, ERC721Full {

    uint256 public sellPrice;
    uint256 public buyPrice;

    mapping (address => bool) public frozenAccount;

    /* This generates a public event on the blockchain that will notify clients */
    event FrozenFunds(address target, bool frozen);

    constructor(
        string memory tokenName,
        string memory tokenSymbol
    ) ERC721Full(tokenName, tokenSymbol) public {}

    /**
     * Set allowance for other address and notify
     *
     * Allows `_spender` to spend token identified by `_tokenId` in your behalf, and then ping the contract about it
     *
     * @param _spender The address authorized to spend
     * @param _tokenId id of token they can spend
     * @param _data some extra information to send to the approved contract
     */
    function approveAndCall(address _spender, uint256 _tokenId, bytes memory _data) public returns (bool success) {
        approve(_to, _tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
        return true;
    }

    /* Internal transfer, only can be called by this contract */
    function _transfer(address _from, address _to, uint256 _tokenId) internal {
        require(!frozenAccount[_from]);     // check if sender is frozen
        require(!frozenAccount[_to]);       // check if recipient is frozen
        safeTransferFrom(_from, _to, _tokenId, keccak256(_from, _tokenId));
    }

    /// @notice Create `amount` tokens and send it to `target`
    /// @param target address to receive the tokens
    /// @param amount the amount of tokens it will receive
    function mintAmount(address target, uint256 amount) onlyOwner public {
        for (uint256 tokenId = 0; tokenId < 2**256-1 && amount > 0; tokenId++) {
            if (!_exists(tokenId)) {
                _mint(target, tokenId);
                amount--;
            }
        }
    }

    /// @notice `freeze? Prevent | Allow` `target` from sending & receiving tokens
    /// @param target Address to be frozen
    /// @param freeze either to freeze it or not
    function freezeAccount(address target, bool freeze) onlyOwner public {
        frozenAccount[target] = freeze;
        emit FrozenFunds(target, freeze);
    }

    /// @notice Allow users to buy tokens for `newBuyPrice` eth and sell tokens for `newSellPrice` eth
    /// @param newSellPrice Price the users can sell to the contract
    /// @param newBuyPrice Price users can buy from the contract
    function setPrices(uint256 newSellPrice, uint256 newBuyPrice) onlyOwner public {
        sellPrice = newSellPrice;
        buyPrice = newBuyPrice;
    }

    /// @notice Buy tokens from contract by sending ether
    function buy() payable public {
        uint amount = msg.value / buyPrice;                        // calculates the amount
        require(balanceOf(address(this)) >= amount);
        for (uint256 i = 0; i < amount; i++) {
            _transfer(address(this), msg.sender, tokenByIndex(i)); // makes the transfers
        }
    }

    /// @notice Sell token identified by `tokenId` to contract
    /// @param tokenId id of token to be sold
    function sell(uint256 tokenId) public {
        _transfer(msg.sender, address(this), tokenId);      // makes the transfers
        msg.sender.transfer(sellPrice);                     // sends ether to the seller. It's important to do this last to avoid recursion attacks
    }

    function deposit(address raffle, uint256 tokenId) public {
        _transfer(msg.sender, raffle, tokenId);
    }
}
