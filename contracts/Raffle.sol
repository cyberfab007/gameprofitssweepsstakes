pragma solidity >=0.4.22 <0.6.0;

import "./Owned.sol";

contract Raffle is Owned {

    string    public name;
    address[] public prizeTokens;
    uint256   public depositLimit;
    uint256   public execLimit;
    uint32    public execTimestamp;
    uint32    public execDelay;
    string    public sponsoredBy;

    constructor(
          string    memory paramName,
          address[] memory paramPrizeTokens,
          uint256          paramDepositLimit,
          uint256          paramExecLimit,
          uint32           paramExecTimestamp,
          uint32           paramExecDelay,
          string    memory paramSponsoredBy)
      public {

        setName(paramName);
        setPrizeTokens(paramPrizeTokens);
        setDepositLimit(paramDepositLimit);
        setExecLimit(paramExecLimit);
        setExecTimestamp(paramExecTimestamp);
        setExecDelay(paramExecDelay);
        setSponsoredBy(paramSponsoredBy);
    }

    function deposit() public {

    }

    function execute() public {

    }

    function verifyWinner() public {
  
    }

    function setName(string memory paramName) onlyOwner public {
        name = paramName;
    }
    function setPrizeTokens(address[] memory paramPrizeTokens) onlyOwner public {
        prizeTokens = paramPrizeTokens;
    }
    function setDepositLimit(uint256 paramDepositLimit) onlyOwner public {
        depositLimit = paramDepositLimit;
    }
    function setExecLimit(uint256 paramExecLimit) onlyOwner public {
        execLimit = paramExecLimit;
    }
    function setExecTimestamp(uint32 paramExecTimestamp) onlyOwner public {
        execTimestamp = paramExecTimestamp;
    }
    function setExecDelay(uint32 paramExecDelay) onlyOwner public {
        execDelay = paramExecDelay;
    }
    function setSponsoredBy(string memory paramSponsoredBy) onlyOwner public {
        sponsoredBy = paramSponsoredBy;
    }
}
