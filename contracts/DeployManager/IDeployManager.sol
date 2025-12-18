// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import "@openzeppelin/contracts/utils/introspection/ERC165.sol";

/// @title IDeployManager - Factory for utility contracts
/// @author webb3george
/// @notice Interface defines the functions, errors and events for the DeployManager contract
interface IDeployManager is IERC165 {
    // ----------------------------------------------------------------
    // Events
    // ----------------------------------------------------------------

    /// @notice Emitted when a new utility contract is added
    /// @param _contractAddress The address of the utility contract
    /// @param _fee The deployment fee(In Wei) for the utility contract
    /// @param _isActive The status of the utility contract
    /// @param _timestamp The timestamp when the contract was added
    event NewContractAdded(address _contractAddress, uint256 _fee, bool _isActive, uint256 _timestamp);

    /// @notice Emmited when deployment Fee updated
    /// @param _contractAddress The address of the utility contract
    /// @param _oldFee The amount of the previous deployment fee (in Wei)
    /// @param _newFee The amount of the new deployment fee (in Wei)
    /// @param _timestamp The timestamp when the fee was updated
    event ContractFeeUpdated(address _contractAddress, uint256 _oldFee, uint256 _newFee, uint256 _timestamp);

    /// @notice Emitted when a contract status updated
    /// @param _contractAddress The address of the utility contract
    /// @param _isActive New status value
    /// @param _timestamp The timestamp when the fee was updated
    event ContractStatusUpdated(address _contractAddress, bool _isActive, uint256 _timestamp);

    /// @notice Emmited when contract deployed
    /// @param _contractAddress The address of the utility contract
    /// @param _deployer Address of the contract deployer
    /// @param _fee Amount of fee to pay for contract deploy
    /// @param _timestamp The timestamp when the fee was updated
    event NewDeployment(address _contractAddress, address _deployer, uint256 _fee, uint256 _timestamp);

    /// @dev Stores registered contract info
    struct ContractInfo {
        uint256 fee; /// @notice Fee for contract deployment
        bool isActive; /// @notice Contract Status
        uint256 registeredAt; /// @notice Timestamp when contract registered
    }

    // ----------------------------------------------------------------
    // Errors
    // ----------------------------------------------------------------

    /// @dev Error if the contract is not active
    error ContractNotActive();

    /// @dev Not enough funds to deploy the contract
    error InsufficientFunds();

    /// @dev Error if the contract does not exist
    error ContractDoesNotExist();

    /// @dev Error if deployment fails
    error DeployFailed();

    /// @dev Error if transaction fails
    error TransactionFailed();

    /// @dev Error if the contract is not a utility contract
    error ContractIsNotUtilityContract();

    /// @dev Error when user tries to register already registered contract
    error ContractAlreadyRegistered();

    // ----------------------------------------------------------------
    // Functions
    // ----------------------------------------------------------------

    /// @notice Deploys a new instance of the specified utility contract
    /// @param _utilityContract The address of the utility contract to deploy
    /// @param _initData The initialization data for the new contract instance
    /// @return The address of the newly deployed contract instance
    /// @dev Emits a NewDeployment event upon successful deployment
    function deploy(address _utilityContract, bytes calldata _initData) external payable returns (address);

    /// @notice Adds new contract info
    /// @param _contractAddress The address of the potential utility contract
    /// @param _fee Fee of the contract to deploy
    /// @param  _isActive Actual status of the contract added
    /// @dev Emits a NewContractAdded event upon successful contract added
    function addNewContract(address _contractAddress, uint256 _fee, bool _isActive) external;

    /// @notice Updates fee amount of contract deploy
    /// @param _contractAddress The address of the utility contract to update fee amount
    /// @param _newFee New fee amount
    /// @dev Emits a ContractFeeUpdated event upon successful fee update
    function updateFee(address _contractAddress, uint256 _newFee) external;

    /// @notice Changes contact status
    /// @param _contractAddress The address of the utility contract to update status
    /// @param _isActive New contract status value
    /// @dev Emits a ContractStatusUpdated event upon successful status update
    function changeContractStatus(address _contractAddress, bool _isActive) external;
}
