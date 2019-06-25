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
      string    memory newName,
      address[] memory newPrizeTokens,
      uint256          newDepositLimit,
      uint256          newExecLimit,
      uint32           newExecTimestamp,
      uint32           newExecDelay,
      string    memory newSponsoredBy)
    public {

    setName(newName);
    setPrizeTokens(newPrizeTokens);
    setDepositLimit(newDepositLimit);
    setExecLimit(newExecLimit);
    setExecTimestamp(newExecTimestamp);
    setExecDelay(newExecDelay);
    setSponsoredBy(newSponsoredBy);
  }

  function deposit() public {

  }

  function execute() public {

  }

  function verifyWinner() public {
  
  }

  function setName(string memory newName) onlyOwner public {
    name = newName;
  }
  function setPrizeTokens(address[] memory newPrizeTokens) onlyOwner public {
    prizeTokens = newPrizeTokens;
  }
  function setDepositLimit(uint256 newDepositLimit) onlyOwner public {
    depositLimit = newDepositLimit;
  }
  function setExecLimit(uint256 newExecLimit) onlyOwner public {
    execLimit = newExecLimit;
  }
  function setExecTimestamp(uint32 newExecTimestamp) onlyOwner public {
    execTimestamp = newExecTimestamp;
  }
  function setExecDelay(uint32 newExecDelay) onlyOwner public {
    execDelay = newExecDelay;
  }
  function setSponsoredBy(string memory newSponsoredBy) onlyOwner public {
    sponsoredBy = newSponsoredBy;
  }
}
