// SPDX-License-Identifier: MIT
pragma solidity 0.8.4; //Do not change the solidity version as it negativly impacts submission grading

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker {
    ExampleExternalContract public exampleExternalContract;

    event Stake(address, uint256);

    mapping(address => uint256) public balances;

    uint256 public constant threshold = 1 ether;
    uint256 public deadline = block.timestamp + 30 seconds;
    bool public openForWithdraw;

    constructor(address exampleExternalContractAddress) {
        exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
    }
    
    modifier notCompleted() {
        require(!exampleExternalContract.completed(), "Already completed");
        _;
    }

    function stake() public payable {
        balances[msg.sender] += msg.value;
        emit Stake(msg.sender, msg.value);
    }


    function execute() public payable notCompleted {
        require(!exampleExternalContract.completed(), "Already completed");
        require(block.timestamp >= deadline, "Deadline not reached");

        if(address(this).balance >= threshold) {
            exampleExternalContract.complete{value: address(this).balance}();
        } else {
            openForWithdraw = true;
        }
    }


    function timeLeft() public view returns (uint256) {
        if (block.timestamp <= deadline) {
            return deadline - block.timestamp;
        } else {
            return 0;
        }
    }


    function withdraw() public notCompleted {
        require(openForWithdraw, "Already withdrawn");
        uint256 userAmount = balances[msg.sender];
        require(userAmount > 0, "Nothing to withdraw");

        balances[msg.sender] = 0;

        (bool success, ) = msg.sender.call{value: userAmount}("");
        require(success, "Failed to withdraw");
    }

    receive() external payable {
        emit Stake(msg.sender, msg.value);  
    }

    
}
    // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
    // (Make sure to add a `Stake(address,uint256)` event and emit it for the frontend `All Stakings` tab to display)

    // After some `deadline` allow anyone to call an `execute()` function
    // If the deadline has passed and the threshold is met, it should call `exampleExternalContract.complete{value: address(this).balance}()`

    // If the `threshold` was not met, allow everyone to call a `withdraw()` function to withdraw their balance

    // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend

    // Add the `receive()` special function that receives eth and calls stake()

