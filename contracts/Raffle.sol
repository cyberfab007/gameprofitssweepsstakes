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


    // prize token address to amount of prize tokens
    mapping (address => uint256)   public prizeERC20;

    // prize token address to array of prize token ids
    mapping (address => uint256[]) public prizeERC721;


    enum LotteryState { FirstRound, SecondRound, Finished }

    LotteryState state;

    modifier onlyFirstRound {
        require(state == LotteryState.FirstRound, "Allowed in the 1st round only");
        _;
    }

    modifier onlySecondRound {
        require(state == LotteryState.SecondRound, "Allowed in the 2nd round only");
        _;
    }


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


    /*** DEPOSIT LOGIC ***/

    /**
     * Called by someone who wants to deposit Ether to this contract
     *
     */
    function depositEther() public payable onlyOwner onlyFirstRound {
        require(prizeEtherAllowed, "Deposit: ether deposits not allowed");
    }

    /**
     * Called by ERC20 token contracts, when someone deposits such a token to this contract
     * NOTE: If some ERC20 token contract doesn't implement calling this method, the depositor must call it manually 
     */
    function receiveApproval(address from, uint256 value, address token, bytes memory data) public onlyFirstRound {
        require(isPrizeToken(token), string(abi.encodePacked("Deposit ERC20: wrong prize token ", addr2str(msg.sender))));
        require(owner == from, "Deposit ERC20: Depositor is not raffle owner");
        prizeERC20[token] += value;                   // record the deposit
    }

    /**
     * Called by ERC721 token contracts, when someone deposits such a token to this contract
     *
     */
    function onERC721Received(address operator, address from, uint256 tokenId, bytes memory data) public onlyFirstRound returns (bytes4) {
        if (msg.sender != ticketToken) {
            require(isPrizeToken(msg.sender), string(abi.encodePacked("Deposit ERC721: wrong prize token ", addr2str(msg.sender))));
            require(owner == from, "Deposit ERC721: Depositor is not raffle owner");
            prizeERC721[msg.sender].push(tokenId);    // record the deposit
        }
        return this.onERC721Received.selector;        // must return this value. See ERC721._checkOnERC721Received()
    }

    /**
     * Called by Ticket token contracts, when someone deposits such a Ticket to this contract
     * NOTE: We must not reveal the token sender address and the token id at this step - they are passed in as a hash, packed and encrypted
     * NOTE2: We could also add a password provided by a Ticket depositor, so the hash will consist of (owner address + ticket number + password)
     */
    function onTicketReceived(address from, bytes32 hash) onlyFirstRound public returns (bytes4) {
        require(msg.sender == ticketToken, string(abi.encodePacked("Deposit Ticket: wrong ticket token ", addr2str(msg.sender))));
        playerToHash[from] = hash;                    // record the deposit
        return this.onTicketReceived.selector;        // must return this value. See Ticket._checkOnTicketReceived()
    }


    function runSecondRound() public onlyOwner onlyFirstRound {
        state = LotteryState.SecondRound;
    }
    
    function claimTicket(uint256 number) public onlySecondRound {
        require(keccak256(abi.encodePacked(msg.sender, number)) == playerToHash[msg.sender], "Claim Ticket: wrong hash");
        numberToPlayer[number] = msg.sender;
        numbers.push(number);
    }

    function execute() public onlyOwner onlySecondRound {
        state = LotteryState.Finished;

        uint256 seedNumberIndex = 0;
        for (uint256 i = 0; i < 4; i++) {
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

    function bytes2bytes32(bytes memory b, uint offset) private pure returns (bytes32) {
        bytes32 out;
        for (uint i = 0; i < 32; i++) {
            out |= bytes32(b[offset + i] & 0xFF) >> (i * 8);
        }
        return out;
    }

    function uint2str(uint _i) private pure returns (string memory) {
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len - 1;
        while (_i != 0) {
            bstr[k--] = byte(uint8(48 + _i % 10));
            _i /= 10;
        }
        return string(bstr);
    }

    function isPrizeToken(address a) private view returns (bool) {
        for (uint256 i = 0; i < prizeTokens.length; i++) {
            if (a == prizeTokens[i]) {
                return true;
            }
        }
        return false;
    }

    function addr2str(address _addr) private pure returns(string memory) {
        bytes32 value = bytes32(uint256(_addr));
        bytes memory alphabet = "0123456789abcdef";

        bytes memory str = new bytes(42);
        str[0] = '0';
        str[1] = 'x';
        for (uint i = 0; i < 20; i++) {
            str[2+i*2] = alphabet[uint(uint8(value[i + 12] >> 4))];
            str[3+i*2] = alphabet[uint(uint8(value[i + 12] & 0x0f))];
        }
        return string(str);
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
