// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IDiscountPool{
    function poolAdmin() external view returns (address);
    function currentState() external view returns(uint8);
    function createdState() external view returns(bool);
    function isWhiteList() external view returns(bool);
    function isPoolBlock() external view returns(bool);
    function poolTimeUpdate(uint256,uint256) external;
    function setWhiteList(bool status) external;
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
    ) external;
}