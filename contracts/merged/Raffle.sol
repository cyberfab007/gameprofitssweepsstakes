pragma solidity >=0.4.22 <0.6.0;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * This test is non-exhaustive, and there may be false-negatives: during the
     * execution of a contract's constructor, its address will be reported as
     * not containing a contract.
     *
     * > It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies in extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    /**
     * @dev Converts an `address` into `address payable`. Note that this is
     * simply a type cast: the actual underlying value is not changed.
     */
    function toPayable(address account) internal pure returns (address payable) {
        return address(uint160(account));
    }
}

library Util {

    function bytes2bytes32(bytes memory arg, uint offset) public pure returns (bytes32) {
        bytes32 out;
        for (uint i = 0; i < 32; i++) {
            out |= bytes32(arg[offset + i] & 0xFF) >> (i * 8);
        }
        return out;
    }

    function uint2str(uint arg) public pure returns (string memory) {
        if (arg == 0) {
            return "0";
        }
        uint j = arg;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len - 1;
        while (arg != 0) {
            bstr[k--] = byte(uint8(48 + arg % 10));
            arg /= 10;
        }
        return string(bstr);
    }

    function addr2str(address arg) public pure returns (string memory) {
        bytes32 value = bytes32(uint256(arg));
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
}

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, string(abi.encodePacked("SafeMath: subtraction overflow: ", Util.uint2str(a), " - ", Util.uint2str(b))));
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented or decremented by one. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 * Since it is not possible to overflow a 256 bit integer with increments of one, `increment` can skip the SafeMath
 * overflow check, thereby saving gas. This does assume however correct usage, in that the underlying `_value` is never
 * directly accessed.
 */
library Counters {
    using SafeMath for uint256;

    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        counter._value += 1;
    }

    function decrement(Counter storage counter) internal {
        counter._value = counter._value.sub(1);
    }
}

contract Owned {

    address public owner;

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner, "Allowed only for the owner");
        _;
    }

    function transferOwnership(address newOwner) onlyOwner public {
        owner = newOwner;
    }
}

/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see `ERC20Detailed`.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a `Transfer` event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through `transferFrom`. This is
     * zero by default.
     *
     * This value changes when `approve` or `transferFrom` are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * > Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an `Approval` event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a `Transfer` event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to `approve`. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * [EIP](https://eips.ethereum.org/EIPS/eip-165).
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others (`ERC165Checker`).
 *
 * For an implementation, see `ERC165`.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * [EIP section](https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified)
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
contract IERC721 is IERC165 {
    event Transfer721(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval721(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll721(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of NFTs in `owner`'s account.
     */
    function balanceOf(address owner) public view returns (uint256 balance);

    /**
     * @dev Returns the owner of the NFT specified by `tokenId`.
     */
    function ownerOf(uint256 tokenId) public view returns (address owner);

    /**
     * @dev Transfers a specific NFT (`tokenId`) from one account (`from`) to
     * another (`to`).
     *
     * 
     *
     * Requirements:
     * - `from`, `to` cannot be zero.
     * - `tokenId` must be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this
     * NFT by either `approve` or `setApproveForAll`.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) public;
    /**
     * @dev Transfers a specific NFT (`tokenId`) from one account (`from`) to
     * another (`to`).
     *
     * Requirements:
     * - If the caller is not `from`, it must be approved to move this NFT by
     * either `approve` or `setApproveForAll`.
     */
    function transferFrom(address from, address to, uint256 tokenId) public;
    function approve(address to, uint256 tokenId) public;
    function getApproved(uint256 tokenId) public view returns (address operator);

    function setApprovalForAll(address operator, bool _approved) public;
    function isApprovedForAll(address owner, address operator) public view returns (bool);


    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public;
}

/**
 * @title ERC20 token receiver interface
 * @dev Interface for any contract that wants to support transfers from ERC20 asset contracts.
 */
interface IExtERC20Receiver {
    /**
     * @notice Handle the receipt of an ERC20 token
     * @dev The ERC20 smart contract calls this function on the recipient on `approveAndCall`.
     * @param from The address which previously owned the token
     * @param value The amount of tokens being transferred
     * @param token The address of the ERC20 token which called the function
     * @param data Additional data with no specified format
     */
    function receiveApproval(address from, uint256 value, address token, bytes calldata data) external;
}

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
contract IERC721Receiver {
    /**
     * @notice Handle the receipt of an NFT
     * @dev The ERC721 smart contract calls this function on the recipient
     * after a `safeTransfer`. This function MUST return the function selector,
     * otherwise the caller will revert the transaction. The selector to be
     * returned can be obtained as `this.onERC721Received.selector`. This
     * function MAY throw to revert and reject the transfer.
     * Note: the ERC721 contract address is always the message sender.
     * @param operator The address which called `safeTransferFrom` function
     * @param from The address which previously owned the token
     * @param tokenId The NFT identifier which is being transferred
     * @param data Additional data with no specified format
     * @return bytes4 `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`
     */
    function onERC721Received(address operator, address from, uint256 tokenId, bytes memory data)
    public returns (bytes4);
}

/**
 * @title Ticket token receiver interface
 * @dev Interface for any contract that wants to support deposits from Ticket contracts.
 */
contract ITicketReceiver {
    /**
     * @notice Handle the receipt of a Ticket
     * @dev The Ticket smart contract calls this function on the recipient
     * after a `deposit`. This function MUST return the function selector,
     * otherwise the caller will revert the transaction. The selector to be
     * returned can be obtained as `this.onTicketReceived.selector`.
     * This function MAY throw to revert and reject the transfer.
     * @param from The address which previously owned the token
     * @param hash Keccak256 hash of the NFT sender and its identifier
     * @return bytes4 `bytes4(keccak256("onTicketReceived(address,bytes32)"))`
     */
    function onTicketReceived(address from, bytes32 hash) public returns (bytes4);
}

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