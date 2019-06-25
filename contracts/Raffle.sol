pragma solidity >=0.4.22 <0.6.0;

import "./Owned.sol";
import "./Token.sol";

contract Raffle is Owned {

    string    public name;
    address[] public prizeTokens;
    uint256   public depositLimit;
    uint256   public execLimit;
    uint32    public execTimestamp;
    uint32    public execDelay;
    string    public sponsoredBy;

    mapping (address => uint256[]) public bets;
    mapping (address => MyAdvancedToken) prizeTokensInstances;

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

     /**
     * Called by players when they want to deposit tickets. The winner will be identified 
     * by the account belonging to the address of the sender depositing the tickets.
     *
     * @param prizeToken the prize token which the player wants to deposit to make a bet
     * @param ticketNumbers the ticket numbers on which the player deposits his prize token earnings
     */
    function deposit(address prizeToken, uint256[] memory ticketNumbers) public {
        
        // check the token a player is going to use is one of prize tokens
        require(prizeTokensInstances[prizeToken] != MyAdvancedToken(0));

        MyAdvancedToken prizeTokenContract = MyAdvancedToken(prizeToken);

        // check the player has enough prize token
        prizeTokenContract.balanceOf(msg.sender);
        
        
        // save the bet
        bets[msg.sender] = ticketNumbers;
    }

    function execute() public {

    }

    function verifyWinner() public {
  
    }

    function setName(string memory paramName) onlyOwner public {
        name = paramName;
    }
    function setPrizeTokens(address[] memory paramPrizeTokens) onlyOwner public {
        unsetPrizeTokensInstances();
        prizeTokens = paramPrizeTokens;
        setPrizeTokensInstances();
    }
    function unsetPrizeTokensInstances() private {
        for (uint256 i=0; i<prizeTokens.length; i++) {
            prizeTokensInstances[prizeTokens[i]] = MyAdvancedToken(0);
        }
    }
    function setPrizeTokensInstances() private {
        for (uint256 i=0; i<prizeTokens.length; i++) {
            prizeTokensInstances[prizeTokens[i]] = MyAdvancedToken(prizeTokens[i]);
        }
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
