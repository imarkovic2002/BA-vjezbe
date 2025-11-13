// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract CrowdFund {
    address public owner;
    uint public  goal;
    uint public deadline;
    uint public totalRaised;
    bool public goalReached;
    bool public fundsWithdrawn;

    mapping(address => uint) public contributions;

    event Donation(address indexed donor, uint amount);
    event FundsWithdrawn(address indexed owner, uint amount);
    event Refunded(address indexed contributor, uint amount);

    modifier onlyOwner(){
        require(msg.sender == owner, "You are not owner.");
        _;
    }

    modifier beforeDeadline() {
        require(block.timestamp < deadline, "Campaign ended");
        _;
    }

    modifier afterDeadline() {
        require(block.timestamp >= deadline, "Campaign not yet ended.");
        _;
    }

    constructor(uint _goal, uint _durationMinutes) {
        owner = msg.sender;
        goal = _goal;
        deadline = block.timestamp + (_durationMinutes * 1 minutes);
    }

    function donate() public payable beforeDeadline {
        require(msg.value > 0, "Must send ETH");

        contributions[msg.sender] += msg.value;
        totalRaised += msg.value;

        if (totalRaised >= goal) {
            goalReached = true;
        }

        emit Donation(msg.sender, msg.value);
    }

    function withdrawFunds() public onlyOwner afterDeadline {
        require(goalReached, "Goal not reached");
        require(!fundsWithdrawn, "Already withdrawn");
        
        uint amount = address(this).balance;
        fundsWithdrawn = true;

        payable(owner).transfer(amount);

        emit FundsWithdrawn(owner, amount);
    }

    function refund() public afterDeadline {
        require(!goalReached, "Goal was reached, no refunds!");

        uint contributed = contributions[msg.sender];
        require(contributed > 0, "Nothing to refund");

        contributions[msg.sender] = 0;
        payable(msg.sender).transfer(contributed);

        emit Refunded(msg.sender, contributed);
    }

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }

    function getTimeLeft() public view returns (uint) {
        if (block.timestamp >= deadline) {
            return 0;
        }
        return deadline - block.timestamp;
    }
}