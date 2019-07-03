pragma solidity >=0.4.22 <0.6.0;

import "./Counters.sol";
import "./Owned.sol";
import "./IERC20.sol";
import "./IExtERC20Receiver.sol";
import "./IERC721Receiver.sol";
import "./ITicketReceiver.sol";

contract Raffle is Owned, IExtERC20Receiver, IERC721Receiver, ITicketReceiver {
    using Counters for Counters.Counter;

    string    public name;
    address   public ticketToken;
    address[] public prizeTokens;
    bool      public prizeEtherAllowed;
    uint256   public depositLimit;
    uint256   public execLimit;
    uint32    public execTimestamp;
    uint32    public execDelay;
    string    public sponsoredBy;

    mapping (address => bytes32) playerToHash;
    mapping (uint256 => address) numberToPlayer;

    uint256[] public numbers;
    uint256[] public winningNumbers;
    address public winner;

    mapping (address => uint256)   public prizeERC20;
    mapping (address => uint256[]) public prizeERC721;

    enum LotteryState { FirstRound, SecondRound, Finished }
    LotteryState state;

    constructor(
          string    memory _name,
          address          _ticketToken,
          address[] memory _prizeTokens,
          bool             _prizeEtherAllowed,
          uint256          _depositLimit,
          uint256          _execLimit,
          uint32           _execTimestamp,
          uint32           _execDelay,
          string    memory _sponsoredBy)
      public {
        setName(_name);
        setTicketToken(_ticketToken);
        setPrizeTokens(_prizeTokens);
        setPrizeEtherAllowed(_prizeEtherAllowed);
        setDepositLimit(_depositLimit);
        setExecLimit(_execLimit);
        setExecTimestamp(_execTimestamp);
        setExecDelay(_execDelay);
        setSponsoredBy(_sponsoredBy);
    }

    /**
     * Called by someone who wants to deposit Ether to this contract
     *
     */
    function depositEther() public payable {
        require(state == LotteryState.FirstRound);            // allow deposits in the first round only
        require(prizeEtherAllowed);                           // check ether allowed as a prize token
        require(owner == msg.sender);                         // accept deposits from owner's account only
                            // address(this).balance to see total deposit
    }

    /**
     * Called by someone who approved ERC20 tokens to this contract, if the ERC20 token does not notify this contract itself
     *
     */
    function depositERC20(address token, uint256 value) public onlyOwner {
        require(state == LotteryState.FirstRound);            // allow deposits in the first round only
        require(isPrizeToken(token));                         // check deposited token is one of prize tokens
        require(owner == msg.sender);                         // accept deposits from owner's account only
        IERC20(token).transferFrom(msg.sender, address(this), value);  // complete the transfer
        prizeERC20[token] += value;                           // record the deposit
    }

    /**
     * Called by ERC20 token contracts, when someone sends such a token to this contract
     *
     */
    function receiveApproval(address from, uint256 value, address token, bytes memory data) public onlyOwner {
        require(state == LotteryState.FirstRound);            // allow deposits in the first round only
        require(isPrizeToken(token));                         // check deposited token is one of prize tokens
        require(owner == from);                               // accept deposits from owner's account only
        prizeERC20[token] += value;                           // record the deposit
    }

    /**
     * Called by ERC721 token contracts, when someone sends such a token to this contract
     *
     */
    function onERC721Received(address token, address from, uint256 tokenId, bytes memory data) public onlyOwner returns (bytes4) {
        require(state == LotteryState.FirstRound);            // allow deposits in the first round only
        require(isPrizeToken(token));                         // check deposited token is one of prize tokens
        require(owner == from);                               // accept deposits from owner's account only
        prizeERC721[token].push(tokenId);                     // record the deposit
        return this.onERC721Received.selector;                // must return this value. See ERC721._checkOnERC721Received()
    }

    /**
     * Called by Ticket token contracts, when someone sends such a Ticket to this contract
     * NOTE: we must not reveal the token sender address and the token id at this step - they are passed in as a hash, packed and encrypted 
     */
    function onTicketReceived(address token, bytes32 hash) public returns (bytes4) {
        require(state == LotteryState.FirstRound);            // allow ticket deposits in the first round only
        require(token == ticketToken);                        // check deposited ticket can be used in this raffle
        playerToHash[msg.sender] = hash;                      // record that the player deposited the ticket to the raffle
        return this.onTicketReceived.selector;                // must return this value. See ERC721._checkOnERC721Received()
    }


    function runSecondRound() public onlyOwner {
        require(state == LotteryState.FirstRound);
        state = LotteryState.SecondRound;
    }
    
    function claimTickets(uint256 number) public {
        require(state == LotteryState.SecondRound);                                     // allow claiming ticket numbers in the second round only
        require(keccak256(abi.encode(number, msg.sender)) == playerToHash[msg.sender]); // check msg.sender submitted the number in the first number
        numberToPlayer[number] = msg.sender;
        numbers.push(number);
    }

    function execute() public onlyOwner {
        require(state == LotteryState.SecondRound);  // allow raffle execution in the second round only
        state = LotteryState.Finished;

        uint256 seedNumberIndex = 0;
        for (uint256 i = 0; i < 10; i++) {
            uint256 randomNumber = numbers[getRandomNumberIndex(seedNumberIndex)];
            seedNumberIndex = winningNumbers.push(randomNumber);
        }
        
        verifyWinner();
    }

    function verifyWinner() private {
        for (uint256 i = 0; i < winningNumbers.length; i++) {
            winner = numberToPlayer[winningNumbers[i]];
            // TODO verification
            if (winner != address(0)) {
                break;
            }
        }
        distributeFunds();
    }

    function distributeFunds() private {
        // TODO
    }

    function getRandomNumberIndex(uint256 seedNumberIndex) private view returns (uint256) {
        uint256 seed = numbers[seedNumberIndex];
        for (uint256 i = 1; i < numbers.length; ++i) {
            seed ^= numbers[i];
        }
        return seed % numbers.length;
    }
    function bytesToBytes32(bytes memory b, uint offset) private pure returns (bytes32) {
        bytes32 out;
        for (uint i = 0; i < 32; i++) {
            out |= bytes32(b[offset + i] & 0xFF) >> (i * 8);
        }
        return out;
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
    function setTicketToken(address _ticketToken) onlyOwner public {
        ticketToken = _ticketToken;
    }
    function setPrizeTokens(address[] memory _prizeTokens) onlyOwner public {
        prizeTokens = _prizeTokens;
    }
    function setPrizeEtherAllowed(bool _prizeEtherAllowed) onlyOwner public {
        prizeEtherAllowed = _prizeEtherAllowed;
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
