//SPDX-License-Identifier:MIT
pragma solidity ^0.8.24;

import {BagelToken} from "./BagelToken.sol";
import {IERC20, SafeERC20} from "../lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import {MerkleProof} from "../lib/openzeppelin-contracts/contracts/utils/cryptography/MerkleProof.sol";
import {EIP712} from "../lib/openzeppelin-contracts/contracts/utils/cryptography/EIP712.sol";
import {ECDSA} from  "../lib/openzeppelin-contracts/contracts/utils/cryptography/ECDSA.sol";
contract MerkelAirdrop is EIP712{
    using SafeERC20 for IERC20;
    error MerkelAirdrop__InvalidProof();
    error MerkelAirdrop__HasAlreadyClaimedOnce();
    error MerkelAirdrop__InvalidSignature();

    address [] claimers;
    bytes32 private immutable i_MerkelRoot;
    IERC20 private immutable i_AirdropToken;

    mapping(address claimer=>bool claimed) private s_hasClaimed;
    event Claim(address account,uint256 amount);
    bytes32 private constant MESSAGE_TYPEHASH = keccak256("AirdropClaim(address account,uint256 amount)");

    struct AirdropClaim{
        address account;
        uint256 amount;

    }
    
    constructor(bytes32 MerkelRoot,IERC20 AirdropToken)EIP712("MerkelAirdrop","1"){
        i_AirdropToken=AirdropToken;
        i_MerkelRoot=MerkelRoot;
    }

    //make sure people don't claim more than once.
    /**
        @notice Follow Check-->Effects-->interactions
     */
    function claim(address account, uint256 amount, bytes32[] calldata merkleProof,uint8 v,bytes32 r,bytes32 s) external{

        //check for claimed or not
        if(s_hasClaimed[account]==true){
            revert MerkelAirdrop__HasAlreadyClaimedOnce();
        }


        //check for signature
        if(!_isValidSignature(account,getMessage(account,amount),v,r,s)){
            revert MerkelAirdrop__InvalidSignature();
        }

        //Combine account and amount together and hash them using kecckack
        //Hash it twice to avoid problem of second preImage attack :)
        bytes32 leaf = keccak256(bytes.concat(keccak256((abi.encode(account,amount)))));

        if(!MerkleProof.verify(merkleProof,i_MerkelRoot,leaf)){
            revert MerkelAirdrop__InvalidProof();
        }

        s_hasClaimed[account]=true;


        emit Claim(account,amount);
        //i_AirdropToken.transfer(account,amount);
        /**
            @notice Instead of using transfer, we will use SafeTransfer-->As it will revert when account doesn't accept
            ERC20 tokens        
         */
        
        i_AirdropToken.safeTransfer(account,amount);
        
    }

    function _isValidSignature(address account, bytes32 digest,uint8 v,bytes32 r,bytes32 s)
    internal pure returns(bool){
        (address actualSigner,,) = ECDSA.tryRecover(digest,v,r,s);
        return (actualSigner == account);

    }


    function getMessage(address account,uint256 amount) public view returns(bytes32){
        return _hashTypedDataV4(
            keccak256(abi.encode(MESSAGE_TYPEHASH,AirdropClaim({account: account , amount: amount})))
        );
    }


    function getMerkelRoot()external view  returns(bytes32){
        return i_MerkelRoot;
    }

    function getAirdropTokens() external view returns(IERC20){
        return i_AirdropToken;
    }
}
