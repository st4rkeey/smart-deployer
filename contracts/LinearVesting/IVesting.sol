// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

interface IVesting {
    struct VestingInfo {
        uint256 totalAmount;
        uint256 startTime;
        uint256 cliff;
        uint256 duration;
        uint256 claimed;
        uint256 lastClaimTime;
        uint256 claimCooldown;
        uint256 minClaimAmount;
        bool created;
    }

    struct VestingParams {
        address beneficiary;
        uint256 totalAmount;
        uint256 startTime;
        uint256 cliff;
        uint256 duration;
        uint256 claimCooldown;
        uint256 minClaimAmount;
    }

    // ----------------------------------------------------------------
    // Events
    // ----------------------------------------------------------------

    event Claim(address beneficiary, uint256 amount, uint256 timestamp);
    event VestingCreated(address beneficiary, uint256 totalAmount, uint256 creationTime);
    event TokensWithdrawn(address to, uint256 amount, uint256 timestamp);

    // ----------------------------------------------------------------
    // Errors
    // ----------------------------------------------------------------

    error VestingNotFound();
    error AlreadyInitialized();
    error ClaimNotAvailable(uint256 blockTimestamp, uint256 AvailableTimeFrom);
    error NothingToClaim();
    error InsufficientBalanceOfContract(uint256 availableBalance, uint256 totalAmount);
    error VestingAlreadyExist();
    error AmountCantBeZero();
    error StartTimeShouldBeFuture(uint256 startTime, uint256 currentTimeStamp);
    error DurationCantBeZero();
    error CooldownCantBeLongerThanDuration();
    error InvalidAddress();
    error BelowMinClaimAmount();
    error CooldownNotPassedYet();
    error CantClaimMoreThanTotalAmount();
    error NothingToWithdraw();

    // ----------------------------------------------------------------
    // Functions
    // ----------------------------------------------------------------

    function startVesting(VestingParams calldata params) external;

    function vestedAmount(address _claimer) external view returns (uint256);

    function claim() external;

    function claimableAmount(address _claimer) external view returns (uint256);

    function withdrawUnallocated(address _to) external;

    function getInitData(address _tokenAddress, uint256 _allocatedTokens, address _owner)
        external
        pure
        returns (bytes memory);
}
