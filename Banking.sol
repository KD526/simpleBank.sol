// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract bankAccount {

 address payable public accountNumber;
 uint256 public bankBalance;
 address public bankContract = 0x4211232cE0e1f6F9390a;
 bool locked;
 uint256 loanPool = 1000 ether;


 event Deposit(address indexed depositor, uint value);
 event Transfer(address indexed from, address indexed to, uint256 value);
 event Approval(address indexed owner, address indexed spender, uint256 value);

    

 mapping(address => uint) private balanceOf;
 mapping(address => mapping(address => uint256)) public allowance;

 

constructor(address payable _address)  {
    accountNumber =_address;

}

modifier noReentrancy() {
    require(!locked, "No reentrancy!");
    locked = true;
    _;
    locked = false;

}

modifier accountOwner() {
    require(msg.sender == accountNumber, "only account owner is required");
    _;
}

function deposit(uint amount) public noReentrancy() returns (bool successful) {

    uint currentBalance = bankBalance;
    uint newBalance = currentBalance + amount;
    require(newBalance >= currentBalance, "Deposit failed!");
    assert(newBalance == bankBalance);
    return true;

}

function withdraw(uint _amount) public accountOwner() noReentrancy() returns (bool successful) {

   uint previousBalance = bankBalance;
   uint _newBalance = previousBalance - _amount;
   require(previousBalance >= _newBalance, "Withdrawal failed!");
   assert(_newBalance == bankBalance);
  // (bool success, ) = owner.call{value: amount}("");
    //require(success, "Failed to send Ether");
   return true;
} 

 receive() external payable noReentrancy() {
     emit Deposit(msg.sender, msg.value);   
    }

    function transfer(address _to, uint256 _value) external returns (bool successful) {
        require(balanceOf[msg.sender] >= _value);
        _transfer(msg.sender, _to, _value);
        return true;

    }
    function _transfer(address _from, address _to, uint256 _value) internal {
        // Ensure sending is to valid address not 0x0 address  
        require(_to != address(0));
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(_from, _to, _value);
    }
    ///assign the bankcontract to spender
     function approve(address _spender, uint256 _value) external returns (bool) {
        require(_spender != address(0));
        allowance[msg.sender][_spender] = _value; //append owner, spender to get allowance value
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

     function transferFrom(address _from, address _to, uint256 _value) external returns (bool) {
        require(_value <= balanceOf[_from]);
        require(_value <= allowance[_from][msg.sender]);
        allowance[_from][msg.sender] -= (_value);
        _transfer(_from, _to, _value);
        return true;
    }
/// function allows to borrow
    function borrowLoan(address payable borrower, uint256 loanAmount) public accountOwner() noReentrancy() returns (bool success) {
        accountNumber = borrower;
        require(msg.sender == borrower, "Invalid account!");
        require(loanAmount <= loanPool);
        loanPool -= loanAmount;
        uint256 borrowerBalance = balanceOf[borrower] + loanAmount;
        assert(bankBalance == borrowerBalance);
        
        return true;
    }

}