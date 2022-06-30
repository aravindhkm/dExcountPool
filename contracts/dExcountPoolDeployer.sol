
// SPDX-License-Identifier: MITs

pragma solidity 0.8.13;
pragma abicoder v2;

import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Create2.sol";

import "./interfaces/IdExcountPoolDeployer.sol";
import "./interfaces/IdExcountPool.sol";
import "./config/Errors.sol";
import "./config/dExcountPoolDeployerConfig.sol";
import "./dExcountPool.sol";

contract dExcountPoolDeployer is Pausable, AccessControl, dExcountConfig{
    using SafeERC20 for IERC20;
    using Address for address payable;

    bytes32 public constant SIGNER_ROLE = keccak256("SIGNER_ROLE");

    mapping (address => address) public pairInfo;
    mapping (address => bool) public poolContains;
    address[] private pools;
    
    constructor(
        address _treasuryWallet,
        address _PlatformWalletAddress
        ) dExcountConfig(_treasuryWallet,_PlatformWalletAddress) {

        _setRoleAdmin(DEFAULT_ADMIN_ROLE, DEFAULT_ADMIN_ROLE);
        _setRoleAdmin(SIGNER_ROLE, DEFAULT_ADMIN_ROLE);
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(SIGNER_ROLE, msg.sender);
    }   

    receive() external payable {}

    /**
     * @dev Triggers stopped state.
     * 
     * Can only be called by the current owner.
     * 
     * Requirements:
     *
     * - The contract must not be paused.
    */
    function pause() public onlyOwner{
      _pause();
    }
    
    /**
     * @dev Triggers normal state.
     * 
     * Can only be called by the current owner.
     * 
     * Requirements:
     *
     * - The contract must not be unpaused.
     */
    function unpause() public onlyOwner{
      _unpause();
    }

    function poolConfig(
        address pool,
        uint256 discount,
        uint256 startTime,
        uint256 endTime,
        uint256 minimumDeposit,
        uint256 maximumDeposit,
        uint256 buyBackFee,
        uint256 claimDate,
        uint8 saleType,
        string memory profileURI
    ) external payable whenNotPaused {
        require(validateSellDate(startTime,endTime), Errors.VL_INVALID_AMOUNT);
        require(buyBackFee >= minimumBuyBack && buyBackFee <= maximumBuyBack, Errors.VL_INVALID_AMOUNT);
        require(discount >= minimumDiscount && discount <= maximumDiscount, Errors.VL_INVALID_AMOUNT);

        uint256 claimDuration = claimDate - (endTime);
        require(claimDuration >= minimumClaimedDate && claimDuration <= maximumClaimedDate , Errors.VL_INVALID_AMOUNT);
        
        {
            IDiscountPool(pool).poolConfig(
                discount,
                startTime,
                endTime,
                minimumDeposit,
                maximumDeposit,
                buyBackFee,
                claimDate,
                saleType,
                profileURI
            );
        }
        
    }

    /**
     * @dev This function is help to create the discountPool.
     * 
     * No restriction, anyone can call.
     * 
     * Requirements:
     *
     * - `token` from and to tokens.From token must be authorized by admin.       
     * - `offeringAmount` How many token our you going to give the discountPool.       
     * - `startTime` Pool starttime.       
     * - `endTime` Pool endtime.       
     * - `discount` discount percentage eg 30%.       
     * - `poolAdmin` project owner.        
     * - `minimumDeposit` Minimum amount of from token.       
     * - `maximumDeposit` Maximum amount of from token.
     * - `buyBackFee` Buyback fee.
     */     
    function createPool(
        address token,
        uint256 offeringAmount,
        address poolAdmin) external payable whenNotPaused {
        require(msg.value >= platformFlatFee, Errors.VL_INVALID_AMOUNT);
        require(poolAdmin != address(0), Errors.VL_INVALID_AMOUNT);

        if(poolContains[pairInfo[token]]){
            uint8 currentState = IDiscountPool(pairInfo[token]).currentState();
            require(currentState == 4 || currentState == 3 , Errors.VL_INVALID_AMOUNT);
        }else {
            poolContains[pairInfo[token]] = true;
        }

       bytes32 salt = keccak256(abi.encodePacked(token,block.timestamp));
       address newPool = Create2.deploy(0,salt,type(dExcountPool).creationCode);
        
        {
            distributeOffer(
                token,
                _msgSender(),
                address(newPool),
                offeringAmount
            );
        }
        
    }

    function distributeOffer(
        address token,
        address user,
        address pool,
        uint256 offeringAmount
        ) internal {
        IERC20(token).safeTransferFrom(user,pool,offeringAmount); 

        if(platformSoldTokensFeeEnabled){
            IERC20(token).safeTransferFrom(user,owner(),offeringAmount * (platformSoldTokensFee) / (1e2));
        }
        pools.push(pairInfo[token] = pool);
        {            
            payable(treasuryWallet).transfer(platformFlatFee/2);
            payable(PlatformWalletAddress).transfer(platformFlatFee/2);
        }       
    }

    function validateSellDate(uint256 startDate,uint256 endDate) internal view returns (bool) {
        return (
            block.timestamp < startDate && 
            startDate < endDate && 
            block.timestamp + (maxSellStartDuration) >= startDate &&
            startDate + (maxSellEndDuration) >= endDate
        );
    }

    /**
     * @dev Returns the number of discountPools.
     */
    function poolLength() public view returns (uint256) {
        return pools.length;
    }

    /**
     * @dev Returns the value stored at position `index` in the discountPool.
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function poolAt(uint256 index) public view returns (address) {
        return pools[index];
    }

    /**
     * @dev Returns true if the address is signer. 
     */      
    function isSigner(address signer) external view returns (bool) {
        return hasRole(SIGNER_ROLE,signer);
    }
}