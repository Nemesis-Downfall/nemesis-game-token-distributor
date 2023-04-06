const { ethers } = require("hardhat");

(async () => {
  try {
    const GameRewardsDistributorFactory = await ethers.getContractFactory("NemesisGameRewardDistributor");
    let gameRewardsDistributorContract = await GameRewardsDistributorFactory.deploy(
      "0xb69DB7b7B3aD64d53126DCD1f4D5fBDaea4fF578",
      "0x4FF0fbcF0EAf3aD57779562F11969A070B013294"
    );
    gameRewardsDistributorContract = await gameRewardsDistributorContract.deployed();

    console.log("New contract address: %s", gameRewardsDistributorContract.address);
  } catch (e) {
    console.log(e);
  }
})();
