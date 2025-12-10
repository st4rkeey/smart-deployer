// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import "../UtilityContract/IUtilityContract.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ERC20Airdropper is IUtilityContract, Ownable {
    constructor() payable Ownable(msg.sender) {}

    IERC20 public token;
    uint256 public amount;
    address public treasury;

    uint256 public constant MAX_AIRDROP_BATCH_SIZE = 300;

    error AlreadyInitialized();
    error NotEnoughApprovedTokens();
    error ArraysLengthMissmatch();
    error TransferFailed();
    error BatchSizeExceeded();

    modifier NotInitialized() {
        require(!initialized, AlreadyInitialized());
        _;
    }

    bool private initialized;

    function initialize(bytes memory _initData) external override NotInitialized returns (bool) {
        (address _tokenAddress, uint256 _airdropAmount, address _treasury, address _owner) =
            abi.decode(_initData, (address, uint256, address, address));

        token = IERC20(_tokenAddress);
        amount = _airdropAmount;
        treasury = _treasury;

        Ownable.transferOwnership(_owner);

        initialized = true;
        return (true);
    }

    function getInitData(address _tokenAddress, uint256 _airdropAmount, address _treasury, address _owner)
        external
        pure
        returns (bytes memory)
    {
        return (abi.encode(_tokenAddress, _airdropAmount, _treasury, _owner));
    }

    function airdrop(address[] calldata receivers, uint256[] calldata amounts) external onlyOwner {
        require(receivers.length <= MAX_AIRDROP_BATCH_SIZE, BatchSizeExceeded());
        require(receivers.length == amounts.length, NotEnoughApprovedTokens());
        require(token.allowance(treasury, address(this)) >= amount, NotEnoughApprovedTokens());

        address treasuryAddress = treasury;

        for (uint256 i = 0; i < receivers.length;) {
            require(token.transferFrom(treasuryAddress, receivers[i], amounts[i]), TransferFailed());
            unchecked {
                ++i;
            }
        }
    }
}
