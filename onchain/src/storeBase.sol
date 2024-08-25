// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Store {
	uint256 userIdAssigned;
	uint256 vendorIdAssigned;
	uint256 totalBuys;

	// ###### STRUCTS ######

	// Define the user struct
	struct User {
		uint256 id;
		string shippingAddress;
		uint256 totalBuys;
	}

	// Define the vendor struct
	struct Vendor {
		uint256 id;
		string homeAddress;
		string phoneNumber;
		address walletAddress;
	}

	// ###### MAPPINGS ######

	// Mapping to store user data based on their address
	mapping(address => User) public users;
	mapping(address => bool) private isRegistered;
	address[] registeredUsers;

	// Map vendor address (msg.sender) to Vendor struct
	mapping(address => Vendor) public vendors;
	mapping(address => bool) private isVendor;
	address[] registeredVendors;

	/// @notice Contract escrow account
	address escrowVault;


	// ###### ACTIONS ######

	// create a new user account
	function createUserAccount(string memory shippingAddress) public {
		uint256 userId = userIdAssigned += 1;
		require(bytes(shippingAddress).length > 0, "Shipping Address cannot be empty");
		require(isRegistered[msg.sender] == false, "user cannot register same address twice");
		users[msg.sender] = User({id: userId, shippingAddress: shippingAddress, totalBuys: 0});
		registeredUsers.push(msg.sender);
		isRegistered[msg.sender] = true;
	}

	// create vendor account
	function createVendorAccount(string memory homeAddress, address walletAddress, string memory phoneNumber) public {
		// validations
		require(isVendor[msg.sender] == false, "vendor cannot register same address twice");
		require(bytes(homeAddress).length > 0, "Home Address cannot be empty");
		require(walletAddress != address(0), "Wallet Address cannot be empty");
		require(bytes(phoneNumber).length > 0, "Phone Number cannot be empty");
		// change state
		uint256 vendorId = vendorIdAssigned += 1;
		vendors[msg.sender] = Vendor({id: vendorId, homeAddress: homeAddress, phoneNumber: phoneNumber, walletAddress: walletAddress});
		registeredVendors.push(msg.sender);
		isVendor[msg.sender] = true;
	}
}
