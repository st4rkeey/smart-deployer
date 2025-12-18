// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";
import "../UtilityContract/AbstractUtilityContract.sol";
import "./IDeployManager.sol";

/// @title DeployManager - Factory for utility contracts
/// @author webb3george
/// @notice Contract to manage deployment of utility contracts
/// @dev Uses OpenZeppelin's Clones and Ownable; assumes utility contracts implement IUtilityContract
contract DeployManager is IDeployManager, Ownable, ERC165 {
    constructor() payable Ownable(msg.sender) {}

    /// @dev Maps deployer address to an array of deployed contracts
    mapping(address => address[]) public deployedContracts;
    /// @dev Maps a utility contract address to it's params
    mapping(address => ContractInfo) public contractsData;

    /// @inheritdoc IDeployManager
    function deploy(address _utilityContract, bytes calldata _initData) external payable override returns (address) {
        ContractInfo memory info = contractsData[_utilityContract];

        require(info.isActive, ContractNotActive());
        require(msg.value >= info.fee, InsufficientFunds());
        require(info.registeredAt > 0, ContractDoesNotExist());

        address clone = Clones.clone(_utilityContract);
        bool success = IUtilityContract(clone).initialize(_initData);
        require(success, DeployFailed());

        (bool sent,) = payable(owner()).call{value: info.fee}("");
        require(sent, TransactionFailed());

        deployedContracts[msg.sender].push(clone);

        emit NewDeployment(clone, msg.sender, info.fee, block.timestamp);

        return clone;
    }

    /// @inheritdoc IDeployManager
    function addNewContract(address _contractAddress, uint256 _fee, bool _isActive) external override onlyOwner {
        require(
            AbstractUtilityContract(_contractAddress).supportsInterface(type(IUtilityContract).interfaceId),
            ContractIsNotUtilityContract()
        );
        require(contractsData[_contractAddress].registeredAt == 0, ContractAlreadyRegistered());

        contractsData[_contractAddress] = ContractInfo(_fee, _isActive, block.timestamp);

        emit NewContractAdded(_contractAddress, _fee, _isActive, block.timestamp);
    }

    /// @inheritdoc IDeployManager
    function updateFee(address _contractAddress, uint256 _newFee) external override onlyOwner {
        require(contractsData[_contractAddress].registeredAt > 0, ContractDoesNotExist());
        uint256 _oldFee = contractsData[_contractAddress].fee;
        contractsData[_contractAddress].fee = _newFee;

        emit ContractFeeUpdated(_contractAddress, _oldFee, _newFee, block.timestamp);
    }

    /// @inheritdoc IDeployManager
    function changeContractStatus(address _contractAddress, bool _isActive) external override onlyOwner {
        require(contractsData[_contractAddress].registeredAt > 0, ContractDoesNotExist());
        contractsData[_contractAddress].isActive = _isActive;

        emit ContractStatusUpdated(_contractAddress, _isActive, block.timestamp);
    }

    /// @inheritdoc ERC165
    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, ERC165) returns (bool) {
        return interfaceId == type(IDeployManager).interfaceId || super.supportsInterface(interfaceId);
    }
}
