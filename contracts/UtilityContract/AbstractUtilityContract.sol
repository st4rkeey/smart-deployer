// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import {IDeployManager} from "../DeployManager/IDeployManager.sol";
import {IUtilityContract} from "./IUtilityContract.sol";

abstract contract AbstractUtilityContract is IUtilityContract, ERC165 {
    address public deployManager;

    /// @inheritdoc IUtilityContract
    function initialize(bytes calldata _initData) external virtual override returns (bool) {
        deployManager = abi.decode(_initData, (address));
        setDeployManager(deployManager);
        return true;
    }

    /// @inheritdoc IUtilityContract
    function setDeployManager(address _deployManager) internal virtual {
        require(validateDeployManager(_deployManager), FailedToDeployManager());
        deployManager = _deployManager;
    }

    /// @inheritdoc IUtilityContract
    function validateDeployManager(address _deployManager) internal view returns (bool) {
        require(_deployManager != address(0), DeployManagerCannotBeZeroAddress());

        bytes4 interfaceId = type(IDeployManager).interfaceId;
        require(IDeployManager(_deployManager).supportsInterface(interfaceId), NotDeployManager());
        return true;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, ERC165) returns (bool) {
        return interfaceId == type(IUtilityContract).interfaceId || super.supportsInterface(interfaceId);
    }
}
