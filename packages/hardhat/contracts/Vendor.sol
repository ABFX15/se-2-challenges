pragma solidity 0.8.4; //Do not change the solidity version as it negativly impacts submission grading
// SPDX-License-Identifier: MIT

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {YourToken} from "./YourToken.sol";

contract Vendor is Ownable {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/
    event BuyTokens(address buyer, uint256 amountOfETH, uint256 amountOfTokens);

    /*//////////////////////////////////////////////////////////////
                               FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    YourToken public yourToken;

    uint256 public constant TOKENS_PER_ETH = 100;

    constructor(address tokenAddress) {
        yourToken = YourToken(tokenAddress);
    }

    /*//////////////////////////////////////////////////////////////
                            PUBLIC FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    function buyTokens() public payable {
        require(msg.value > 0, "More ETH required");

        uint256 amountOfTokens = msg.value * TOKENS_PER_ETH;
        require(yourToken.balanceOf(address(this)) >= amountOfTokens, "Not enough tokens");

        bool success = yourToken.transfer(msg.sender, amountOfTokens);
        require(success, "Transfer failed");

        emit BuyTokens(msg.sender, msg.value, amountOfTokens);
    }


    function withdraw() public onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }


    function sellTokens(uint256 _amount) public {
        uint256 theAmount = _amount / TOKENS_PER_ETH;
        require(address(this).balance >= theAmount, "Insufficient ETH balance");

        bool success = yourToken.transferFrom(msg.sender, address(this), _amount);
        require(success, "Transfer failed");

        (bool sent,) = msg.sender.call{value: theAmount}("");
        require(sent, "Failed to send ETH");
    }


    receive() external payable {}

} 
