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

        (
            uint256 id,
            string memory storedShippingAddress,
            uint256 totalBuys
        ) = store.users(address(this));

        assertEq(
            storedShippingAddress,
            shippingAddress,
            "Shipping address should match"
        );

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

        (
            uint256 id,
            string memory storedHomeAddress,
            string memory storedPhoneNumber,
            address storedWalletAddress
        ) = store.vendors(address(this));

        assertEq(storedHomeAddress, homeAddress, "Home address should match");
        assertEq(storedPhoneNumber, phoneNumber, "Phone number should match");
        assertEq(
            storedWalletAddress,
            walletAddress,
            "Wallet address should match"
        );

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

    function testAddProduct() public {
        store.createVendorAccount(
            "123 Main Street, City, Country",
            address(this),
            "123-456-7890"
        );
        store.addProduct(
            "Product 1",
            "Product 1 description",
            Store.ProductCategory.Electronics,
            100,
            10,
            1630000000,
            1730000000,
            Store.ProductCondition.BrandNew,
            "QmXZnJ1YQZz"
        );

        uint256 productId = 1; // productIds.length + 1
        assertEq(
            store.productIds(0),
            productId,
            "Product ID should be added to productIds array"
        );

        (
            uint256 storedId,
            address owner,
            string memory storedName,
            string memory storedDescription,
            Store.ProductCategory storedCategory,
            uint256 storedPrice,
            uint256 storedQuantity,
            uint256 storedManufacturingDate,
            uint256 storedExpiryDate,
            Store.ProductCondition storedCondition,
            string memory storedImage
        ) = store.products(productId);

        assertEq(storedId, productId, "Product ID should match");
        assertEq(owner, address(this), "Owner should match");
        assertEq(storedName, "Product 1", "Name should match");
        assertEq(
            storedDescription,
            "Product 1 description",
            "Description should match"
        );
        assertEq(
            uint256(storedCategory),
            uint256(Store.ProductCategory.Electronics),
            "Category should match"
        );
        assertEq(storedPrice, 100, "Price should match");
        assertEq(storedQuantity, 10, "Quantity should match");
        assertEq(
            storedManufacturingDate,
            1630000000,
            "Manufacturing date should match"
        );
        assertEq(storedExpiryDate, 1730000000, "Expiry date should match");
        assertEq(
            uint256(storedCondition),
            uint256(Store.ProductCondition.BrandNew),
            "Condition should match"
        );
        assertEq(storedImage, "QmXZnJ1YQZz", "Image should match");
    }

    function testAddProductWithoutVendorAccount() public {
        vm.expectRevert("Only registered vendors can add products");
        store.addProduct(
            "Product 1",
            "Product 1 description",
            Store.ProductCategory.Electronics,
            100,
            10,
            1630000000,
            1730000000,
            Store.ProductCondition.BrandNew,
            "QmXZnJ1YQZz"
        );
    }

    function testAddProductWithEmptyName() public {
        store.createVendorAccount(
            "123 Main Street, City, Country",
            address(this),
            "123-456-7890"
        );

        vm.expectRevert("Name cannot be empty");
        store.addProduct(
            "",
            "Product 1 description",
            Store.ProductCategory.Electronics,
            100,
            10,
            1630000000,
            1730000000,
            Store.ProductCondition.BrandNew,
            "QmXZnJ1YQZz"
        );
    }

    function testAddProductWithEmptyPrice() public {
        store.createVendorAccount(
            "123 Main Street, City, Country",
            address(this),
            "123-456-7890"
        );

        vm.expectRevert("Price cannot be empty");
        store.addProduct(
            "Product 1",
            "Product 1 description",
            Store.ProductCategory.Electronics,
            0,
            10,
            1630000000,
            1730000000,
            Store.ProductCondition.BrandNew,
            "QmXZnJ1YQZz"
        );
    }

    function testAddProductWithEmptyQuantity() public {
        store.createVendorAccount(
            "123 Main Street, City, Country",
            address(this),
            "123-456-7890"
        );

        vm.expectRevert("Quantity cannot be empty");
        store.addProduct(
            "Product 1",
            "Product 1 description",
            Store.ProductCategory.Electronics,
            100,
            0,
            1630000000,
            1730000000,
            Store.ProductCondition.BrandNew,
            "QmXZnJ1YQZz"
        );
    }

    function testAddProductWithEmptyImage() public {
        store.createVendorAccount(
            "123 Main Street, City, Country",
            address(this),
            "123-456-7890"
        );

        vm.expectRevert("Image cannot be empty");
        store.addProduct(
            "Product 1",
            "Product 1 description",
            Store.ProductCategory.Electronics,
            100,
            10,
            1630000000,
            1730000000,
            Store.ProductCondition.BrandNew,
            ""
        );
    }

    // product update tests
    function testUpdateProduct() public {
        store.createVendorAccount(
            "123 Main Street, City, Country",
            address(this),
            "123-456-7890"
        );
        store.addProduct(
            "Product 1",
            "Product 1 description",
            Store.ProductCategory.Electronics,
            100,
            10,
            1630000000,
            1730000000,
            Store.ProductCondition.BrandNew,
            "QmXZnJ1YQZz"
        );

        store.updateProduct(
            1,
            "Product 2",
            "Product 2 description",
            Store.ProductCategory.Clothings,
            200,
            20,
            1630000000,
            1730000000,
            Store.ProductCondition.BrandNew,
            "QmXZnJ1YQZz"
        );

        (
            uint256 storedId,
            address owner,
            string memory storedName,
            string memory storedDescription,
            Store.ProductCategory storedCategory,
            uint256 storedPrice,
            uint256 storedQuantity,
            uint256 storedManufacturingDate,
            uint256 storedExpiryDate,
            Store.ProductCondition storedCondition,
            string memory storedImage
        ) = store.products(1);

        assertEq(storedId, 1, "Product ID should match");
        assertEq(owner, address(this), "Owner should match");
        assertEq(storedName, "Product 2", "Name should match");
        assertEq(
            storedDescription,
            "Product 2 description",
            "Description should match"
        );
        assertEq(
            uint256(storedCategory),
            uint256(Store.ProductCategory.Clothings),
            "Category should match"
        );
        assertEq(storedPrice, 200, "Price should match");
        assertEq(storedQuantity, 20, "Quantity should match");
        assertEq(
            storedManufacturingDate,
            1630000000,
            "Manufacturing date should match"
        );
        assertEq(storedExpiryDate, 1730000000, "Expiry date should match");
        assertEq(
            uint256(storedCondition),
            uint256(Store.ProductCondition.BrandNew),
            "Condition should match"
        );
        assertEq(storedImage, "QmXZnJ1YQZz", "Image should match");
    }

    function testUpdateProductWithoutVendorAccount() public {
        vm.expectRevert("Only the owner of the product can update it");
        store.updateProduct(
            1,
            "Product 2",
            "Product 2 description",
            Store.ProductCategory.Clothings,
            200,
            20,
            1630000000,
            1730000000,
            Store.ProductCondition.BrandNew,
            "QmXZnJ1YQz"
        );
    }

    function testUpdateProductWithEmptyName() public {
        store.createVendorAccount(
            "123 Main Street, City, Country",
            address(this),
            "123-456-7890"
        );
        store.addProduct(
            "Product 1",
            "Product 1 description",
            Store.ProductCategory.Electronics,
            100,
            10,
            1630000000,
            1730000000,
            Store.ProductCondition.BrandNew,
            "QmXZnJ1YQZz"
        );

        vm.expectRevert("Name cannot be empty");
        store.updateProduct(
            1,
            "",
            "Product 2 description",
            Store.ProductCategory.Clothings,
            200,
            20,
            1630000000,
            1730000000,
            Store.ProductCondition.BrandNew,
            "QmXZnJ1YQz"
        );
    }

    function testUpdateProductWithEmptyPrice() public {
        store.createVendorAccount(
            "123 Main Street, City, Country",
            address(this),
            "123-456-7890"
        );
        store.addProduct(
            "Product 1",
            "Product 1 description",
            Store.ProductCategory.Electronics,
            100,
            10,
            1630000000,
            1730000000,
            Store.ProductCondition.BrandNew,
            "QmXZnJ1YQZz"
        );

        vm.expectRevert("Price cannot be empty");
        store.updateProduct(
            1,
            "Product 2",
            "Product 2 description",
            Store.ProductCategory.Clothings,
            0,
            20,
            1630000000,
            1730000000,
            Store.ProductCondition.BrandNew,
            "QmXZnJ1YQz"
        );
    }

    function testUpdateProductWithEmptyQuantity() public {
        store.createVendorAccount(
            "123 Main Street, City, Country",
            address(this),
            "123-456-7890"
        );
        store.addProduct(
            "Product 1",
            "Product 1 description",
            Store.ProductCategory.Electronics,
            100,
            10,
            1630000000,
            1730000000,
            Store.ProductCondition.BrandNew,
            "QmXZnJ1YQZz"
        );

        vm.expectRevert("Quantity cannot be empty");
        store.updateProduct(
            1,
            "Product 2",
            "Product 2 description",
            Store.ProductCategory.Clothings,
            200,
            0,
            1630000000,
            1730000000,
            Store.ProductCondition.BrandNew,
            "QmXZnJ1YQz"
        );
    }

    function testUpdateProductWithEmptyImage() public {
        store.createVendorAccount(
            "123 Main Street, City, Country",
            address(this),
            "123-456-7890"
        );
        store.addProduct(
            "Product 1",
            "Product 1 description",
            Store.ProductCategory.Electronics,
            100,
            10,
            1630000000,
            1730000000,
            Store.ProductCondition.BrandNew,
            "QmXZnJ1YQZz"
        );

        vm.expectRevert("Image cannot be empty");
        store.updateProduct(
            1,
            "Product 2",
            "Product 2 description",
            Store.ProductCategory.Clothings,
            200,
            20,
            1630000000,
            1730000000,
            Store.ProductCondition.BrandNew,
            ""
        );
    }

    function testUpdateProductWithInvalidProductId() public {
        store.createVendorAccount(
            "123 Main Street, City, Country",
            address(this),
            "123-456-7890"
        );

        vm.expectRevert("Product does not exist");
        store.updateProduct(
            1,
            "Product 2",
            "Product 2 description",
            Store.ProductCategory.Clothings,
            200,
            20,
            1630000000,
            1730000000,
            Store.ProductCondition.BrandNew,
            "QmXZnJ1YQz"
        );
    }
}
