// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import "../UtilityContract/AbstractUtilityContract.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title ERC721 Airdropper Contract
/// @author webb3george
/// @notice This contract facilitates the airdropping of ERC721 tokens to multiple recipients.
contract ERC721Airdropper is AbstractUtilityContract, Ownable {
    constructor() payable Ownable(msg.sender) {}

    IERC721 public token;
    address public treasury;

    uint256 public constant MAX_AIRDROP_BATCH_SIZE = 300;

    /// @dev Error if contract is already initialized
    error AlreadyInitialized();
    /// @dev Error if no approved tokens for airdrop
    error NoApprovedTokens();
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
        (address _deployManager, address _tokenAddress, address _treasury, address _owner) =
            abi.decode(_initData, (address, address, address, address));

        setDeployManager(_deployManager);

        token = IERC721(_tokenAddress);
        treasury = _treasury;

        Ownable.transferOwnership(_owner);

        initialized = true;
        return (true);
    }

    /// @notice Returns the initialization data for deploying a new ERC721Airdropper contract
    /// @param _deployManager The address of the deploy manager
    /// @param _tokenAddress The address of the ERC721 token contract
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

    function airdrop(address[] calldata receivers, uint256[] calldata tokenIds) external onlyOwner {
        require(tokenIds.length <= MAX_AIRDROP_BATCH_SIZE, BatchSizeExceeded());
        require(receivers.length == tokenIds.length, ArraysLengthMissmatch());
        require(token.isApprovedForAll(treasury, address(this)), NoApprovedTokens());

        for (uint256 i = 0; i < receivers.length;) {
            token.safeTransferFrom(treasury, receivers[i], tokenIds[i]);
            unchecked {
                ++i;
            }
        }
    }
}
