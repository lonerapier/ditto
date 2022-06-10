// SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

contract Impl {
    uint256 private _x = 1;

    function initialize() public {
        _x = 2;
    }

    function getX() public view returns (uint256) {
        return _x;
    }

    function destroy() public {
        selfdestruct(payable(msg.sender));
    }
}
