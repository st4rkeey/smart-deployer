// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import "../UtilityContract/AbstractUtilityContract.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title ERC1155 Airdropper Contract
/// @author webb3george
/// @notice This contract facilitates the airdropping of ERC1155 tokens to multiple recipients
contract ERC1155Airdropper is AbstractUtilityContract, Ownable {
    constructor() payable Ownable(msg.sender) {}

    uint256 public constant MAX_AIRDROP_BATCH_SIZE = 300;

    IERC1155 public token;
    address public treasury;

    /// @dev Error if contract is already initialized
    error AlreadyInitialized();
    /// @dev Error if no approved tokens for airdrop
    error NoApprovedTokens();
    /// @dev Error if receivers length does not match tokenIds length
    error ReceiversLengthMismatch();
    /// @dev Error if amounts length does not match tokenIds length
    error AmountsLengthMismatch();
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
        (address _deployManager, address _tokenAddress, address _treasury, address _owner) =
            abi.decode(_initData, (address, address, address, address));

        setDeployManager(_deployManager);

        token = IERC1155(_tokenAddress);
        treasury = _treasury;

        Ownable.transferOwnership(_owner);

        initialized = true;
        return (true);
    }

    /// @notice Returns the initialization data for deploying a new ERC1155Airdropper contract
    /// @param _deployManager The address of the deploy manager
    /// @param _tokenAddress The address of the ERC1155 token contract
    /// @param _treasury The address of the treasury holding the tokens to be airdropped
    /// @param _owner The address of the owner of the new contract
    /// @return The encoded initialization data
    function getInitData(address _deployManager, address _tokenAddress, address _treasury, address _owner)
        external
        pure
        returns (bytes memory)
    {
        return (abi.encode(_deployManager, _tokenAddress, _treasury, _owner));
    }

    /// @notice Airdrops ERC1155 tokens to multiple receivers
    /// @param receivers The array of receivers addresses
    /// @param amounts The array of amounts to be airdropped to each receiver
    /// @param tokenIds The array of token IDs to be airdropped to each receiver
    function airdrop(address[] calldata receivers, uint256[] calldata amounts, uint256[] calldata tokenIds)
        external
        onlyOwner
    {
        require(tokenIds.length <= MAX_AIRDROP_BATCH_SIZE, BatchSizeExceeded());
        require(receivers.length == tokenIds.length, ReceiversLengthMismatch());
        require(amounts.length == tokenIds.length, AmountsLengthMismatch());
        require(token.isApprovedForAll(treasury, address(this)), NoApprovedTokens());

        address treasuryAddress = treasury;

        for (uint256 i = 0; i < receivers.length;) {
            token.safeTransferFrom(treasuryAddress, receivers[i], tokenIds[i], amounts[i], "");
            unchecked {
                ++i;
            }
        }
    }
}
