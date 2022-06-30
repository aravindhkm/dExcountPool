

// SPDX-License-Identifier: MITs
import "@openzeppelin/contracts/access/Ownable.sol";

pragma solidity 0.8.13;
pragma abicoder v2;

abstract contract dExcountConfig is Ownable{

    uint256 public platformFlatFee;
    uint256 public platformSoldTokensFee;
    uint256 public platformRaisedAmountFee;
    uint256 public minimumBuyBack;
    uint256 public maximumBuyBack;
    uint256 public maxSellStartDuration;
    uint256 public maxSellEndDuration;
    uint256 public minimumDiscount;
    uint256 public maximumDiscount;
    uint256 public minimumClaimedDate;
    uint256 public maximumClaimedDate;
        
    address public treasuryWallet;
    address public PlatformWalletAddress;
    
    bool public platformSoldTokensFeeEnabled;

    constructor(
        address _treasuryWallet,
        address _PlatformWalletAddress
    ) {
        platformFlatFee = 4e17;
        platformSoldTokensFee = 2;
        platformRaisedAmountFee = 2;
        minimumBuyBack = 50;
        maximumBuyBack = 90;
        maxSellStartDuration = 604800;
        maxSellEndDuration = 604800;
        minimumDiscount = 1;
        maximumDiscount = 90;
        minimumClaimedDate = 86400;
        maximumClaimedDate = 864000;

        treasuryWallet = _treasuryWallet;
        PlatformWalletAddress = _PlatformWalletAddress;
    }

    /**
     * @dev This function is help to update the platformFlatFee percentage.
     * 
     * Can only be called by the current owner.
     * 
     * Requirements:
     *
     * - `amount` platformFlatFee value.
     */          
    function platformFlatFeeUpdate(uint256 amount) public onlyOwner {
        require(amount != 0, "invalid amount");
        platformFlatFee = amount;
    }

    /**
     * @dev This function is help to update the platformSoldTokensFee percentage.
     * 
     * Can only be called by the current owner.
     * 
     * Requirements:
     *
     * - `amount` platformSoldTokensFee value.
     */    
    function platformSoldTokensFeeUpdate(uint256 amount) public onlyOwner {
        require(amount != 0, "invalid amount");
        platformSoldTokensFee = amount;
    }


    /**
     * @dev This function is help to update the platformRaisedAmountFee percentage.
     * 
     * Can only be called by the current owner.
     * 
     * Requirements:
     *
     * - `amount` new platformRaisedAmountFee.
     */     
    function platformRaisedAmountFeeUpdate(uint256 amount) public onlyOwner {
        require(amount != 0, "invalid amount");
        platformRaisedAmountFee = amount;
    }

    /**
     * @dev This function is help to update the MinimumBuyBack fee and MaximumBuyBack fee.
     * 
     * Can only be called by the current owner.
     * 
     * Requirements:
     *
     * - `minimum` minimum buyback fee. eg like 70%.
     * - `maximum` maximum buyback fee. eg like 100%.
     */    
    function buyBackUpdate(uint256 minimum,uint256 maximum) public onlyOwner {
        minimumBuyBack = minimum;
        maximumBuyBack = maximum;
    }

    /**
     * @dev This function is help to update the maxSellStartDuration duration. 
     * Eg contract currently have a 7 days.
     * 
     * Can only be called by the current owner.
     * 
     * Requirements:
     *
     * - `startDuration` newStartDuration.
     * - `endDuration` newEndDuration.
     */     
    function setSellDuration(uint256 startDuration,uint256 endDuration) public onlyOwner {
        maxSellStartDuration = startDuration;
        maxSellEndDuration = endDuration;
    }

    /**
     * @dev This function is help to update the discount minimum and maximum percentage.
     * 
     * Can only be called by the project owner.
     * 
     * Requirements:
     *
     * - `minimum` minimum discount value.
     * - `maximum` maximum discount value.
     */  
    function setDiscountMinAndMax(uint256 minimum,uint256 maximum) public onlyOwner {
        minimumDiscount = minimum;
        maximumDiscount = maximum;
    }

    /**
     * @dev This function is help to update the claimDate duration.
     * 
     * Can only be called by the current owner.
     * 
     * Requirements:
     *
     * - `newMin` minimumClaimedDate.
     * - `newMax` maximumClaimedDate.
     */   
    function setClaimDate(uint256 newMin,uint256 newMax) public onlyOwner {
        minimumClaimedDate = newMin;
        maximumClaimedDate = newMax;
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
    function platformSoldTokensFeeEnabledUpdate(bool status) external onlyOwner {
        platformSoldTokensFeeEnabled = status;
    }

    /**
     * @dev This function is help to update the treasuryWallet account.
     * 
     * Can only be called by the current owner.
     * 
     * Requirements:
     *
     * - `account` new treasuryWallet.
     */    
    function treasuryWalletUpdate(address account) public onlyOwner {
        treasuryWallet = account;
    }
    
    /**
     * @dev This function is help to update the PlatformWalletAddress account.
     * 
     * Can only be called by the current owner.
     * 
     * Requirements:
     *
     * - `account` new PlatformWalletAddress.
     */ 
    function PlatformWalletAddressUpdate(address account) public onlyOwner {
        PlatformWalletAddress = account;
    }

}