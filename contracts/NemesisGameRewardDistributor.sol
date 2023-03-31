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
  mapping(address => mapping(uint256 => bool)) nonceUsed;
  mapping(address => uint256) public nextNonce;

  event RewardDistributed(address claimant, bytes signature, bytes32 messageHash, uint256 reward);

  constructor(address distributor, address _token) {
    require(_token.isContract(), "must_be_contract_address");
    token = _token;
    _grantRole(DISTRIBUTOR_ROLE, distributor);
  }

  function canClaim(address claimant, bytes32 messageHash, bytes memory signature) private pure returns (bool) {
    bytes32 prefixedHashMessage = messageHash.prefixed();
    return claimant == prefixedHashMessage.obtainSigner(signature);
  }

  function distributeReward(address claimant, string memory randomId, uint256 nonce, bytes memory signature, uint256 reward) external {
    bytes32 messageHash = keccak256(abi.encodePacked(randomId, "Nemesis_Downfall", nonce, reward));
    require(hasRole(DISTRIBUTOR_ROLE, _msgSender()), "only_distributor");
    require(canClaim(claimant, messageHash, signature), "player_can't_claim_now");
    require(!nonceUsed[claimant][nonce], "nonce_already_used");
    require(IERC20(token).balanceOf(address(this)) >= reward, "not_enough_balance");
    TransferHelpers._safeTransferERC20(token, claimant, reward);

    nonceUsed[claimant][nonce] = true;
    nextNonce[claimant] = nextNonce[claimant] + 1;

    emit RewardDistributed(claimant, signature, messageHash, reward);
  }

  function addDistributor(address account) external onlyOwner {
    require(!hasRole(DISTRIBUTOR_ROLE, account), "already_a_distributor");
    _grantRole(DISTRIBUTOR_ROLE, account);
  }

  function removeDistributor(address account) external onlyOwner {
    require(hasRole(DISTRIBUTOR_ROLE, account), "not_a_distributor");
    _revokeRole(DISTRIBUTOR_ROLE, account);
  }

  function claimERC20(address t, address to, uint256 amount) external onlyOwner {
    require(IERC20(t).balanceOf(address(this)) >= amount, "not_enough_balance");
    TransferHelpers._safeTransferERC20(t, to, amount);
  }

  function fillContractWithTokens(uint256 amount) external onlyOwner {
    require(IERC20(token).allowance(_msgSender(), address(this)) >= amount, "not_enough_allowance_given");
    TransferHelpers._safeTransferFromERC20(token, _msgSender(), address(this), amount);
  }

  function changeTokenAddress(address _token) external onlyOwner {
    require(_token.isContract(), "must_be_contract_address");
    token = _token;
  }
}
