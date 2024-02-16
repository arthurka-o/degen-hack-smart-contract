// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract DepositTreasure {
    using SafeERC20 for IERC20;

    enum DepositStatus {
        ACTIVE, // 1
        CLOSED // 2
    }

    event DepositCreated(uint _depositID, uint _amount, uint _startTime);
    event DepositWithdrawn(uint _depositID, uint _amount, uint _endTime);

    struct Deposit {
        uint value;
        uint startTime;
        uint price;
        DepositStatus status;
    }

    mapping(uint _id => Deposit _deposit) depositIDToDeposit;
    mapping(uint _id => address _depositor) depositIDToDepositor;

    uint depositID = 0;
    address ERC20Address; // wrapped ETH address
    uint FIVE_YEARS = 5 * 365 days;

    address oracleAddress;

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

        uint _currentPrice = getPrice();

        Deposit memory _deposit = Deposit(
            _amount,
            block.timestamp,
            _currentPrice,
            DepositStatus.ACTIVE
        );

        depositID++;
        depositIDToDeposit[depositID] = _deposit;
        depositIDToDepositor[depositID] = msg.sender;

        emit DepositCreated(depositID, _amount, block.timestamp);
    }

    function withdraw(uint _depositID) public {
        // check for time or price
        // withdraw to depositor
        // change status to closed

        require(
            depositIDToDepositor[_depositID] == msg.sender,
            "Not the depositor"
        );
        require(
            depositIDToDeposit[_depositID].status == DepositStatus.ACTIVE,
            "Deposit is not active"
        );

        bool _eligibleForWithdrawal = block.timestamp -
            depositIDToDeposit[_depositID].startTime <
            FIVE_YEARS;

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

    function getPrice() private returns (uint) {
        // checks oracle for price
    }
}
