
// SPDX-License-Identifier: MITs

pragma solidity 0.8.13;
pragma abicoder v2;


import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "../interfaces/IdExcountPoolDeployer.sol";
import "../interfaces/IdExcountPool.sol";
import "../interfaces/IUniswapV2Pair.sol";
import "../interfaces/IUniswapV2Router02.sol";

abstract contract dExcountPoolConfig {

    IDiscountPoolDeployer public DiscountMain;
    IERC20 public saleToken;
    IUniswapV2Router02 public pancake; 

    enum saleType {BASEPRICE, MARKETPRICE} // 0 - BASEPRICE, 1 - MARKETPRICE

    saleType public currentSale;

    address public poolAdmin;
    address public deadWallet = 0x000000000000000000000000000000000000dEaD;

    uint8 public currentState; // 1 - configState, 2 - burnState , 3 - claimState, 4 - buyBackState.
    bool public isWhiteList;
    bool public isPoolBlock;
    bool public isReferral;
    bool public isReferralTokenEnable;
    
    uint256 public totalAmounUsedtoBuyBack;
    uint256 public soldOutTokens;
    uint256 public redeemTokens;
    uint256 public offeringAmount;
    uint256 public currentDiscount;
    uint256 public startTime;
    uint256 public endTime;
    uint256 public minimumDeposit;
    uint256 public maximumDeposit;
    uint256 public buyBackFee;
    uint256 public claimDate;
    uint256 public currentBasePrice;
    uint256 public referralShare;

    uint256 internal constant precision = 1e18;

    string public profileURI;

    modifier onlyOperator() {
        require((msg.sender == poolAdmin) || 
                (msg.sender == DiscountMain.PlatformWalletAddress()));
        _;
    } // , "dExcountPool: Unable to access"

    modifier onlyMainAdmin() {
        require(msg.sender == DiscountMain.PlatformWalletAddress());
        _;
    } // ,"dExcountPool: only platform admin accessible"

    function setBasePrice(uint256 newPrice) external onlyOperator {
        currentBasePrice = newPrice;
    }

    function setProfileURI(string memory _profileURI) public onlyOperator {
        profileURI = _profileURI;
    }

    function setReferralTokenEnable(bool status) external onlyOperator {
        isReferralTokenEnable = status;
    }

    function setReferralBonus(bool status) external onlyOperator {
        isReferral = status;
    }

    function setReferralShare(uint256 newReferralShare) external onlyOperator {
        referralShare = newReferralShare;
    }

    /**
     * @dev This function is help to update the platformSoldTokensFeeEnabled state.
     * 
     * Can only be called by the current owner.
     * 
     * Requirements:
     *      
     * - `status` true means enable and false means disable.
     */    

    function setWhiteList(bool status) external onlyOperator {
        isWhiteList = status;
    }

    /**
     * @dev This function is help to block the particular pool.
     * If it's enable, no one can able to use the that discountSale contract.
     * 
     * Can only be called by the current owner.
     * 
     * Requirements:
     *     
     * - `status` true means enable and false means disable.
     */     
    function blockPool(bool status) external onlyMainAdmin{
        isPoolBlock = status;
    }   


    function poolTimeUpdateForTesting(uint256 _startTime,uint256 _endTime,uint256 _claimDate) external onlyOperator{
        startTime = _startTime;
        endTime = _endTime;
        claimDate = _claimDate;
    }
}