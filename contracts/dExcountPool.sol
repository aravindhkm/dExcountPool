
// SPDX-License-Identifier: MITs

pragma solidity 0.8.13;
pragma abicoder v2;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/draft-EIP712.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

import "./config/dExcountPoolConfig.sol";

contract dExcountPool is Ownable, ReentrancyGuard, Pausable, EIP712, dExcountPoolConfig {
    using SafeERC20 for IERC20;
    using Address for address payable;
    using Counters for Counters.Counter;

    struct userLockStore {
        uint256 lockAmount;
        uint256 lockTime;
        uint256 claimTime;
    }  

    struct referralStore {
        uint256 bnbEarned;
        uint256 tokenEarned;
        uint256 totalReferrals;
    }

    bytes32 private constant _PERMIT_TYPEHASH =
        keccak256("Permit(address user,uint256 value,uint256 nonce,uint256 deadline)");

    mapping (address => userLockStore) public userLockInfo;
    mapping(address => Counters.Counter) private _nonces;
    mapping (address => referralStore) public referralCommission;

    event lockEvent(
        address indexed user,
        uint256 amount,
        uint256 time
    );
    event unlockEvent(
        address indexed user,
        uint256 amount,
        uint256 time
    );

    constructor(
        address _token,
        address _poolAdmin,       
        uint256 _offeringAmount
        ) EIP712("DiscountPool", "1") {
        DiscountMain = IDiscountPoolDeployer(_msgSender());
        saleToken = IERC20(_token);
        poolAdmin = _poolAdmin;
        offeringAmount = _offeringAmount;
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
    function pause() public onlyOperator{
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
    function unpause() public onlyOperator{
      _unpause();
    }

    function poolConfig( 
        uint256 _discount,
        uint256 _startTime,
        uint256 _endTime,
        uint256 _minimumDeposit,
        uint256 _maximumDeposit,
        uint256 _buyBackFee,
        uint256 _claimDate,
        uint8 _saleType,
        string memory _profileURI
    ) external {
        require(currentState == 0);  
        require(_saleType < 2); 
        require(_minimumDeposit < _maximumDeposit);

        currentDiscount = _discount;
        startTime = _startTime;
        endTime = _endTime;
        minimumDeposit = _minimumDeposit;
        maximumDeposit = _maximumDeposit;
        buyBackFee = _buyBackFee;
        claimDate = _claimDate;
        profileURI = _profileURI;
        currentSale = saleType(_saleType);
        currentBasePrice = 5e18;

        currentState++;
        // testnet
        pancake = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    }
    
    /**
     * @dev Return the PlatformRaisedAmountFee.
     */     
    function getPlatFormBuyBackFee() public view returns (uint256) {
        return DiscountMain.PlatformRaisedAmountFee();
    }

    /**
     * @dev Returns the amount of tokens owned by `pool`.
     */  
    function bnbBalance() public view returns (uint256) {
        return (address(this).balance);        
    }

    /**
     * @dev Returns the amount of tokens owned by `pool`.
     */  
    function tokenBalance() public view returns (uint256) {
        return saleToken.balanceOf(address(this));
    }

    /**
     * @dev Transfers poolAdmin ownership of the contract to a new account (`newOwner`).
     * Can only be called by the poolAdmin.
     */
    function transferProjectOwnerShip(address newOwner) external returns (bool) {        
        require(newOwner != address(0));
        require(msg.sender == poolAdmin);

        poolAdmin = newOwner;
        return true;
    }
 

    /**
     * @dev This function is help to the swap to pool token0 to token1.
     * 
     * Can only be called by the discountSale contract.
     * 
     * - E.g. User can swap bnb to busd. User can able to receive 30% more than pancakeswap.
     */   
    function swap(address referrer) external payable nonReentrant whenNotPaused returns (bool) {
        require(!isWhiteList);
        return _swap(_msgSender(),referrer,msg.value);
    }

    /**
     * @dev See {IERC20Permit-permit}.
     */  
    function swapWithPermit(
        address referrer,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external payable nonReentrant whenNotPaused returns (bool) {
        require(isWhiteList);
        require(block.timestamp <= deadline);

        bytes32 structHash = keccak256(abi.encode(_PERMIT_TYPEHASH, _msgSender(), msg.value, _useNonce(_msgSender()), deadline));
        bytes32 hash = _hashTypedDataV4(structHash);

        address signer = ECDSA.recover(hash, v, r, s);
        require(DiscountMain.isSigner(signer));

        return _swap(_msgSender(),referrer,msg.value);
    }

    function _swap(address user,address referrer,uint256 amount) internal returns (bool){
        require(!isPoolBlock);
        require(minimumDeposit <= msg.value && maximumDeposit >= msg.value);
        require(startTime < block.timestamp && endTime > block.timestamp);

        uint256 amountOut;
        if(currentSale == saleType.BASEPRICE) {
           (,,amountOut) = _getAmountOutForBasePrice(amount);
        } else if(currentSale == saleType.MARKETPRICE) {
            (,,amountOut) = _getAmountOutForMarketPrice(amount);
        }
       
        userLockInfo[user].lockAmount = userLockInfo[user].lockAmount + (amountOut);
        userLockInfo[user].lockTime = block.timestamp;
        emit lockEvent(user,amountOut,block.timestamp);

        if(isReferral && referrer != address(0)) {
            referralCommission[referrer].totalReferrals++;
            uint256 referrerPayout = amount * (referralShare) / (1e2);
            payable(referrer).sendValue(referrerPayout);
            referralCommission[referrer].bnbEarned = referralCommission[referrer].bnbEarned + (referrerPayout);

            if(isReferralTokenEnable) {
                uint256 refTokenPayout = amountOut * (referralShare) / (1e2);
                saleToken.safeTransfer(referrer,refTokenPayout);
                referralCommission[referrer].tokenEarned = referralCommission[referrer].tokenEarned + (refTokenPayout);
            }
        }
        return true;
    }

    /**
     * @dev This function is help to the buyback the all funds.
     *
     * Can only be called by the project owner and platform owner. 
     * 
     * 
     * - E.g. After the currentDiscount sale admin can be able to buyback the bnb to token.
     * 
     */  
    function buyBack() external whenNotPaused nonReentrant onlyOperator{
        uint256 currentBalance = address(this).balance;   

        require(endTime < block.timestamp);
        require(currentBalance > 0);
     
        uint256 getAmountOut = currentBalance * (buyBackFee) / (1e2);
        uint256 platFormFee = currentBalance * (getPlatFormBuyBackFee()) / (1e2);
        payable(DiscountMain.PlatformWalletAddress()).sendValue(platFormFee / 2);
        payable(DiscountMain.treasuryWallet()).sendValue(platFormFee / 2);
        totalAmounUsedtoBuyBack = totalAmounUsedtoBuyBack + (getAmountOut + (platFormFee));
        currentState++;

        address[] memory path = new address[](2);
        path[0] = pancake.WETH();
        path[1] = address(saleToken);

        pancake.swapExactETHForTokensSupportingFeeOnTransferTokens{value: getAmountOut}(
            0,
            path,
            address(this),
            block.timestamp
        );
    }
 
    /**
     * @dev This function is help to the claim all remaining tokens
     * 
     * Can only be called by the discountSale contract.
     * 
     * - E.g. after the confirm execution,admin can be able to claim the remaining token
     * - If platform owner doing this process, all the tokens will goes to the project owner.
     */    
    function claim() external nonReentrant whenNotPaused onlyOperator returns (bool) {
        require(claimDate < block.timestamp);
        require(currentState == 2);
        uint256 getAmountOut = address(this).balance;
        address[] memory path = new address[](2);
        path[0] = pancake.WETH();
        path[1] = address(saleToken);

        pancake.swapExactETHForTokensSupportingFeeOnTransferTokens{value: getAmountOut}(
            0,
            path,
            address(this),
            block.timestamp
        );

        saleToken.safeTransfer(poolAdmin,saleToken.balanceOf(address(this)) - (soldOutTokens - (redeemTokens)));
        currentState = 4;
        return true;
    }

    /**
     * @dev This function is help to the burn all remaining tokens.
     * 
     * Can only be called by the discountSale contract.
     * 
     * - E.g. after the confirm execution,admin can be able to burn the remaining token
     * - If platform owner doing this process, all the tokens will goes to the dead wallet.
     */    
    function burn() external nonReentrant whenNotPaused onlyOperator returns (bool){
        require(currentState == 2);
        require(claimDate < block.timestamp);
        uint256 getAmountOut = address(this).balance;
        address[] memory path = new address[](2);
        path[0] = pancake.WETH();
        path[1] = address(saleToken);

        pancake.swapExactETHForTokensSupportingFeeOnTransferTokens{value: getAmountOut}(
            0,
            path,
            address(this),
            block.timestamp
        );
        
        IERC20(saleToken).safeTransfer(deadWallet,saleToken.balanceOf(address(this)) - (soldOutTokens - (redeemTokens)));
        currentState = 3;
        return true;
    }

    /**
     * @dev This function is help to the redeem the allocated tokens.
     * 
     * - E.g. after the sale end,user can able to claim their tokens.
     */ 
    function redeem() external nonReentrant whenNotPaused {
        userLockStore storage store = userLockInfo[msg.sender];
        require(store.lockAmount > 0);
        require(claimDate <= block.timestamp);
        
        saleToken.safeTransfer(msg.sender,store.lockAmount);
        redeemTokens = redeemTokens + (store.lockAmount);
        store.lockAmount = 0;
        store.claimTime = block.timestamp;
        emit unlockEvent(msg.sender,store.lockAmount,block.timestamp);
    }

    function redeemByAccount(address[] calldata accounts) external nonReentrant whenNotPaused {
        for(uint256 i; i<accounts.length; i++) {
            userLockStore storage store = userLockInfo[accounts[i]];
            if(store.lockAmount > 0 && claimDate <= block.timestamp) {
                saleToken.safeTransfer(accounts[i],store.lockAmount);
                redeemTokens = redeemTokens + (store.lockAmount);
                store.lockAmount = 0;
                store.claimTime = block.timestamp;
                emit unlockEvent(accounts[i],store.lockAmount,block.timestamp);
            }                  
        }
    }

    /**
     * @dev This function is help to the recover the stucked funds.
     *
     * Can only be called by the platform owner. 
     * 
     * Requirements:
     *
     * - `token` token contract address.
     * - `amount` amount of tokens
     * 
     */      
    function recoverOtherToken(address _token,uint256 amount) external onlyMainAdmin {
        require(address(saleToken) != _token);
        saleToken.safeTransfer(DiscountMain.PlatformWalletAddress(),amount);
    }

    /**
     * @dev See {IERC20Permit-nonces}.
     */
    function nonces(address owner) public view returns (uint256) {
        return _nonces[owner].current();
    }

    /**
     * @dev See {IERC20Permit-DOMAIN_SEPARATOR}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32) {
        return _domainSeparatorV4();
    }

    /**
     * @dev "Consume a nonce": return the current value and increment.
     *
     * _Available since v4.1._
     */
    function _useNonce(address owner) internal virtual returns (uint256 current) {
        Counters.Counter storage nonce = _nonces[owner];
        current = nonce.current();
        nonce.increment();
    }

    function _getAmountOutForBasePrice(
        uint256 amount
    ) internal view returns(        
        uint256 marketAmount,
        uint256 discount,
        uint256 amountOut){
        marketAmount = amount * (currentBasePrice) / (precision);
        discount = marketAmount * (currentDiscount) / (100);
        return (marketAmount,discount,marketAmount+discount);        
    }

    function _getAmountOutForMarketPrice(
        uint256 amount
    ) internal view returns(
        uint256 marketAmount,
        uint256 discount,
        uint256 amountOut){
        address[] memory path = new address[](2);
        path[0] = pancake.WETH();
        path[1] = address(saleToken);

        uint[] memory getAmountOut = pancake.getAmountsOut(amount,path);
        discount = getAmountOut[1] * (currentDiscount) / (100);
        return (getAmountOut[1],discount,getAmountOut[1] + discount);   
    }

    function getAmountOutForBasePrice(
        uint256 amount
    ) external view returns(        
        uint256 marketAmount,
        uint256 discount,
        uint256 amountOut) {
        return (
            _getAmountOutForBasePrice(amount)
        );
    }

    function getAmountOutForMarketPrice(
        uint256 amount
    ) external view returns(        
        uint256 marketAmount,
        uint256 discount,
        uint256 amountOut) {
        return (
            _getAmountOutForMarketPrice(amount)
        );
    }
}