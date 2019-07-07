pragma solidity >=0.4.22 <0.6.0;

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
        require(b <= a, "SafeMath: subtraction overflow");
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
        require(msg.sender == owner, "Sender is not owner");
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

    // token address to amount of tokens
    mapping (address => uint256)   public prizeERC20;
    // token address to array of token ids
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
    function depositEther()
      public payable onlyOwner {
        require(state == LotteryState.FirstRound);            // allow deposits in the first round only
        require(prizeEtherAllowed);                           // check ether allowed as a prize token
        require(owner == msg.sender);                         // accept deposits from owner's account only
                            // address(this).balance to see total deposit
    }

    /**
     * Called by ERC20 token contracts, when someone deposits such a token to this contract
     * NOTE: If some ERC20 token contract doesn't implement calling this method, the depositor must call it manually 
     */
    function receiveApproval(address from, uint256 value, address token, bytes memory data)
      public {
        require(state == LotteryState.FirstRound);            // allow deposits in the first round only
        require(isPrizeToken(token));                         // check deposited token is one of prize tokens
        require(owner == from);                               // accept deposits from owner's account only
        prizeERC20[token] += value;                           // record the deposit
    }

    /**
     * Called by ERC721 token contracts, when someone deposits such a token to this contract
     *
     */
    function onERC721Received(address operator, address from, uint256 tokenId, bytes memory data)
      public returns (bytes4) {
        if (msg.sender != ticketToken) {
            require(state == LotteryState.FirstRound, "Deposit: not allowed in this round");
            require(isPrizeToken(msg.sender), string(abi.encodePacked("Deposit: wrong prize token ", addr2str(msg.sender))));
            require(owner == from, "Deposite: Depositor is not raffle owner");
            prizeERC721[msg.sender].push(tokenId);    // record the deposit
        }
        return this.onERC721Received.selector;        // must return this value. See ERC721._checkOnERC721Received()
    }

    /**
     * Called by Ticket token contracts, when someone deposits such a Ticket to this contract
     * NOTE: We must not reveal the token sender address and the token id at this step - they are passed in as a hash, packed and encrypted
     * NOTE2: We could also add a password provided by a Ticket depositor, so the hash will consist of (owner address + ticket number + password)
     */
    function onTicketReceived(address from, bytes32 hash)
      public returns (bytes4) {
        require(state == LotteryState.FirstRound, "Deposit: not allowed in this round");
        require(msg.sender == ticketToken, string(abi.encodePacked("Deposit: wrong ticket token ", addr2str(msg.sender))));
        playerToHash[from] = hash;                // record the deposit
        return this.onTicketReceived.selector;    // must return this value. See Ticket._checkOnTicketReceived()
    }


    function runSecondRound() public onlyOwner {
        require(state == LotteryState.FirstRound);
        state = LotteryState.SecondRound;
    }
    
    function claimTickets(uint256 number) public {
        require(state == LotteryState.SecondRound, "Claim: not allowed in this round");
        require(keccak256(abi.encodePacked(msg.sender, number)) == playerToHash[msg.sender], "Claim: wrong hash");
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