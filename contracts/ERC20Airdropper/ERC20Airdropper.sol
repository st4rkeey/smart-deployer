// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../UtilityContract/AbstractUtilityContract.sol";

/// @title ERC20 Airdropper Contract
/// @author webb3george
/// @notice This contract facilitates the airdropping of ERC20 tokens to multiple recipients.
contract ERC20Airdropper is AbstractUtilityContract, Ownable {
    constructor() payable Ownable(msg.sender) {}

    IERC20 public token;
    uint256 public amount;
    address public treasury;

    uint256 public constant MAX_AIRDROP_BATCH_SIZE = 300;

    /// @dev Error if contract is already initialized
    error AlreadyInitialized();
    /// @dev Error if no approved tokens for airdrop
    error NotEnoughApprovedTokens();
    /// @dev Error if receivers length does not match tokenIds length
    error ArraysLengthMissmatch();
    /// @dev Error if transfer failed
    error TransferFailed();
    /// @dev Error if batch size exceeded
    error BatchSizeExceeded();

    /// @dev Modifier to check if contract is not initialized
    modifier notInitialized() {
        require(!initialized, AlreadyInitialized());
        _;
    }

    bool private initialized;

    /// @notice Initialization of the airdropper contract
    /// @param _initData The initialization data for the new contract instance
    /// @return The boolean value indicating whether the initialization was successful
    function initialize(bytes memory _initData) external override notInitialized returns (bool) {
        (address _deployManager, address _tokenAddress, uint256 _airdropAmount, address _treasury, address _owner) =
            abi.decode(_initData, (address, address, uint256, address, address));

        setDeployManager(_deployManager);

        token = IERC20(_tokenAddress);
        amount = _airdropAmount;
        treasury = _treasury;

        Ownable.transferOwnership(_owner);

        initialized = true;
        return (true);
    }

    /// @notice Returns the initialization data for deploying a new ERC20Airdropper contract
    /// @param _deployManager The address of the deploy manager
    /// @param _tokenAddress The address of the ERC20 token contract
    /// @param _airdropAmount The amount of tokens to be airdropped to each receiver
    /// @param _treasury The address of the treasury holding the tokens to be airdropped
    /// @param _owner The address of the owner of the new contract
    /// @return The encoded initialization data
    function getInitData(
        address _deployManager,
        address _tokenAddress,
        uint256 _airdropAmount,
        address _treasury,
        address _owner
    ) external pure returns (bytes memory) {
        return (abi.encode(_deployManager, _tokenAddress, _airdropAmount, _treasury, _owner));
    }

    /// @notice Airdrops ERC20 tokens to multiple receivers
    /// @param receivers The array of receivers addresses
    /// @param amounts The array of amounts to be airdropped to each receiver
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
