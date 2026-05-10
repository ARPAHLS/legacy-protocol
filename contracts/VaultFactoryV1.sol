// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ILegacyVaultV1} from "./interfaces/ILegacyVaultV1.sol";

contract VaultFactoryV1 {
    address public immutable implementation;
    mapping(address owner => address vault) public vaultOf;

    event VaultCreated(address indexed owner, address indexed vault);

    constructor(address implementation_) {
        require(implementation_ != address(0), "implementation=0");
        implementation = implementation_;
    }

    function createVault(address owner_, bytes32 salt) external returns (address vault) {
        require(owner_ != address(0), "owner=0");
        require(vaultOf[owner_] == address(0), "vault exists");

        vault = _cloneDeterministic(implementation, salt);
        ILegacyVaultV1(vault).initialize(owner_);
        vaultOf[owner_] = vault;

        emit VaultCreated(owner_, vault);
    }

    function predictVaultAddress(bytes32 salt) external view returns (address predicted) {
        return _predictDeterministicAddress(implementation, salt, address(this));
    }

    function _cloneDeterministic(address impl, bytes32 salt) internal returns (address instance) {
        bytes memory creation = abi.encodePacked(
            hex"3d602d80600a3d3981f3",
            hex"363d3d373d3d3d363d73",
            bytes20(impl),
            hex"5af43d82803e903d91602b57fd5bf3"
        );
        assembly {
            instance := create2(0, add(creation, 0x20), mload(creation), salt)
        }
        require(instance != address(0), "clone failed");
    }

    function _predictDeterministicAddress(
        address impl,
        bytes32 salt,
        address deployer
    ) internal pure returns (address predicted) {
        bytes32 codeHash = keccak256(
            abi.encodePacked(
                hex"3d602d80600a3d3981f3",
                hex"363d3d373d3d3d363d73",
                bytes20(impl),
                hex"5af43d82803e903d91602b57fd5bf3"
            )
        );

        predicted = address(
            uint160(
                uint256(
                    keccak256(
                        abi.encodePacked(bytes1(0xff), deployer, salt, codeHash)
                    )
                )
            )
        );
    }
}
