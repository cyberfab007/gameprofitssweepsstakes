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

    mapping (address => bytes32) playerToHash;
    mapping (uint256 => address) numberToPlayer;

    uint256[] public numbers;
    uint256[] public winningNumbers;
    address public winner;

    enum LotteryState { FirstRound, SecondRound, Finished }
    LotteryState state;

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
        require(state == LotteryState.FirstRound);            // allow deposits in the first round only
        playerToHash[msg.sender] = bytesToBytes32(_data, 0);  // record that the player deposited the ticket to the raffle
        return this.onERC721Received.selector;                // must return this value. See ERC721._checkOnERC721Received()
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
