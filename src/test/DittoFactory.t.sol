// SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

import {Test} from "@std/Test.sol";
import {console} from "@std/console.sol";

import {DittoFactory} from "../DittoFactory.sol";
import {Impl} from "../utils/Impl.sol";
import {ImplOther} from "../utils/ImplOther.sol";
import {ImplConstructor} from "../utils/ImplWithConstructor.sol";
import {Ephemeral} from "../Ephemeral.sol";

import {GetCode} from "../lib/GetCode.sol";

contract TestDittoFactory is Test {
    using GetCode for address;

    Impl public impl;
    ImplOther public implOther;
    ImplConstructor public implConstructor;
    DittoFactory public dittoFactory;

    function setUp() public {
        impl = new Impl();
        implOther = new ImplOther();
        implConstructor = new ImplConstructor();

        dittoFactory = new DittoFactory(type(Ephemeral).creationCode);
    }

    function testImpostor() public {
        bytes32 salt = bytes32(uint256(uint160(address(impl))));

        address impostor = dittoFactory.impostor(
            salt,
            type(Impl).creationCode,
            ""
        );

        assertEq(1, impl.getX());
        Impl(impostor).initialize();
        assertEq(2, Impl(impostor).getX());
    }

    function testImpostorExisting() public {
        bytes32 salt = bytes32(uint256(uint160(address(impl))));

        address impostor = dittoFactory.impostorExisting(
            salt,
            address(impl),
            ""
        );

        assertEq(1, impl.getX());
        Impl(impostor).initialize();
        assertEq(2, Impl(impostor).getX());
    }

    function testImpostorEphemeral() public {
        bytes32 salt = bytes32(uint256(uint160(address(implConstructor))));

        address impostor = dittoFactory.impostorEphemeral(
            salt,
            type(ImplConstructor).creationCode
        );

        assertEq(2, implConstructor.getX());

        assertEq(2, ImplConstructor(impostor).getX());
    }
}
