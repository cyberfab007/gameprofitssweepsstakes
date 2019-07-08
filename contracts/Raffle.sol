pragma solidity >=0.4.22 <0.6.0;

import "./Address.sol";
import "./Counters.sol";
import "./Owned.sol";
import "./Util.sol";
import "./IERC20.sol";
import "./IERC721.sol";
import "./IExtERC20Receiver.sol";
import "./IERC721Receiver.sol";
import "./ITicketReceiver.sol";

contract Raffle is Owned, IExtERC20Receiver, IERC721Receiver, ITicketReceiver {
    using Address for address;
    using Counters for Counters.Counter;

    /**
     * The name of the raffle
     */
    string    public name;

    /**
     * Ethereum addresses of the ticket token contract
     */
    address   public ticketToken;

    /**
     * Ethereum addresses of the prize token contracts
     */
    address[] public prizeTokens;

    /**
     * Whether ETH deposits allowed to this raffle or not
     */
    bool      public prizeEtherAllowed;

    /**
     * The max number of tickets that one player is allowed to pledge
     * NOTE: if set to 0 there is no deposit limit
     */
    uint256   public depositLimit;

    /**
     * The amount of tickets that must be pledged before the raffle can be executed
     * NOTE: If set to 0, use exec_timestamp condition; otherwise use exec_delay condition
     */ 
    uint256   public execLimit;

    /**
     * A UNIX timestamp (in seconds), representing datetime when execLimit reached
     */ 
    uint256   public execLimitTimestamp;

    /**
     * A UNIX timestamp (in seconds), representing datetime after which the raffle can be executed
     */ 
    uint32    public execTimestamp;

    /**
     * The delay (in seconds) after exec_limit reached and before the raffle can be executed.
     */  
    uint32    public execDelay;

    /**
     * The name of the sponsor
     */
    string    public sponsoredBy;

    /**
     * Players and their hashes (can be multiple) submitted in the 1st round
     */
    mapping (address => bytes32[]) private playerToHashes;

    /**
     * Ticket numbers claimed by players in the 2nd round
     */
    mapping (uint256 => address) private numberToPlayer;

    /**
     * All ticket numbers involved into the raffle
     */
    uint256[] public numbers;

    /**
     * It is more robust to define several winning numbers,
     * because in case if the first one belongs to a person 
     * who is not eligible for prize receival,
     * we can give it to the next one, etc.
     */
    uint8 constant private winnersLengthMax = 10;
    address[] public winners;
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




    event LogERC20Allowance(address from, address to, uint256 value);


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
        require(isPrizeToken(token), string(abi.encodePacked("Deposit ERC20: wrong prize token ", Util.addr2str(msg.sender))));
        require(owner == from, "Deposit ERC20: Depositor is not raffle owner");
        prizeERC20[token] += value;                   // record the deposit
    }

    /**
     * Called by ERC721 token contracts, when someone deposits such a token to this contract
     *
     */
    function onERC721Received(address operator, address from, uint256 tokenId, bytes memory data) public onlyFirstRound returns (bytes4) {
        if (msg.sender != ticketToken) {
            require(isPrizeToken(msg.sender), string(abi.encodePacked("Deposit ERC721: wrong prize token ", Util.addr2str(msg.sender))));
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
        require(msg.sender == ticketToken, string(abi.encodePacked("Deposit Ticket: wrong ticket token ", Util.addr2str(msg.sender))));
        if (depositLimit > 0) {
            require(playerToHashes[from].length < depositLimit, "Deposit Ticket: depositLimit reached");
        }
        playerToHashes[from].push(hash);              // record the deposit
        return this.onTicketReceived.selector;        // must return this value. See Ticket._checkOnTicketReceived()
    }


    function runSecondRound() public onlyOwner onlyFirstRound {
        state = LotteryState.SecondRound;
    }
    
    function claimTicket(uint256 number) public onlySecondRound {
        bool hashExists;
        for (uint256 i = 0; i < playerToHashes[msg.sender].length; i++) {
            if (keccak256(abi.encodePacked(msg.sender, number)) == playerToHashes[msg.sender][i]) {
                hashExists = true;
                break;
            }
        }
        require(hashExists, "Claim Ticket: wrong hash");
        numberToPlayer[number] = msg.sender;
        numbers.push(number);
        if (execLimit > 0 && numbers.length == execLimit) {
            execLimitTimestamp = now;
        }
    }

    function execute() public onlyOwner onlySecondRound {
        if (execLimit > 0) {
            require(execLimitTimestamp > 0, "Execution not allowed: execLimit is not reached yet");
            require(now >= (execLimitTimestamp + execDelay), "Execution not allowed: execDelay is not reached yet");
        } else {
            require(now >= execTimestamp, "Execution not allowed: execTimestamp is not reached yet");
        }
        state = LotteryState.Finished;
        uint256 winnersLength = numbers.length > winnersLengthMax ? winnersLengthMax : numbers.length;
        uint256 seedNumberIndex = 0;
        for (uint256 i = 0; i < winnersLength; i++) {
            uint256 randomNumber = numbers[getRandomNumberIndex(seedNumberIndex)];
            seedNumberIndex = winningNumbers.push(randomNumber);
            winners.push(numberToPlayer[randomNumber]);
        }
    }

    function giveAwayPrize(uint256 winnerIndex) public onlyOwner {
        winner = winners[winnerIndex];
        require(state == LotteryState.Finished, "Allowed after the 2nd round only");
        if (prizeEtherAllowed && address(this).balance > 0) {
            winner.toPayable().transfer(address(this).balance);
        }
        for (uint256 i = 0; i < prizeTokens.length; i++) {
            if (prizeERC20[prizeTokens[i]] > 0) {
                IERC20 token = IERC20(prizeTokens[i]);
                uint256 allowance = token.allowance(owner, address(this));
                emit LogERC20Allowance(owner, address(this), allowance);
                token.transferFrom(owner, winner, allowance);
            }
            if (prizeERC721[prizeTokens[i]].length > 0) {
                IERC721 token = IERC721(prizeTokens[i]);
                for (uint256 j = 0; j < prizeERC721[prizeTokens[i]].length; j++) {
                    token.safeTransferFrom(address(this), winner, prizeERC721[prizeTokens[i]][j]); 
                }               
            }
        }
    }

    function getRandomNumberIndex(uint256 seedNumberIndex) private view returns (uint256) {
        uint256 seed = numbers[seedNumberIndex];
        for (uint256 i = 1; i < numbers.length; ++i) {
            seed ^= numbers[i];
        }
        return seed % numbers.length;
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
        require(_ticketToken != address(0), "_ticketToken == address(0)");
        ticketToken = _ticketToken;
    }
    function setPrizeTokens(address[] memory _prizeTokens) onlyOwner public {
        prizeTokens = _prizeTokens;
    }
    function setPrizeEtherAllowed(bool _prizeEtherAllowed) onlyOwner public {
        prizeEtherAllowed = _prizeEtherAllowed;
    }
    function setDepositLimit(uint256 _depositLimit) onlyOwner public {
        require(_depositLimit >= 0, "depositLimit < 0");
        depositLimit = _depositLimit;
    }
    function setExecLimit(uint256 _execLimit) onlyOwner public {
        require(_execLimit >= 0, "execLimit < 0");
        execLimit = _execLimit;
    }
    function setExecTimestamp(uint32 _execTimestamp) onlyOwner public {
        if (execLimit > 0) {
            require(_execTimestamp == 0, "execTimestamp != 0 when execLimit > 0");
        } else {
            require(_execTimestamp > now, "execTimestamp <= now when execLimit !> 0");
        }
        execTimestamp = _execTimestamp;
    }
    function setExecDelay(uint32 _execDelay) onlyOwner public {
        require(_execDelay >= 0, "execDelay < 0");
        execDelay = _execDelay;
    }
    function setSponsoredBy(string memory _sponsoredBy) onlyOwner public {
        sponsoredBy = _sponsoredBy;
    }
}
