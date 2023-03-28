pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./libraries/ECDSALib.sol";

contract NemesisGameRewardDistributor is Ownable {
  using ECDSALib for bytes32;
}
