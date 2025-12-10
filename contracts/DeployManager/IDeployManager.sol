// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

interface IDeployManager {
    event NewContractAdded(address _contractAddress, uint256 _fee, bool _isActive, uint256 _timestamp);
    event ContractFeeUpdated(address _contractAddress, uint256 _oldFee, uint256 _newFee, uint256 _timestamp);
    event ContractStatusUpdated(address _contractAddress, bool _isActive, uint256 _timestamp);
    event NewDeployment(address _contractAddress, address _deployer, uint256 _fee, uint256 _timestamp);

    struct ContractInfo {
        uint256 fee;
        bool isActive;
        uint256 registeredAt;
    }

    error ContractNotActive();
    error InsufficientFunds();
    error ContractDoesNotExist();
    error DeployFailed();

    function deploy(address _utilityContract, bytes calldata _initData) external payable returns (address);

    function addNewContract(address _contractAddress, uint256 _fee, bool _isActive) external;

    function updateFee(address _contractAddress, uint256 _newFee) external;

    function changeContractStatus(address _contractAddress, bool _isActive) external;
}
