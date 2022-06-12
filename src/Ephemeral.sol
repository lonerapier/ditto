// SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

interface IDittoFactory {
    function getDittoCode() external returns (bytes memory);
}

contract Ephemeral {
    constructor() {
        bytes memory _code = IDittoFactory(msg.sender).getDittoCode();

        address payable ditto;

        /* solhint-disable no-inline-assembly */
        assembly {
            ditto := create(callvalue(), add(0x20, _code), mload(_code))
        } /* solhint-enable no-inline-assembly */

        require(ditto != address(0), "Failed to create");

        selfdestruct(ditto);
    }
}
