// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// Decentralized CrowdFunding smartcontract
contract Decentralized_CrowdFunding_Contract
{
   uint public Target;
   uint public Deadline;
   uint public MinContribution;
   address public manager;
   uint public Raisedamount;
   uint public Noofcontributors;
   mapping(address=>uint) public contributors;

   struct Request
   {
      string description;
      address payable recepient;
      uint value;
      bool completed;
      uint noofVoters;
      mapping(address=>bool) voters;
   }

   uint public NumOfRequests;
   mapping(uint=>Request) public requests;

   constructor (uint _Target , uint _Deadline)
   {
       Target = _Target;
       Deadline = block.timestamp + _Deadline;
       MinContribution = 300 wei;
       manager = msg.sender;
   }

   function SendEther() public payable
   {
       require(block.timestamp < Deadline , "Deadline has been passed");
       require(msg.value>=MinContribution,"The amount u sent doesnt meet the minimum contribution");

       if(contributors[msg.sender] == 0)
       {
           Noofcontributors++;
       }

       contributors[msg.sender]+=msg.value;
       Raisedamount+=msg.value;        
   }

   function getContractBalance() public view returns(uint)
   {
       return address(this).balance;
   }

   function refund() public
   {
       require(block.timestamp > Deadline &&  Raisedamount < Target , "Refund not possible" );
       require(contributors[msg.sender] > 0 ,"First you need to be a contributor");
       address payable person = payable(msg.sender);
       person.transfer(contributors[person]);
       contributors[person] = 0 ;
   }

   modifier OnlyManager() 
   {
       require(msg.sender == manager ,"Only manager can call this function");
       _;
   }

   function createRequests(string memory _description , address payable _recepient , uint _value) public OnlyManager
   {
     Request storage newRequest = requests[NumOfRequests];
     NumOfRequests++;
     newRequest.description = _description;
     newRequest.recepient = _recepient;
     newRequest.value = _value;
     newRequest.completed = false;
     newRequest.noofVoters = 0;
   }

   function voteRequests(uint _RequestNo) public
   {
       require(contributors[msg.sender]>0,"You need to be a contributor first to vote");
       Request storage ThisRequest = requests[_RequestNo];
       require(ThisRequest.voters[msg.sender] == false , "You have already voted");
       ThisRequest.voters[msg.sender] == true;
       ThisRequest.noofVoters+=1;
   }

   function makePayments(uint request_no) public OnlyManager
   {
       require(Raisedamount>=Target,"The contribution has not reached the target value");
       Request storage ThisRequest = requests[request_no];
       require(ThisRequest.completed == false , "Payment already completed");
       require(ThisRequest.noofVoters > Noofcontributors/2,"Majority dont support you");
       ThisRequest.recepient.transfer(ThisRequest.value);
       ThisRequest.completed = true;
   }

}
