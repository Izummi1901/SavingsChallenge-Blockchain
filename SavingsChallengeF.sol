// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

interface IERC20 {

    function transferFrom(address from,address to,uint256 amount ) external returns (bool);
    function transfer(address to,uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract SavingsChallengeF{

    IERC20 public token;
    address public deployedOwner;

    uint256 public registrationDeadline;
    uint256 public challengeDeadline;
    uint256 public depositAmount;

    uint256 public totalParticipants;
    uint256 public forfeitedCount;
    uint256 public forfeitedMoney;
    uint256 public totalFinished;
    bool public finalResult;

    struct Participant {
        bool joined;
        bool forfeited;
        bool claimed;
    }

    mapping(address => Participant) public participants;
    address[] public participantslist;

    event Joined(address participant, uint256 amount);
    event Forfeited(address participant, uint256 amount);
    event Claimed(address participant, uint256 paymentAmount);
    event Finalized(uint256 totalFinished,uint256 forfeitedCount, uint256 forfeitedMoney);

    error registrationClosed();
    error challengeNotOver();
    error alreadyJoined();
    error notParticipant();
    error alreadyForfeited();
    error alreadyClaimed();
    error transferFail();

    constructor(address _token,uint256 _registrationDuration,uint256 _depositAmount,uint256 _challengeDuration){
        if(_token==address(0)) revert transferFail();
        if(_registrationDuration==0 ||_challengeDuration==0) revert challengeNotOver();

        token = IERC20(_token);
        deployedOwner = msg.sender;
        depositAmount= _depositAmount;
        registrationDeadline=block.timestamp+_registrationDuration;
        challengeDeadline=registrationDeadline+_challengeDuration;
    }
    modifier onlyParticipant() {
        if(!participants[msg.sender].joined) revert notParticipant();
        _;
    }

    function join() external {
        if(block.timestamp > registrationDeadline) revert registrationClosed();
        if(participants[msg.sender].joined) revert alreadyJoined();

        participants[msg.sender]= Participant(true,false,false);
        participantslist.push(msg.sender);
        totalParticipants++;

        bool ok = token.transferFrom(msg.sender, address(this), depositAmount);
        if(!ok) revert transferFail();

        emit Joined(msg.sender, depositAmount);
    }

    function forfeit() external onlyParticipant{
        Participant storage p =participants[msg.sender];

        if(block.timestamp>= challengeDeadline) revert challengeNotOver();
        if(p.forfeited) revert alreadyForfeited();
        if(p.claimed) revert alreadyClaimed();

        p.forfeited=true;
        forfeitedCount++;
        forfeitedMoney+= depositAmount;

        emit Forfeited(msg.sender, depositAmount);
    }

    function finalize() public{
        if(block.timestamp<challengeDeadline) revert challengeNotOver();
        if(finalResult) return;
        
        uint256 count;
        uint256 len = participantslist.length;

        for (uint256 i=0; i<len;i++) 
        {
            if(!participants[participantslist[i]].forfeited){
                count++;
            }
        }
        totalFinished=count;
        finalResult=true;

        emit Finalized(totalFinished, forfeitedCount, forfeitedMoney);
    }

    function claim() external onlyParticipant{
        if(block.timestamp<challengeDeadline) revert challengeNotOver();
        if(!finalResult){
            finalize();
        }

        Participant storage p = participants[msg.sender];
        if(p.forfeited) revert alreadyForfeited();
        if(p.claimed) revert alreadyClaimed();
        if(totalFinished==0) revert challengeNotOver();

        p.claimed=true;
        uint256 bonus=forfeitedMoney/totalFinished;
        uint256 paymentAmount=depositAmount+bonus;
        bool ok = token.transfer(msg.sender, paymentAmount);
        if (!ok) revert transferFail();

         emit Claimed(msg.sender, paymentAmount);

    }

    function getParticipants() external view returns (address[] memory) {
    return participantslist;
}

}