// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract GovernanceToken is ERC20, Ownable {
    mapping(address => uint256) public votingPower;
    
    event TokensStaked(address indexed user, uint256 amount);
    event TokensUnstaked(address indexed user, uint256 amount);

    constructor() ERC20("CommunityGovToken", "CGT") {
        _mint(msg.sender, 1000000 * 10 ** decimals());
    }

    function stakeTokens(uint256 amount) external {
        require(balanceOf(msg.sender) >= amount, "Insufficient balance");
        _transfer(msg.sender, address(this), amount);
        votingPower[msg.sender] += amount;
        emit TokensStaked(msg.sender, amount);
    }

    function unstakeTokens(uint256 amount) external {
        require(votingPower[msg.sender] >= amount, "Insufficient voting power");
        _transfer(address(this), msg.sender, amount);
        votingPower[msg.sender] -= amount;
        emit TokensUnstaked(msg.sender, amount);
    }
}
