// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import "@openzeppelin/contracts/utils/introspection/ERC165.sol";

interface IUtilityContract is IERC165 {

    /// @dev Error if contrat is Zero address
    error DeployManagerCannotBeZeroAddress();

    /// @dev Error if deploying contract does not supports its interface
    error NotDeployManager();

    /// @dev Error if deployManager validation failed
    error FailedToDeployManager();

    /// @notice Initialization of deployManager
    /// @param _initData The initialization data for the new contract instance
    /// @return The boolean value indicating whether the initialization was successful
    function initialize(bytes memory _initData) external returns (bool);

    /// @notice Sets the deployManager address
    /// @param _deployManager The address of the deployManager
    /// @return The address of the deployManager
    function setDeployManager(address _deployManager) internal returns (address);

    /// @notice Validates the deployManager address
    /// @param _deployManager The address of the deployManager to validate
    /// @return The boolean value indicating whether the deployManager is valid
    function validateDeployManager(address _deployManager) internal returns (bool);
}
