pragma solidity ^0.5.0;

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
