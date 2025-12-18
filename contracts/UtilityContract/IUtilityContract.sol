// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import "@openzeppelin/contracts/utils/introspection/ERC165.sol";

interface IUtilityContract is IERC165 {
    // ----------------------------------------------------------------
    // Errors
    // ----------------------------------------------------------------

    /// @dev Error if contrat is Zero address
    error DeployManagerCannotBeZeroAddress();

    /// @dev Error if deploying contract does not supports its interface
    error NotDeployManager();

    /// @dev Error if deployManager validation failed
    error FailedToDeployManager();

    // ----------------------------------------------------------------
    // Functions
    // ----------------------------------------------------------------

    /// @notice Initialization of deployManager
    /// @param _initData The initialization data for the new contract instance
    /// @return The boolean value indicating whether the initialization was successful
    function initialize(bytes memory _initData) external returns (bool);

    /// @notice Shows address of the deploy manager
    /// @return address of the deploy manager
    function getDeployManager() external view returns (address);
}
