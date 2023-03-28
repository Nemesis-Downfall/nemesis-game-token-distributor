pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./libraries/ECDSALib.sol";
import "./libraries/TransferHelpers.sol";

contract NemesisGameRewardDistributor is Ownable, AccessControl {
  using ECDSALib for bytes32;
  using Address for address;

  bytes32 constant DISTRIBUTOR_ROLE = keccak256(abi.encodePacked("DISTRIBUTOR_ROLE"));
  address token;

  constructor(address distributor, address _token) {
    require(_token.isContract(), "must_be_contract_address");
    token = _token;
    _grantRole(DISTRIBUTOR_ROLE, distributor);
  }

  function canClaim(address claimant, bytes32 messageHash, bytes memory signature) private pure returns (bool) {
    bytes32 prefixedHashMessage = messageHash.prefixed();
    return claimant == prefixedHashMessage.obtainSigner(signature);
  }

  function distributeReward(address claimant, bytes32 messageHash, bytes memory signature, uint256 reward) external {
    require(hasRole(DISTRIBUTOR_ROLE, _msgSender()), "only_distributor");
    require(canClaim(claimant, messageHash, signature), "player_can't_claim_now");
    require(IERC20(token).balanceOf(address(this)) >= reward, "not_enough_balance");
    TransferHelpers._safeTransferERC20(token, claimant, reward);
  }
}
