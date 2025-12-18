// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import "./IVesting.sol";

library VestingLib {
    function vestedAmount(IVesting.VestingInfo storage v) internal view returns (uint256) {
        uint256 blockTimeStamp = block.timestamp;
        if (blockTimeStamp < v.startTime + v.cliff) return 0;
        uint256 passed = blockTimeStamp - (v.startTime + v.cliff);
        if (passed > v.duration) passed = v.duration;
        return (v.totalAmount * passed) / v.duration;
    }

    function claimableAmount(IVesting.VestingInfo storage v) internal view returns (uint256) {
        uint256 vested = vestedAmount(v);
        if (vested <= v.claimed) return 0;
        return vested - v.claimed;
    }
}
