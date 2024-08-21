// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Store} from "../src/storeBase.sol";

contract StoreTest is Test {
    Store public store;

    function setUp() public {
        store = new Store();
    }

    function testCreateUserAccount() public {
        string memory shippingAddress = "123 Main Street, City, Country";

        store.createUserAccount(shippingAddress);

        (uint256 id, string memory storedShippingAddress, uint256 totalBuys) = store.users(address(this));

        assertEq(storedShippingAddress, shippingAddress, "Shipping address should match");

        assertEq(totalBuys, 0, "Total buys should be initialized to 0.");

        assertGt(id, 0, "User ID should be greater than 0.");
    }

    function testCreateUserAccountWithEmptyAddress() public {
        string memory emptyShippingAddress = "";

        vm.expectRevert("Shipping Address cannot be empty");
        store.createUserAccount(emptyShippingAddress);
    }

    function testCreateDuplicatUserAccount() public {
        string memory shippingAddress = "123 Main Street, City, Country";

        store.createUserAccount(shippingAddress);

        vm.expectRevert("Account already exists");
        store.createUserAccount(shippingAddress);
    }

    function testUserIdIncrement() public {
        string memory shippingAddress_1 = "123 Main Street, City, Country";
        string memory shippingAddress_2 = "456 Another Street, City, Country";

        store.createUserAccount(shippingAddress_1);
        uint256 firstUserId = store.users(address(this)).id;

        address secondUser = address(0x123456);
        vm.prank(secondUser);
        store.createUserAccount(shippingAddress_2);
        uint256 secondUserId = store.users(secondUser).id;

        assertEq(firstUserId, secondUserId - 1, "User ID should be incremented by 1.");
    }

   
}
