pragma solidity ^0.8.19;

import "openzeppelin-contracts/contracts/proxy/Proxy.sol";

/**
 * @title Game Proxy Contract
 * @author Carlos Ramos
 */
contract GameProxy is Proxy {
    /**
     * @dev Storage slot with the address of the current implementation.
     * This is the keccak-256 hash of "eip1967.proxy.implementation" subtracted by 1, and is
     * validated in the constructor.
     */
    bytes32 private constant IMPLEMENTATION_SLOT =
        bytes32(uint(keccak256("eip1967.proxy.implementation")) - 1);

    /**
     * @param _logic The address of the initial implementation.
     */
    constructor(address _logic) {
        bytes32 slot = IMPLEMENTATION_SLOT;
        assembly {
            sstore(slot, _logic)
        }
    }

    function _implementation() internal view override returns (address logic) {
        bytes32 slot = IMPLEMENTATION_SLOT;
        assembly {
            logic := sload(slot)
        }
    }

    function getImplementation() external view returns (address) {
        return _implementation();
    }
}
