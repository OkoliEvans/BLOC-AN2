// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Store {
    uint256 userIdAssigned;
    uint256 vendorIdAssigned;
    uint256 public totalUsers;
    uint256 public totalVendors;
    uint256 public totalBuys;
    uint256 public totalListedProducts;

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

    struct Product {
        uint256 id;
        address owner;
        string name;
        string description;
        ProductCategory category;
        uint256 price;
        uint256 quantity;
        uint256 manufacturingDate;
        uint256 expiryDate;
        ProductCondition condition;
        string image; // ipfs CID
    }

    enum ProductCondition {
        BrandNew,
        ForeignUsed,
        NigerianUsed
    }

    enum ProductCategory {
        Clothings,
        Electronics,
        Appliances,
        Furniture,
        Plastics,
        Phones,
        FootWears,
        Laptops,
        Others
    }

    // ###### MAPPINGS ######

    // Mapping to store user data based on their address
    mapping(address => User) public users;
    mapping(address => bool) private isRegistered;
    address[] registeredUsers;

    // Map vendor address (msg.sender) to Vendor struct
    mapping(address => Vendor) public vendors;
    mapping(address => bool) private isRegisteredVendor;
    address[] registeredVendors;

    /// @notice Contract escrow account
    address escrowVault;

    // Map productId to Product struct for easy manipulations
    mapping(uint256 => Product) public products;
    uint256[] public productIds;

    // ###### ACTIONS ######

    // create a new user account
    function createUserAccount(string memory shippingAddress) public {
        uint256 userId = userIdAssigned += 1;
        require(
            bytes(shippingAddress).length > 0,
            "Shipping Address cannot be empty"
        );
        require(
            isRegistered[msg.sender] == false,
            "user cannot register same address twice"
        );
        users[msg.sender] = User({
            id: userId,
            shippingAddress: shippingAddress,
            totalBuys: 0
        });
        registeredUsers.push(msg.sender);
        isRegistered[msg.sender] = true;
    }

    // create vendor account
    function createVendorAccount(
        string memory homeAddress,
        address walletAddress,
        string memory phoneNumber
    ) public {
        // validations
        require(
            isRegisteredVendor[msg.sender] == false,
            "vendor cannot register same address twice"
        );
        require(bytes(homeAddress).length > 0, "Home Address cannot be empty");
        require(walletAddress != address(0), "Wallet Address cannot be empty");
        require(bytes(phoneNumber).length > 0, "Phone Number cannot be empty");
        // change state
        uint256 vendorId = vendorIdAssigned += 1;
        vendors[msg.sender] = Vendor({
            id: vendorId,
            homeAddress: homeAddress,
            phoneNumber: phoneNumber,
            walletAddress: walletAddress
        });
        registeredVendors.push(msg.sender);
        isRegisteredVendor[msg.sender] = true;
    }

    // add a new product
    // Only registered vendors are granted access.
    // Params: product description, product category, product amount, product manufacturing date, product expiry date, product condition, product image (ipfs CID)
    function addProduct(
        string memory name,
        string memory description,
        ProductCategory category,
        uint256 price,
        uint256 quantity,
        uint256 manufacturingDate,
        uint256 expiryDate,
        ProductCondition condition,
        string memory image
    ) public returns(uint){
        require(
            isRegisteredVendor[msg.sender] == true,
            "Only registered vendors can add products"
        );
        // validations
        require(bytes(name).length > 0, "Name cannot be empty");
        require(price > 0, "Price cannot be empty");
        require(quantity > 0, "Quantity cannot be empty");
        require(bytes(image).length > 0, "Image cannot be empty");

        uint256 productId = totalListedProducts += 1;
        products[productId] = Product({
            id: productId,
            owner: msg.sender,
            name: name,
            description: description,
            category: category,
            price: price,
            quantity: quantity,
            manufacturingDate: manufacturingDate,
            expiryDate: expiryDate,
            condition: condition,
            image: image
        });
        productIds.push(productId);
        return totalListedProducts;
    }

    /// Desc: Updates already uploaded product on the store using the productId to access the product. Only vendor that uploaded the product is granted access.
    /// Product struct should be updated with the new data.
    /// Params: product id, product description, product category, product amount,
    //          product manufacturing date, product expiry date, product condition, product image (ipfs CID)
    function updateProduct(
        uint256 productId,
        string memory name,
        string memory description,
        ProductCategory category,
        uint256 price,
        uint256 quantity,
        uint256 manufacturingDate,
        uint256 expiryDate,
        ProductCondition condition,
        string memory image
    ) public {
        Product storage product = products[productId];
        require(productId > 0, "Product does not exist");
        require(
            productId <= totalListedProducts,
            "Product does not exist in the store"
        );
        require(
            product.owner == msg.sender,
            "Only the owner of the product can update it"
        );
        // validations
        require(bytes(name).length > 0, "Name cannot be empty");
        require(price > 0, "Price cannot be empty");
        require(quantity > 0, "Quantity cannot be empty");
        require(bytes(image).length > 0, "Image cannot be empty");

        product.owner = msg.sender;
        product.name = name;
        product.description = description;
        product.category = category;
        product.price = price;
        product.quantity = quantity;
        product.manufacturingDate = manufacturingDate;
        product.expiryDate = expiryDate;
        product.condition =condition;
        product.image = image;
    }
}
