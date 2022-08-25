// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract Lottery{

    struct Candidate{
        address addr;
        uint candidateSlot;
    }

    mapping(uint256 => Candidate) candidate;
    uint256 currentId;
    uint256 winningNumber;
    address manager;
    bool hasEnded;
    bool canClaim;
    bool isinit;

    // Amount Must be greater than 1 eth
    error AmountMustBeGreaterThanOneEth();

    //Only the manager is allowed
    error OnlyManager();

    //you cannot claim now
    error CannotClaimNow();
     
    //Contract cannot be init
     error CannotInit();

    modifier onlyManager{
        if(msg.sender != manager){
            revert OnlyManager();
        }
        _;
    }

    modifier cannotInit{
        if(isinit){
            revert CannotInit();
        }
        _;
    }

    //This code is serving a s a constructor ,in this case 
    function initialize(address _manager) public cannotInit{
    manager= _manager;
    }
    
    //this functionAdds a user to the lottery

    function cast(uint256 _candidateSlot)public payable{
        if(msg.value < 1 ether){
            revert AmountMustBeGreaterThanOneEth();
        }
        candidate[currentId].addr = msg.sender;
        candidate[currentId].candidateSlot = _candidateSlot;

        currentId++;
    }
    
    function selectWinner() public onlyManager{
        uint256 randomNumber = uint256(keccak256(abi.encode(block.timestamp, block.difficulty)));
        winningNumber = uint256(randomNumber % 255);
        canClaim = true;
    }

    function claimLottery() public onlyManager{
        if(!canClaim){
            revert CannotClaimNow();
        }

        //sending ether to all lucky winners

        for(uint256 i = 0; i < currentId; i++){
            if(candidate[i].candidateSlot == winningNumber){
                payable(candidate[1].addr).transfer(10 ether);
            }
        }

        hasEnded = true;
    }
    
    function withdraw() public payable onlyManager{
        if(!hasEnded){
            revert CannotClaimNow();
        }
        payable(manager).transfer(address(this).balance);
        }
        function revealWinnerNumbe() public view returns(uint256){
            return winningNumber;
        }
    
}