// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract WrappedEth is ERC20 {
    constructor() ERC20("Wrapped Ether", "WETH") {}

    event Deposit(address _address, uint _value);
    event Withdraw(address _address, uint _value);

    receive() external payable {
        deposit();
    }

    fallback() external payable {
        deposit();
    }

    function deposit() public payable {
        _mint(msg.sender, msg.value);
        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(uint amount) public {
        require(
            balanceOf(msg.sender) >= amount,
            "you can not withdraw more than you have"
        );
        _burn(msg.sender, amount);
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "withdraw failed");
        emit Withdraw(msg.sender, amount);
    }
}
