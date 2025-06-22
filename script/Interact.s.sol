//SPDX-License-Identifier:MIT
pragma solidity ^0.8.24;
import "../lib/forge-std/src/Script.sol";
import { DevOpsTools } from "../lib/foundry-devops/src/DevOpsTools.sol";
import {MerkelAirdrop} from "../src/MerkelAirdrop.sol";


contract ClaimAirdrop is Script{
    error __ClaimAirdrop__InvalidSignatureLength();


    address private constant CLAIMING_ADDRESS = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    uint256 private CLAIMING_AMOUNT = 25 * 1e18;
    bytes32 PROOF1 = 0xd1445c931158119b00449ffcac3c947d028c0c359c34a6646d95962b3b55c6ad;
    bytes32 PROOF2 = 0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576;    
    bytes32[] proof= [PROOF1, PROOF2];
    bytes private SIGNATURE = hex"f5a9bd6cd964ddd38d1f86c4c2352c87563f75b22120c47b1336c98542956e03630e5a6181ba9b5fb7c203b543f1c9dbe0a6169e93c06977881c675c3b58aa071c";

    function claimAirdrop(address airdrop) public{
        vm.startBroadcast();
        (uint8 v, bytes32 r, bytes32 s) = splitSignature(SIGNATURE);
        MerkelAirdrop(airdrop).claim(CLAIMING_ADDRESS, CLAIMING_AMOUNT, proof , v, r ,s);
        vm.stopBroadcast();
        
    }

    function splitSignature(bytes memory sig)public returns(uint8 v, bytes32 r, bytes32 s){
        if(sig.length!=65){
            revert __ClaimAirdrop__InvalidSignatureLength();

        }
        assembly{
            r:= mload(add(sig,32))
            s:= mload(add(sig,64))
            v:= byte(0,mload(add(sig,96)))
        }

        (v,r,s);
    }
    function run() external{
        address mostRecentlyDeployed  = DevOpsTools.get_most_recent_deployment("MerkelAirdrop", block.chainid);
        claimAirdrop(mostRecentlyDeployed);
    }


}