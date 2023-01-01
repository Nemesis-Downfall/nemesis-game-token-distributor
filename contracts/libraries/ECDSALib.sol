pragma solidity ^0.8.0;

library ECDSALib {
  function prefixed(bytes32 messageHash) internal pure returns (bytes32 prefixedHash) {
    prefixedHash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", messageHash));
  }

  function split(bytes memory signature) internal pure returns (bytes32 r, bytes32 s, uint8 v) {
    require(signature.length == 65, "invalid_signature_length");
    assembly {
      r := mload(add(signature, 32))
      s := mload(add(signature, 64))
      v := byte(0, mload(add(signature, 96)))
    }
  }

  function obtainSigner(bytes32 messageHash, bytes memory signature) internal pure returns (address signer) {
    (bytes32 r, bytes32 s, uint8 v) = split(signature);
    signer = ecrecover(messageHash, v, r, s);
  }
}
