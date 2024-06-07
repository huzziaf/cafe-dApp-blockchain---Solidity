// SPDX-License-Identifier: MIT

pragma solidity >=0.4.22 <0.9.0;

interface ERC20 {
    // total supply of the tokens
    function totalSupply() external view returns (uint256);
    // balance of a particular account
    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address _spender) external view returns (uint256);
    function approve(address spender, uint256 value) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    
}

contract FastCoin is ERC20 {
    string public name = "FastCoin";
    string public symbol = "FC";
    
    address public cafe;
    uint256 public totalTokenSupply = 1000000 * (10**18);

    // which address has how many tokens
    mapping(address => uint256) public balances;

    // which address has allowed which address to spend how many tokens
    mapping(address => mapping(address => uint256)) public allowances;

    constructor() {
        cafe = msg.sender;
        // give half of the tokens to the owner
        balances[cafe] = totalTokenSupply;
    }

    // total supply of the tokens
    function totalSupply() external view override returns (uint256) {
        return totalTokenSupply;
    }

    // balance of a particular account
    function balanceOf(address account) external view override returns (uint256) {
        return balances[account];
    }

    function getTokens() external payable{
        //1 eth = 100 FC
        payable(cafe).transfer(msg.value);
        uint256 tokensToSend = (msg.value/1 ether)*100;
        balances[msg.sender] += tokensToSend;
        balances[cafe] -= tokensToSend;
    }

    function transferToCafe(address customer, uint256 amount) external returns (bool){
        require(balances[customer]>=amount, "Insufficient Funds");
        balances[customer] -= amount;
        balances[cafe] += amount;
        return true;
    }

    function transferFromCafe(address customer, uint256 amount) external returns (bool){
        require(balances[cafe]>=amount, "Insufficient Funds");
        balances[cafe] -= amount;
        balances[customer] += amount;
        return true;
    }

    // transfer tokens from the contract invoker to the recipient
    function transfer(address recipient,uint256 amount) external returns (bool){
        require(balances[msg.sender] >= amount, "You dont have enough balance to transfer the amount");
        balances[msg.sender] -= amount;
        balances[recipient] += amount;
        return true;
    }

    function approve(address spender,uint256 value) external returns (bool) {
        require(balances[msg.sender] >= value, "You dont have enough balance to set the allowance amount");
        allowances[msg.sender][spender] = value;
        return true;    
    }

    // check the allowance and its availablity
    function allowance(address _owner, address _spender) external view returns (uint256){
        return allowances[_owner][_spender];
    }

    function transferFrom(address sender,address recipient,uint256 amount) external returns (bool) {
        // sender should have enough balance to spend
        require(balances[sender] >= amount, "The sender balance is less than the amount");
        require(allowances[sender][msg.sender] >= amount, "The allowance for contract invoker is less than the amount");

        // cut balance from sender and add to reciepent
        balances[sender] -= amount;
        balances[recipient] += amount;

        allowances[sender][msg.sender] -= amount;

        return true;
    }

}

contract MenuManagement{
    // state variables (stored directly on the blockchain)
    address public owner;

    // called only once when the smart contract is deployed to the blockchain
    constructor() {
        owner = msg.sender;
    }

    struct MenuItem {
        string itemName;
        uint256 quantity;
        uint256 price;
    }

    // array to store menu items
    MenuItem[] public menuItems;

    function getItemsCount() public view returns (uint256) {
        return menuItems.length;
    }

    modifier onlyOwner{
        require(msg.sender == owner);
        _;
    }

    modifier indexCheck(uint256 _index){
        require(_index < menuItems.length, "Invalid index");
        _;

    }

    function addItem(string memory _itemName, uint256 _itemQuantity, uint256 _itemPrice) public onlyOwner{
        menuItems.push(MenuItem(_itemName, _itemQuantity, _itemPrice));
    }

    function updatePrice(uint256 _index, uint256 _itemPrice) public onlyOwner indexCheck(_index){
        // multiply by 1 ether to convert to wei
        menuItems[_index].price = _itemPrice;
    }

    function getPrice(uint256 _index) public view indexCheck(_index) returns (uint256){
        // divide by 1 ether to convert to ether
        return menuItems[_index].price;
    }

    function updateQuantity(uint256 _index, uint256 _itemQuantity) public indexCheck(_index){
        menuItems[_index].quantity = _itemQuantity;
    }

    function getItemQuantity(uint256 _index) public view indexCheck(_index) returns (uint256) {
        return menuItems[_index].quantity;
    }

    function checkAvailability(uint256 _index) public view indexCheck(_index) returns (bool) {
        // available if quantity is more than 0
        return (menuItems[_index].quantity > 0);
    }


}

contract promotions{

    uint256 public discount;
    address public owner;


    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner{
        require(msg.sender == owner);
        _;
    }

    function setDiscount(uint256 disc) public onlyOwner{
        discount = disc;
    } 

    function applyDiscount(uint256 amount) public view returns (uint256){
        return (amount * (100 - discount)) / 100;
    }
    
}

contract RewardsLoyalty{
    mapping(address => uint256) public loyaltyTokens;
    FastCoin public fc;
    address public owner;
    
    constructor(FastCoin _fc){
        owner = msg.sender;
        fc = _fc;
    }

    function incTokens(address _customer) public {
        //10 loyalty points given for each purchase
        loyaltyTokens[_customer]+=10;
    }

    function redeemPrize() public{
        uint256 prize = loyaltyTokens[msg.sender]/10;
        loyaltyTokens[msg.sender] = 0;
        fc.transferFromCafe(msg.sender, prize);
    }

}

contract OrderContract{
    address public owner; 
    MenuManagement public mm;
    promotions public pr;
    RewardsLoyalty public rl;
    FastCoin public fc;

    constructor(MenuManagement _mm, promotions _pr, RewardsLoyalty _rl, FastCoin _fc) {
        owner = msg.sender;
        mm = _mm;
        pr = _pr;
        rl = _rl;
        fc = _fc;
    }

    function calculateOrderAmount(uint256[] memory _itemIndexes, uint256[] memory _quantities) public view returns (uint256){
        require(_itemIndexes.length == _quantities.length, "Error: Item and quantity count mismatch");
        
        // check for an invalid item index and availability
        for (uint256 i = 0; i < _itemIndexes.length; i++) {
            require(_itemIndexes[i] < mm.getItemsCount(), "Invalid item index");
            require(mm.checkAvailability(_itemIndexes[i]), "Item out of stock");
        }

        uint256 totalAmount = 0;

        for (uint256 i = 0; i < _itemIndexes.length; i++) {
            uint256 itemPrice = mm.getPrice(_itemIndexes[i]);
            totalAmount += itemPrice * _quantities[i];
        }
        //returning discounted value
        return  pr.applyDiscount(totalAmount);
    }


    function placeOrder(uint256[] memory _itemIndexes, uint256[] memory _quantities, uint payment) public{
        uint256 totalAmount = calculateOrderAmount(_itemIndexes, _quantities);
        require(payment >= totalAmount, "You didnt pay enough");

        for (uint256 i = 0; i < _itemIndexes.length; i++) {
            mm.updateQuantity(_itemIndexes[i], mm.getItemQuantity(_itemIndexes[i]) - _quantities[i]);
        }

        rl.incTokens(msg.sender);
        fc.transferToCafe(msg.sender, payment);
    }


}