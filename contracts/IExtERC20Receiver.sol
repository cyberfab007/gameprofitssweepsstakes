pragma solidity ^0.5.0;

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
