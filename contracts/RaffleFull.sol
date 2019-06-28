pragma solidity >=0.4.22 <0.6.0;

contract Owned {

    address public owner;

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) onlyOwner public {
        owner = newOwner;
    }
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

contract Raffle is Owned, IERC721Receiver {
    using Counters for Counters.Counter;

    string    public name;
    address[] public prizeTokens;
    uint256   public depositLimit;
    uint256   public execLimit;
    uint32    public execTimestamp;
    uint32    public execDelay;
    string    public sponsoredBy;

    mapping (uint256 => address) public addressByTicket;
    Counters.Counter public ticketsCounter;

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
        require(isPrizeToken(msg.sender));       // check msg.sender is a prize token

        if (addressByTicket[_tokenId] == address(0)) { // if the ticket is used for the first time - 
            ticketsCounter.increment();                // increment ticket counted to compare to execLimit later
        }
        addressByTicket[_tokenId] = _from;       // record that the player deposited the ticket to the raffle (overwrite if necessary)

        return this.onERC721Received.selector;   // must return this value. See ERC721._checkOnERC721Received()
    }

    function execute() public {

    }

    function verifyWinner() public {
        
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
