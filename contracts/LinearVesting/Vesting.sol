// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import "../UtilityContract/AbstractUtilityContract.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./IVesting.sol";

import {VestingLib} from "./VestingLib.sol";

contract Vesting is IVesting, AbstractUtilityContract, Ownable {
    using VestingLib for IVesting.VestingInfo;
    constructor() payable Ownable(msg.sender) {}

    bool private initialized;

    IERC20 public token;
    uint256 public allocatedTokens;

    modifier notInitialized() {
        require(!initialized, AlreadyInitialized());
        _;
    }

    mapping(address => VestingInfo) public vestings;

    function initialize(bytes memory _initData) external override notInitialized returns (bool) {
        (address _tokenAddress, address _owner) = abi.decode(_initData, (address, address));

        token = IERC20(_tokenAddress);

        Ownable.transferOwnership(_owner);

        initialized = true;
        return (true);
    }

    function startVesting(IVesting.VestingParams calldata params) external onlyOwner {
        uint256 blockTimeStamp = block.timestamp;

        if (params.beneficiary == address(0)) revert InvalidAddress();
        if (params.duration == 0) revert DurationCantBeZero();
        if (params.totalAmount == 0) revert AmountCantBeZero();
        if (params.startTime < blockTimeStamp) revert StartTimeShouldBeFuture(params.startTime, blockTimeStamp);
        if (params.claimCooldown < params.duration) revert CooldownCantBeLongerThanDuration();
        uint256 availableBalance = token.balanceOf(address(this)) - allocatedTokens;
        if (availableBalance < params.totalAmount) {
            revert InsufficientBalanceOfContract(availableBalance, params.totalAmount);
        }

        VestingInfo storage vesting = vestings[params.beneficiary];

        if (vesting.created && vesting.totalAmount != vesting.claimed) revert VestingAlreadyExist();

        vesting.totalAmount = params.totalAmount;
        vesting.startTime = params.startTime;
        vesting.cliff = params.cliff;
        vesting.duration = params.duration;
        vesting.claimed = 0;
        vesting.lastClaimTime = 0;
        vesting.claimCooldown = params.claimCooldown;
        vesting.minClaimAmount = params.minClaimAmount;
        vesting.created = true;

        unchecked {
            allocatedTokens = allocatedTokens + params.totalAmount;
        }

        emit VestingCreated(params.beneficiary, params.totalAmount, blockTimeStamp);
    }

    function claim() public {
        VestingInfo storage vesting = vestings[msg.sender];
        if (!vesting.created) revert VestingNotFound();
        uint256 blockTimeStamp = block.timestamp;

        if (blockTimeStamp <= vesting.startTime + vesting.cliff) {
            revert ClaimNotAvailable(blockTimeStamp, vesting.startTime + vesting.cliff);
        }
        if (blockTimeStamp < vesting.lastClaimTime + vesting.claimCooldown) revert CooldownNotPassedYet();

        uint256 claimable = vesting.claimableAmount();
        if (claimable == 0) revert NothingToClaim();
        if (claimable < vesting.minClaimAmount) revert BelowMinClaimAmount();
        if (claimable + vesting.claimed > vesting.totalAmount) revert CantClaimMoreThanTotalAmount();

        unchecked {
            vesting.claimed = vesting.claimed + claimable;
            vesting.lastClaimTime = blockTimeStamp;
            allocatedTokens = allocatedTokens - claimable;
        }

        require(token.transfer(msg.sender, claimable));

        emit Claim(msg.sender, claimable, blockTimeStamp);
    }

    function withdrawUnallocated(address _to) external onlyOwner {
        uint256 available = token.balanceOf(address(this)) - allocatedTokens;

        if (available <= 0) revert NothingToWithdraw();

        require(token.transfer(_to, available));

        emit TokensWithdrawn(_to, available, block.timestamp);
    }

    function vestedAmount(address _claimer) public view returns (uint256) {
        return vestings[_claimer].vestedAmount();
    }

    function claimableAmount(address _claimer) public view returns (uint256) {
        return vestings[_claimer].claimableAmount();
    }

    function getInitData(address _tokenAddress, uint256 _allocatedTokens, address _owner)
        external
        pure
        returns (bytes memory)
    {
        return (abi.encode(_tokenAddress, _allocatedTokens, _owner));
    }
}
