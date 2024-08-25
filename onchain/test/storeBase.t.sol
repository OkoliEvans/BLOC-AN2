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

        vm.expectRevert("user cannot register same address twice");
        store.createUserAccount(shippingAddress);
    }

    function testCreateVendorAccount() public {
        string memory homeAddress = "123 Main Street, City, Country";
        string memory phoneNumber = "123-456-78900";
        address walletAddress = address(this);

        store.createVendorAccount(homeAddress, walletAddress, phoneNumber);

        (uint256 id, string memory storedHomeAddress, string memory storedPhoneNumber, address storedWalletAddress) = store.vendors(address(this));

        assertEq(storedHomeAddress, homeAddress, "Home address should match");
        assertEq(storedPhoneNumber, phoneNumber, "Phone number should match");
        assertEq(storedWalletAddress, walletAddress, "Wallet address should match");

        assertGt(id, 0, "Vendor ID should be greater than 0.");
    }

    function testCreateVendorAccountWithEmptyAddress() public {
        string memory emptyHomeAddress = "";
        string memory phoneNumber = "123-456-7890";
        address walletAddress = address(this);

        vm.expectRevert("Home Address cannot be empty");
        store.createVendorAccount(emptyHomeAddress, walletAddress, phoneNumber);
    }

    function testCreateVendorAccountWithEmptyWalletAddress() public {
        string memory homeAddress = "123 Main Street, City, Country";
        string memory phoneNumber = "123-456-7890";
        address walletAddress = address(0);

        vm.expectRevert("Wallet Address cannot be empty");
        store.createVendorAccount(homeAddress, walletAddress, phoneNumber);
    }

    function testCreateVendorAccountWithEmptyPhoneNumber() public {
        string memory homeAddress = "123 Main Street, City, Country";
        string memory emptyPhoneNumber = "";
        address walletAddress = address(this);

        vm.expectRevert("Phone Number cannot be empty");
        store.createVendorAccount(homeAddress, walletAddress, emptyPhoneNumber);
    }

    function testCreateDuplicateVendorAccount() public {
        string memory homeAddress = "123 Main Street, City, Country";
        string memory phoneNumber = "123-456-7890";
        address walletAddress = address(this);

        store.createVendorAccount(homeAddress, walletAddress, phoneNumber);

        vm.expectRevert("vendor cannot register same address twice");
        store.createVendorAccount(homeAddress, walletAddress, phoneNumber);
    }
}
