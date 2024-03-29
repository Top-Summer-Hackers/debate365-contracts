// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract MockToken is ERC20 {
    constructor(
        string memory _name,
        string memory _symbol
    ) ERC20(_name, _symbol) {}

    function faucet(uint256 _amount, address _to) external {
        _mint(_to, _amount);
    }

    // to be avoided in coverage
    function test() external {}
}
