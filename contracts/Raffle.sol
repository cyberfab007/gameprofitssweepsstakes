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

     /**
     * Called by players when they want to deposit tickets. The winner will be identified 
     * by the account belonging to the address of the sender depositing the tickets.
     *
     * @ _prizeToken the prize token which the player wants to deposit to make a bet
     * @ _ticketNumbers the ticket numbers on which the player deposits his prize token earnings
     */
    function deposit(address _prizeToken, uint256[] memory _ticketNumbers) public {
        
        // check the token a player is going to use is one of prize tokens
        require(prizeTokensInstances[_prizeToken] != MyAdvancedToken(0));

        MyAdvancedToken prizeTokenContract = MyAdvancedToken(_prizeToken);

        // check the player has enough prize token
        prizeTokenContract.balanceOf(msg.sender);
        
        // ...
        
        // save the bet
        bets[msg.sender] = _ticketNumbers;
    }

    function execute() public {

    }

    function verifyWinner() public {
  
    }

    function setName(string memory _name) onlyOwner public {
        name = _name;
    }
    function setPrizeTokens(address[] memory _prizeTokens) onlyOwner public {
        unsetPrizeTokensInstances();
        prizeTokens = _prizeTokens;
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
