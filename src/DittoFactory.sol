// SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

/*
 * ⠀⠀⠀⢠⡜⠛⠛⠿⣤⠀⠀⣤⡼⠿⠿⢧⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
 * ⠀⣀⡶⠎⠁⠀⠀⠀⠉⠶⠶⠉⠁⠀⠀⠈⠹⢆⣀⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
 * ⣀⡿⠇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠉⠉⠶⠶⠶⠶⣆⡀⠀⠀⠀⠀
 * ⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⢣⡄⠀⠀⠀
 * ⠛⣧⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⡇⠀⠀
 * ⠀⠛⣧⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠿⠀⠀⠀⠀⢠⡼⠃⠀⠀
 * ⠀⠀⠿⢇⡀⠀⠀⠀⠀⠀⠀⠀⠰⠶⠶⢆⣀⣀⣀⠀⠀⠀⠀⠀⠀⢸⡇⠀⠀⠀
 * ⠀⠀⠀⢸⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠉⠉⠉⠀⠀⠀⠀⠀⠀⢸⡇⠀⠀⠀
 * ⠀⠀⠀⢸⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⡇⠀⠀
 * ⠀⠀⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⢣⣤
 * ⠀⣶⡏⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿
 * ⠀⠿⣇⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣀⣀⣀⣀⣀⣀⠀⠀⠀⠀⢀⣀⣸⠿
 * ⠀⠀⠙⢳⣶⣶⣶⣶⣶⣶⣶⣶⣶⣶⣶⡞⠛⠛⠛⠛⠛⠛⣶⣶⣶⣶⡞⠛⠃⠀
 */

import {console} from "@std/console.sol";
import {Address} from "./lib/Address.sol";

contract DittoFactory {
    using Address for address;

    error FailedDeploy();

    bytes private _dittoInitCode;
    bytes32 private immutable _dittoInitCodeHash;

    bytes private _ephemeralInitCode;
    bytes32 private immutable _ephemeralInitCodeHash;

    mapping(address => address) private _pokemons;
    mapping(address => bytes) private _initCellularCode;

    event DittoDitto(address dittoAddress, address pokeAddress);
    event DittoDittoWithConstructor(
        address dittoAddress,
        address ephemeralAddress
    );

    constructor(bytes memory _ephemeralCode) {
        _dittoInitCode = hex"3D60323D6004601C335A63aaf10f423D52FA158151803B80938091923CF3";
        _dittoInitCodeHash = keccak256(abi.encodePacked(_dittoInitCode));

        _ephemeralInitCode = _ephemeralCode;
        _ephemeralInitCodeHash = keccak256(
            abi.encodePacked(_ephemeralInitCode)
        );
    }

    function impostor(
        bytes32 salt,
        bytes calldata _pokeCellularCode,
        bytes calldata _dittoCalldata
    ) external payable returns (address dittoDeployedAddress) {
        bytes memory _pokeCode = _pokeCellularCode;
        bytes memory _dittoCode = _dittoInitCode;
        address pokeDeployedAddress;

        /* solhint-disable no-inline-assembly */
        assembly {
            pokeDeployedAddress := create(
                0,
                add(0x20, _pokeCode),
                mload(_pokeCode)
            )
        } /* solhint-enable no-inline-assembly */

        if (pokeDeployedAddress == address(0)) revert FailedDeploy();

        address dittoAddress = getDittoAddress(salt);

        _pokemons[dittoAddress] = pokeDeployedAddress;

        /* solhint-disable no-inline-assembly */
        assembly {
            dittoDeployedAddress := create2(
                0,
                add(0x20, _dittoCode),
                mload(_dittoCode),
                salt
            )
        } /* solhint-enable no-inline-assembly */

        require(dittoDeployedAddress == dittoAddress, "Failed to deploy ditto");

        if (msg.value > 0 || _dittoCalldata.length > 0) {
            /* solhint-disable avoid-low-level-calls */
            (bool success, ) = dittoDeployedAddress.call{value: msg.value}(
                _dittoCalldata
            );
            /* solhint-enable avoid-low-level-calls */

            require(success, "Failed to initialize ditto");
        }

        emit DittoDitto(dittoDeployedAddress, pokeDeployedAddress);
    }

    function impostorExisting(
        bytes32 salt,
        address pokemon,
        bytes calldata _dittoCalldata
    ) external payable returns (address dittoDeployedAddress) {
        bytes memory _dittoCode = _dittoInitCode;

        address dittoAddress = getDittoAddress(salt);

        _pokemons[dittoAddress] = pokemon;

        /* solhint-disable no-inline-assembly */
        assembly {
            dittoDeployedAddress := create2(
                0,
                add(0x20, _dittoCode),
                mload(_dittoCode),
                salt
            )
        } /* solhint-enable no-inline-assembly */

        require(dittoDeployedAddress == dittoAddress, "Failed to deploy ditto");

        if (msg.value > 0 || _dittoCalldata.length > 0) {
            /* solhint-disable avoid-low-level-calls */
            (bool success, ) = dittoDeployedAddress.call{value: msg.value}(
                _dittoCalldata
            );
            /* solhint-enable avoid-low-level-calls */

            require(success, "Failed to initialize ditto");
        }

        emit DittoDitto(dittoDeployedAddress, pokemon);
    }

    function impostorEphemeral(bytes32 salt, bytes calldata _pokeCode)
        external
        returns (address dittoDeployedAddress)
    {
        bytes memory _ephemeralCode = _ephemeralInitCode;

        address ephemeralAddress = getEphemeralAddress(salt);

        _initCellularCode[ephemeralAddress] = _pokeCode;

        address ephemeral;

        /* solhint-disable no-inline-assembly */
        assembly {
            ephemeral := create2(
                0,
                add(0x20, _ephemeralCode),
                mload(_ephemeralCode),
                salt
            )
        } /* solhint-enable no-inline-assembly */

        if (ephemeral != ephemeralAddress) revert FailedDeploy();

        dittoDeployedAddress = getDittoAddressFromEphemeral(ephemeralAddress);

        emit DittoDittoWithConstructor(ephemeralAddress, dittoDeployedAddress);
    }

    function getImplementation() public view returns (address) {
        return _pokemons[msg.sender];
    }

    function getDittoCode() public view returns (bytes memory) {
        return _initCellularCode[msg.sender];
    }

    function getDittoAddress(bytes32 salt) public view returns (address) {
        return address(this).getCreate2Address(salt, _dittoInitCodeHash);
    }

    function getEphemeralAddress(bytes32 salt) public view returns (address) {
        return address(this).getCreate2Address(salt, _ephemeralInitCodeHash);
    }

    function getDittoAddressFromEphemeral(address ephemeral)
        public
        pure
        returns (address)
    {
        return ephemeral.getCreateAddress();
    }
}
