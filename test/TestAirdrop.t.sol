//SPDX-License-Identifier:MIT
pragma solidity ^0.8.24;
import "../lib/forge-std/src/Test.sol";
import "../src/MerkelAirdrop.sol";
import "../src/BagelToken.sol";
import {ZkSyncChainChecker} from "../lib/foundry-devops/src/ZkSyncChainChecker.sol";
import {DeployMerkelAirdrop } from "../script/DeployMerkelAirdrop.s.sol";
contract TestAirdrop is Test,ZkSyncChainChecker{
    MerkelAirdrop public merkelAirdrop;
    BagelToken public bagelToken;


    bytes32 public ROOT = 0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;
    uint256 public AMOUNT= 25 * 1e18;
    bytes32 proof1=0x0fd7c981d39bece61f7499702bf59b3114a90e66b51ba2c53abdf7b62986c00a;
    bytes32 proof2=0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576;
    bytes32[] public PROOF = [proof1,proof2];
    uint256 public MINTING_AMOUNT=AMOUNT * 4;
    address user;
    uint256 userPrivKey;

    address public gasPayer;



function setUp() external {
    (user, userPrivKey) = makeAddrAndKey("user");
     gasPayer = makeAddr("gasPayer");
    if (!isZkSyncChain()) {
        DeployMerkelAirdrop deployer = new DeployMerkelAirdrop();
        (merkelAirdrop, bagelToken) = deployer.run();
    } else {
        bagelToken = new BagelToken();
        merkelAirdrop = new MerkelAirdrop(ROOT, bagelToken);
        bagelToken.mint(bagelToken.owner(), MINTING_AMOUNT);
        bagelToken.transfer(address(merkelAirdrop), MINTING_AMOUNT);
    }
}

    function testUsersCanClaim() public{
        uint256 startingBalance = bagelToken.balanceOf(user);

        //get the digest
        bytes32 digest = merkelAirdrop.getMessage(user, AMOUNT);

        
        (uint8 v,bytes32 r, bytes32 s) = vm.sign(userPrivKey, digest);

        vm.prank(gasPayer);
        merkelAirdrop.claim(user, AMOUNT, PROOF,v,r,s);

        uint256 endingBalance = bagelToken.balanceOf(user);
        assertEq(endingBalance - startingBalance,AMOUNT);


    }
}