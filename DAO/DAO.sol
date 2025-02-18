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

// React + TailwindCSS UI for DAO Governance
// Install dependencies: `npm install ethers react-icons shadcn/ui`

import { useState, useEffect } from "react";
import { ethers } from "ethers";
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";

const contractAddress = "YOUR_CONTRACT_ADDRESS";
const abi = [
    "function stakeTokens(uint256 amount) external",
    "function unstakeTokens(uint256 amount) external",
    "function balanceOf(address owner) external view returns (uint256)",
    "function votingPower(address owner) external view returns (uint256)"
];

export default function GovernanceUI() {
    const [amount, setAmount] = useState("");
    const [balance, setBalance] = useState("0");
    const [votingPower, setVotingPower] = useState("0");
    
    async function connectWallet() {
        if (window.ethereum) {
            const provider = new ethers.providers.Web3Provider(window.ethereum);
            await window.ethereum.request({ method: "eth_requestAccounts" });
            return provider.getSigner();
        } else {
            alert("MetaMask not detected");
        }
    }

    async function fetchData() {
        const signer = await connectWallet();
        const contract = new ethers.Contract(contractAddress, abi, signer);
        const userAddress = await signer.getAddress();
        const userBalance = await contract.balanceOf(userAddress);
        const userVotingPower = await contract.votingPower(userAddress);
        setBalance(ethers.utils.formatEther(userBalance));
        setVotingPower(ethers.utils.formatEther(userVotingPower));
    }

    async function stakeTokens() {
        const signer = await connectWallet();
        const contract = new ethers.Contract(contractAddress, abi, signer);
        const tx = await contract.stakeTokens(ethers.utils.parseEther(amount));
        await tx.wait();
        fetchData();
    }

    async function unstakeTokens() {
        const signer = await connectWallet();
        const contract = new ethers.Contract(contractAddress, abi, signer);
        const tx = await contract.unstakeTokens(ethers.utils.parseEther(amount));
        await tx.wait();
        fetchData();
    }

    useEffect(() => {
        fetchData();
    }, []);

    return (
        <div className="flex flex-col items-center p-10 bg-gray-900 text-white min-h-screen">
            <h1 className="text-4xl font-bold mb-5">DAO Governance</h1>
            <Card className="w-full max-w-md p-5 bg-gray-800">
                <CardContent>
                    <p className="text-lg">Balance: {balance} CGT</p>
                    <p className="text-lg">Voting Power: {votingPower}</p>
                    <input type="text" placeholder="Amount" className="w-full p-2 my-3 text-black" value={amount} onChange={(e) => setAmount(e.target.value)} />
                    <Button onClick={stakeTokens} className="w-full my-2 bg-green-500 hover:bg-green-600">Stake</Button>
                    <Button onClick={unstakeTokens} className="w-full my-2 bg-red-500 hover:bg-red-600">Unstake</Button>
                </CardContent>
            </Card>
        </div>
    );
}
