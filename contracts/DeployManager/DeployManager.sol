// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";
import "../UtilityContract/AbstractUtilityContract.sol";
import "./IDeployManager.sol";

contract DeployManager is IDeployManager, Ownable {
    constructor() payable Ownable(msg.sender) {}

    mapping(address => address[]) public deployedContracts;
    mapping(address => ContractInfo) public contractsData;

    function deploy(address _utilityContract, bytes calldata _initData) external payable override returns (address) {
        ContractInfo memory info = contractsData[_utilityContract];

        require(info.isActive, ContractNotActive());
        require(msg.value >= info.fee, InsufficientFunds());
        require(info.registeredAt > 0, ContractDoesNotExist());

        address clone = Clones.clone(_utilityContract);
        bool success = IUtilityContract(clone).initialize(_initData);
        require(success, DeployFailed());

        payable(owner()).transfer(msg.value);

        deployedContracts[msg.sender].push(clone);

        emit NewDeployment(clone, msg.sender, info.fee, block.timestamp);

        return clone;
    }

    function addNewContract(address _contractAddress, uint256 _fee, bool _isActive) external override onlyOwner {
        contractsData[_contractAddress] = ContractInfo(_fee, _isActive, block.timestamp);

        emit NewContractAdded(_contractAddress, _fee, _isActive, block.timestamp);
    }

    function updateFee(address _contractAddress, uint256 _newFee) external override onlyOwner {
        require(contractsData[_contractAddress].registeredAt > 0, ContractDoesNotExist());
        uint256 _oldFee = contractsData[_contractAddress].fee;
        contractsData[_contractAddress].fee = _newFee;

        emit ContractFeeUpdated(_contractAddress, _oldFee, _newFee, block.timestamp);
    }

    function changeContractStatus(address _contractAddress, bool _isActive) external override onlyOwner {
        require(contractsData[_contractAddress].registeredAt > 0, ContractDoesNotExist());
        contractsData[_contractAddress].isActive = _isActive;

        emit ContractStatusUpdated(_contractAddress, _isActive, block.timestamp);
    }
}
