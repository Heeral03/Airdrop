//SPDX-License-Identifier:MIT
pragma solidity ^0.8.24;

import {MerkelAirdrop} from "../src/MerkelAirdrop.sol";
import {BagelToken} from "../src/BagelToken.sol";
import {Script} from "../lib/forge-std/src/Script.sol";
import {IERC20} from "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
contract DeployMerkelAirdrop is Script{
    bytes32 private s_merkelRoot=0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;
    uint256 private s_amountToSend = 4* 25 *1e18;
    function deployMerkelAirdrop() public 
    returns (MerkelAirdrop, BagelToken)
    {
      vm.startBroadcast();
      BagelToken bagelToken= new BagelToken();
      MerkelAirdrop merkelAirdrop = new MerkelAirdrop(s_merkelRoot, IERC20(address(bagelToken)));
      bagelToken.mint(bagelToken.owner(), s_amountToSend);
      bagelToken.transfer(address(merkelAirdrop),s_amountToSend );
      vm.stopBroadcast();
      return (merkelAirdrop,bagelToken);

    }


    function run() external returns(MerkelAirdrop, BagelToken){
        return deployMerkelAirdrop();
    }


}