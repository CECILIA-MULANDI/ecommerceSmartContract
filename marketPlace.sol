// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
// selling things- we have sell and buy functionality

contract MarketPlace{
    // product we will be selling
    struct Product{
        uint256 id;
        // string image;
        string name;
        string description;
        uint256 price;
        address seller;
        bool isSold;
        
    }
    // have a mapping 
    // products[1] ={details of the product}
    mapping (uint256 =>Product)public products;
    // count the number of products
    uint256 public productCount;
    mapping (address => bool ) public registeredUsers;
    // producToBuyer[234] =[{0xc345}]
    mapping (uint256 => address) public productToBuyer;
    // it has the products one is selling
    // so we can have a scenarrio like this: 
    // 0xc345 =[123(nike shoes),9090(addidas socks)]
    mapping(address => uint256[]) public userItems;
    // maps addresses to the products bought by that address
    mapping(address => uint256[]) public userPurchases;

    event productListed(uint256 indexed id,string title,address seller);
    event productPurchased(uint256 indexed id,string title,address buyer,address seller);

    // onlyRegisteredUsermodifier - when this is called only registered users can access that function
    modifier _onlyRegisteredUser(){
        require(registeredUsers[msg.sender],"User is not registered");
        _;
    }
    // check that only seller access some functions
    // so we go into the products mapping
    // check the ids(key)
    // then go and check the seller value since we are dealing with a product struct
    // 
    modifier _onlyProductSeller(uint256 _productId){
        require(products[_productId].seller==msg.sender,"Only the Seller can perform this action");
        _;
    }

// this is an external fun meaning it is only accessed from outside the contract
// we will use this to get an entry point into the contract
    function register() external {
        // check that the registeredUser mapping and see 
        require(!registeredUsers[msg.sender],"User registered");
        registeredUsers[msg.sender]=true;
    }
    // function to list a new item
    function listNewProduct(string memory _name,string memory _description ,uint256 _price)external  _onlyRegisteredUser{
        // increase number count
        productCount++;
        products[productCount]=Product({
            id:productCount,
            name:_name,
            description:_description,
            price:_price,
            seller:msg.sender,
            isSold:false

        });
        userItems[msg.sender].push(productCount);
        emit productListed(productCount, _name, msg.sender);

    }
    function purchaseProduct(uint256 _productId)external payable _onlyRegisteredUser {
        // retrieve the product you'd want to buy
        Product storage product = products[_productId];
        // ensure that it is not sold first
        require(!product.isSold,"Product already sold");
        // check if you have enough money to do the purchase
        require(msg.value>=product.price,"Insufficient funds");
        product.isSold = true;
        // match product id to the buyer's address
        productToBuyer[_productId]=msg.sender;
        // add it on your purchases
        userPurchases[msg.sender].push(_productId);
        // send the money now
        (bool success,) = product.seller.call{value:product.price}("");
        // check to see if it was succesful
        require(success,"Failed to transfer funds");
        // show that purchase has taken place
        emit productPurchased(_productId, product.name, msg.sender, product.seller);

        
    }
    // get the item count
    function getProductCount() public view returns(uint256 ){
        return productCount;
    }
    // get user items
    function getUserProducts(address _user) public view returns (uint256[] memory){
        return userItems[_user];
    }
    // all purchases
    function getUserPurchases(address _user) public view returns(uint256[] memory) {
        return userPurchases[_user];
        
    }


}