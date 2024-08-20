// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Store {
	uint256 userIdAssigned;
	uint256 totalBuys;

	// Define the user struct
	struct User {
		uint256 id;
		string shippingAddress;
		uint256 totalBuys;
	}

	// Mapping to store user data based on their address
	mapping(address => User) public users;
	mapping(address => bool) private isRegistered;
	address[] registeredUsers;

	// create a new user account
	function createUserAccount(string memory shippingAddress) public {
		uint256 userId = userIdAssigned += 1;
		require(bytes(shippingAddress).length > 0, "Shipping Address cannot be empty");
		require(isRegistered[msg.sender] == false, "user cannot register same address twice");
		users[msg.sender] = User({id: userId, shippingAddress: shippingAddress, totalBuys: 0});
		registeredUsers.push(msg.sender);
		isRegistered[msg.sender] = true;
	}
}
