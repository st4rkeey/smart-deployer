// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import "../IUtilityContract.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ERC1155Airdropper is IUtilityContract, Ownable {

    constructor() Ownable(msg.sender) {}

    IERC1155 public token;
    address public treasury;

    error AlreadyInitialized();
    error NoApprovedTokens();
    error ArraysLengthMissmatch();
    error TransferFailed();

    modifier NotInitialized() {
        require(!initialized, AlreadyInitialized());
        _;
    }

    bool private initialized;

    function initialize(bytes memory _initData) external NotInitialized returns(bool){
        (address _tokenAddress, address _treasury, address _owner)  = abi.decode(_initData, (address, address, address));

        token = IERC1155(_tokenAddress);
        treasury = _treasury;

        Ownable.transferOwnership(_owner);

        initialized = true;
        return (true);
    }

    function getInitData(address _tokenAddress, address _treasury, address _owner) external pure returns(bytes memory) {
        return (abi.encode(_tokenAddress, _treasury, _owner));
    }

    function airdrop(address[] calldata receivers, uint256[] calldata amounts, uint256[] calldata tokenIds) external onlyOwner {
        require(receivers.length == amounts.length && receivers.length == tokenIds.length, ArraysLengthMissmatch());
        require(token.isApprovedForAll(treasury, address(this)), NoApprovedTokens());

        for (uint256 i = 0; i < receivers.length; i++) {
            token.safeTransferFrom(treasury, receivers[i], tokenIds[i], amounts[i], "");
        }
    }

}