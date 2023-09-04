//SPDX-License-Identifier:MIT
pragma solidity ^0.8.8;

import {IStandardToken} from "./IstandardToken.sol";
import {ERC20} from "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";

contract StakingContract is ERC20 {
    IStandardToken standardToken;// give the interface a name so we can use it


    uint constant withdrawTime = 1 minutes;
    uint8 constant rate = 5;
    uint8 constant percentage = 100;
    uint256 public globalTokenStaked;


struct User{
    uint amountStaked; //the amount the user staked
    uint timeStaked;  //the day the user staked 
}

mapping(address => User) public user;
event Staked(uint amountstaked,uint totalAmountStaked, uint time);

constructor(address _standardToken)ERC20("nathToken", "NRT") {
    standardToken = IStandardToken(_standardToken); //IStanda
    
}


function stake(uint amount) public {
   
  uint balance = standardToken.balanceOf(msg.sender);
  //i check the balance of the user and assign it to a uint variable because the balanceOf returns uint 
    require(balance >= amount, "Insuficient balance");
  bool status = standardToken.transferFrom(msg.sender, address(this), amount);
  //bool status because the transferFrom in her contract returns boolean
  require(status == true, "Transfer fail");
   
    User storage _user = user[msg.sender];
    _user.amountStaked += amount;
    _user.timeStaked = block.timestamp;
    globalTokenStaked += amount;
    emit Staked(amount, _user.amountStaked, block.timestamp);
}

function getStaked(address _addr) public view returns(uint _staked) {
    User storage _user = user[_addr];
    _staked = _user.amountStaked;
}

function withdraw() external {
    User storage _user = user[msg.sender];
    uint totalStaked = getStaked(msg.sender);
    uint256 _stakedtime = _user.timeStaked;
    uint256 _withdrawStakedTime = _stakedtime + withdrawTime;

    if(_withdrawStakedTime > block.timestamp) {
        revert("calm down, e neva reach harvest time");
    }
    else {
        require(totalStaked > 0, "no staked token");
         uint256 stakeReward  = (totalStaked * rate * withdrawTime) / percentage;
        uint256 rewardGiven = stakeReward / 60;
         _mint(msg.sender,rewardGiven);
        standardToken.transfer(msg.sender, totalStaked);
        _user.amountStaked = 0;
        globalTokenStaked -= totalStaked; //subtract the amount user withdrew from the total token staked by the users 
    }
}
//getReward helps user to know the expected reward on the amount staked.
    function getReward(uint256 _onAmount) public pure returns(uint _reward) {
     _reward = (_onAmount * rate) / 100;
}
    
function withdrawEther() external {
    standardToken.withdrawEther();
}
}