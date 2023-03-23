// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import "forge-std/Test.sol";
import {Initializable} from "openzeppelin/proxy/utils/Initializable.sol";
import {TransparentUpgradeableProxy} from "openzeppelin/proxy/transparent/TransparentUpgradeableProxy.sol";

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

    function testDeployProxyAndIncrement() external {
        Counter counterProxy = Counter(address(new TransparentUpgradeableProxy(
            address(counter),
            address(this),
            abi.encode(counter.increment.selector)
        )));

        // Impersonate non-admin caller
        vm.startPrank(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266);

        // `counter` is incremented on proxy, even though impl. is already initialized
        assertEq(1, counterProxy.counter());

        // Unchanged, since only the proxy's storage was updated
        assertEq(0, counter.counter());

        vm.expectRevert(bytes("Initializable: contract is already initialized"));

        // Reverts because the proxy is now initialized
        counterProxy.increment();
    }
}
