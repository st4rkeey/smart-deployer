// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import "../UtilityContract/IUtilityContract.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ERC1155Airdropper is IUtilityContract, Ownable {
    constructor() payable Ownable(msg.sender) {}

    uint256 public constant MAX_AIRDROP_BATCH_SIZE = 300;

    IERC1155 public token;
    address public treasury;

    error AlreadyInitialized();
    error NoApprovedTokens();
    error ReceiversLengthMismatch();
    error AmountsLengthMismatch();
    error TransferFailed();
    error BatchSizeExceeded();

    modifier NotInitialized() {
        require(!initialized, AlreadyInitialized());
        _;
    }

    bool private initialized;

    function initialize(bytes memory _initData) external override NotInitialized returns (bool) {
        (address _tokenAddress, address _treasury, address _owner) = abi.decode(_initData, (address, address, address));

        token = IERC1155(_tokenAddress);
        treasury = _treasury;

        Ownable.transferOwnership(_owner);

        initialized = true;
        return (true);
    }

    function getInitData(address _tokenAddress, address _treasury, address _owner)
        external
        pure
        returns (bytes memory)
    {
        return (abi.encode(_tokenAddress, _treasury, _owner));
    }

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
