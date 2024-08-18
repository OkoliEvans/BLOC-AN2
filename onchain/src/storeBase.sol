// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Store {

	// Define the user struct
	struct User {
		string shippingAddress;
		uint8 totalBuys;
	}

	// Mapping to store user data based on their address
	mapping(address => User) public users;

	// create a new account
	function createAccount(string memory shippingAddress) public {
		require(!users[msg.sender].shippingAddress, "Account already exists");
		require(bytes(shippingAddress).length > 0, "Shipping Address cannot be empty");
		users[msg.sender] = User({shippingAddress, totalBuys: 0});
	}
}
