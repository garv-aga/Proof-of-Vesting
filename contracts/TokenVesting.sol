// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract TokenVesting {
    address public beneficiary;
    uint256 public startTimestamp;
    uint256 public vestingDuration;
    uint256 public totalAmount;
    uint256 public claimedAmount;

    IERC20 public token;

    event VestingStarted(address beneficiary, uint256 startTimestamp, uint256 vestingDuration, uint256 totalAmount);
    event TokensClaimed(address beneficiary, uint256 amount, uint256 timestamp);
    event VestingEnded(address beneficiary, uint256 timestamp);

    modifier onlyBeneficiary() {
        require(msg.sender == beneficiary, "Not the beneficiary");
        _;
    }

    constructor(
        address _beneficiary,
        uint256 _startTimestamp,
        uint256 _vestingDuration,
        uint256 _totalAmount,
        address _token
    ) {
        beneficiary = _beneficiary;
        startTimestamp = _startTimestamp;
        vestingDuration = _vestingDuration;
        totalAmount = _totalAmount;
        token = IERC20(_token);

        emit VestingStarted(_beneficiary, _startTimestamp, _vestingDuration, _totalAmount);
    }

    function claim() external onlyBeneficiary {
        require(block.timestamp >= startTimestamp, "Vesting has not started yet");

        uint256 vestedAmount = calculateVestedAmount();

        require(vestedAmount > claimedAmount, "No tokens to claim");

        uint256 claimableAmount = vestedAmount - claimedAmount;

        claimedAmount = vestedAmount;

        token.transfer(beneficiary, claimableAmount);

        emit TokensClaimed(beneficiary, claimableAmount, block.timestamp);

        if (block.timestamp >= startTimestamp + vestingDuration) {
            emit VestingEnded(beneficiary, block.timestamp);
        }
    }

    function calculateVestedAmount() public view returns (uint256) {
        if (block.timestamp >= startTimestamp + vestingDuration) {
            return totalAmount;
        } else {
            uint256 timeSinceStart = block.timestamp - startTimestamp;
            uint256 vestedPercentage = (timeSinceStart * 100) / vestingDuration;
            return (totalAmount * vestedPercentage) / 100;
        }
    }
}
