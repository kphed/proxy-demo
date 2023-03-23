// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import "forge-std/Test.sol";
import {Initializable} from "openzeppelin/proxy/utils/Initializable.sol";

contract Counter is Initializable {
    uint256 public counter;

    constructor() initializer {}

    function increment() external initializer {
        ++counter;
    }
}

contract CounterTest is Test {
    Counter private immutable counter;

    constructor() {
        counter = new Counter();
    }

    function testCannotIncrementAlreadyInitialized() external {
        vm.expectRevert(
            bytes("Initializable: contract is already initialized")
        );

        // Reverts because due to the `initializer` modifier in the constructor
        counter.increment();

        // Should remain 0 since `increment` can only be called if initializing contract
        assertEq(0, counter.counter());
    }
}
