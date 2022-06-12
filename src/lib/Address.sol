// SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

library Address {
	function getCreateAddress(address _proxy) public pure returns (address) {
		return address(uint160(uint256(keccak256(abi.encodePacked(hex"d6", hex"94", _proxy, hex"01")))));
	}

	function getCreate2Address(address _proxy, bytes32 _salt, bytes32 hash) public pure returns (address) {
		return address(uint160(uint256(keccak256(abi.encodePacked(hex"ff", _proxy, _salt, hash)))));
	}
}