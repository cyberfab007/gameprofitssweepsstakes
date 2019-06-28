pragma solidity >=0.4.22 <0.6.0;

import "./Owned.sol";
import "./IERC721Receiver.sol";
import "./Counters.sol";

contract Raffle is Owned, IERC721Receiver {
    using Counters for Counters.Counter;

    string    public name;
    address[] public prizeTokens;
    uint256   public depositLimit;
    uint256   public execLimit;
    uint32    public execTimestamp;
    uint32    public execDelay;
    string    public sponsoredBy;

    mapping (uint256 => address) public addressByTicket;
    Counters.Counter public ticketsCounter;

    constructor(
          string    memory _name,
          address[] memory _prizeTokens,
          uint256          _depositLimit,
          uint256          _execLimit,
          uint32           _execTimestamp,
          uint32           _execDelay,
          string    memory _sponsoredBy)
      public {
        setName(_name);
        setPrizeTokens(_prizeTokens);
        setDepositLimit(_depositLimit);
        setExecLimit(_execLimit);
        setExecTimestamp(_execTimestamp);
        setExecDelay(_execDelay);
        setSponsoredBy(_sponsoredBy);
    }

    function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes memory _data)
      public returns (bytes4) {
        require(isPrizeToken(msg.sender));       // check msg.sender is a prize token

        if (addressByTicket[_tokenId] == address(0)) { // if the ticket is used for the first time - 
            ticketsCounter.increment();                // increment ticket counted to compare to execLimit later
        }
        addressByTicket[_tokenId] = _from;       // record that the player deposited the ticket to the raffle (overwrite if necessary)

        return this.onERC721Received.selector;   // must return this value. See ERC721._checkOnERC721Received()
    }

    function execute() public {

    }

    function verifyWinner() public {
        
    }

    function isPrizeToken(address a) private view returns (bool) {
        for (uint256 i = 0; i < prizeTokens.length; i++) {
            if (a == prizeTokens[i]) {
                return true;
            }
        }
        return false;
    }

    function setName(string memory _name) onlyOwner public {
        name = _name;
    }
    function setPrizeTokens(address[] memory _prizeTokens) onlyOwner public {
        prizeTokens = _prizeTokens;
    }
    function setDepositLimit(uint256 _depositLimit) onlyOwner public {
        depositLimit = _depositLimit;
    }
    function setExecLimit(uint256 _execLimit) onlyOwner public {
        execLimit = _execLimit;
    }
    function setExecTimestamp(uint32 _execTimestamp) onlyOwner public {
        execTimestamp = _execTimestamp;
    }
    function setExecDelay(uint32 _execDelay) onlyOwner public {
        execDelay = _execDelay;
    }
    function setSponsoredBy(string memory _sponsoredBy) onlyOwner public {
        sponsoredBy = _sponsoredBy;
    }
}
