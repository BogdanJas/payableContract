// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {PriceConverter} from "./PriceConverter.sol";

contract FundMe{
    using PriceConverter for uint256;

    uint256 public constant MIN_USD = 5e18;
    address[] public funders;
    mapping(address funder => uint256 amountFunded) public addressToAmountFunded;
    address public immutable i_owner;

    constructor() {
        i_owner = msg.sender;    
    }

    function fund() public payable{
        require(msg.value.getConversionRate() >= MIN_USD, "Nor enough ETH"); //1e18 = 1ETH
        funders.push(msg.sender);
        addressToAmountFunded[msg.sender] = addressToAmountFunded[msg.sender] + msg.value;
    }

    function withdraw() public onlyOwner { 
        for(uint256 index = 0; index < funders.length; index++){
            address funder = funders[index];
            addressToAmountFunded[funder] = 0;
        }

        funders = new address[](0);
        // payable(msg.sender).transfer(address(this).balance); //Transfer throw error

        // bool sendSuccess = payable(msg.sender).send(address(this).balance); //Send returns bool
        // require(sendSuccess, "Send failed");

        (bool callSuccess, ) =  payable(msg.sender).call{value: address(this).balance}(""); // Call forward all gas or set gas, returns bool
        require(callSuccess, "Call failed");
    }

    modifier onlyOwner() {
        require(msg.sender == i_owner, "Cannot withdraw unless owner.");
        _;
    }

    receive() external payable{
        fund();
    }

    fallback() external payable{
        fund();
    }
}