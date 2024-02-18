// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

interface DIAOracleV2 {
    function getValue(
        string memory _key
    ) external view returns (uint128, uint128);
}

contract DepositTreasure {
    using SafeERC20 for IERC20;

    enum DepositStatus {
        ACTIVE,
        CLOSED
    }

    event DepositCreated(uint _depositID, uint _amount, uint _startTime);
    event DepositWithdrawn(uint _depositID, uint _amount, uint _endTime);

    struct Deposit {
        uint value;
        uint startTime;
        uint128 price;
        DepositStatus status;
    }

    address ERC20Address; // wrapped BTC address
    uint FIVE_YEARS = 5 * 365 days;
    address ORCALE_ADDRESS = 0x61a598Cd6340B8edcb4faE7Eabcd117Ff371320e;

    mapping(uint _id => Deposit _deposit) depositIDToDeposit;
    mapping(uint _id => address _depositor) depositIDToDepositor;

    uint depositID = 0;

    constructor(address _address) {
        require(_address != address(0), "_address cannot be zero");

        ERC20Address = _address;
    }

    /// @notice Deposit the wrapped BTC
    /// @param _amount The amount of wrapped BTC to deposit
    function deposit(uint _amount) public {
        require(
            IERC20(ERC20Address).balanceOf(msg.sender) >= _amount,
            "Less tokens owned than specified _amount"
        );

        IERC20(ERC20Address).safeTransferFrom(
            msg.sender,
            address(this),
            _amount
        );

        Deposit memory _deposit = Deposit(
            _amount,
            block.timestamp,
            getPrice(),
            DepositStatus.ACTIVE
        );

        depositID++;
        depositIDToDeposit[depositID] = _deposit;
        depositIDToDepositor[depositID] = msg.sender;

        emit DepositCreated(depositID, _amount, block.timestamp);
    }

    /// @notice Withdraw the deposit
    /// @param _depositID The ID of the deposit
    function withdraw(uint _depositID) public {
        // Check if the sender is the depositor
        require(
            depositIDToDepositor[_depositID] == msg.sender,
            "Not the depositor"
        );
        // Check if the deposit is active
        require(
            depositIDToDeposit[_depositID].status == DepositStatus.ACTIVE,
            "Deposit is not active"
        );

        // Check if five years have passed
        bool _eligibleForWithdrawal = block.timestamp -
            depositIDToDeposit[_depositID].startTime <
            FIVE_YEARS;

        // Check if the price has doubled
        _eligibleForWithdrawal =
            _eligibleForWithdrawal &&
            depositIDToDeposit[_depositID].price * 2 < getPrice();

        require(
            _eligibleForWithdrawal,
            "Not eligible for withdrawal (5 years or double price)"
        );

        IERC20(ERC20Address).safeTransfer(
            depositIDToDepositor[_depositID],
            depositIDToDeposit[_depositID].value
        );

        depositIDToDeposit[_depositID].status = DepositStatus.CLOSED;

        emit DepositWithdrawn(
            _depositID,
            depositIDToDeposit[_depositID].value,
            block.timestamp
        );
    }

    /// @notice Get the price of BTC in USD
    /// @return The price of BTC in USD
    function getPrice() private view returns (uint128) {
        (uint128 result, ) = DIAOracleV2(ORCALE_ADDRESS).getValue("BTC/USD");

        return result;
    }
}
