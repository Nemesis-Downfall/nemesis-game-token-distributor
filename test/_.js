const { expect, use } = require("chai");
const { waffle, ethers } = require("hardhat");

use(waffle.solidity);

describe("Game Token Distributor Test", () => {
  /**
   * @type {import('ethers').Contract}
   */
  let gameDistributor;

  /**
   * @type {import('ethers').Contract}
   */
  let erc20;

  before(async () => {
    const GameDistributorContractFactory = await ethers.getContractFactory("NemesisGameRewardDistributor");
    const TestERC20ContractFactory = await ethers.getContractFactory("TestERC20");

    erc20 = await TestERC20ContractFactory.deploy(ethers.utils.parseEther("700000000"));
    erc20 = await erc20.deployed();

    const [signer] = await ethers.getSigners();
    gameDistributor = await GameDistributorContractFactory.deploy(signer.address, erc20.address);
    gameDistributor = await gameDistributor.deployed();

    await erc20.transfer(gameDistributor.address, ethers.utils.parseEther("700000000"));
  });

  it("should permit tokens to be distributed to winners", async () => {
    const [, signer2] = await ethers.getSigners();
    const nextNonce = await gameDistributor.nextNonce(signer2.address);
    const someId = "this_is_some_random_id";
    const reward = ethers.utils.parseEther("7000");
    const messageHash = ethers.utils.solidityKeccak256(
      ["bytes"],
      [ethers.utils.solidityPack(["string", "string", "uint256", "uint256"], [someId, "Nemesis_Downfall", nextNonce, reward])]
    );
    const signature = await signer2.signMessage(ethers.utils.arrayify(messageHash));
    await expect(gameDistributor.distributeReward(signer2.address, someId, nextNonce, signature, reward))
      .to.emit(gameDistributor, "RewardDistributed")
      .withArgs(signer2.address, signature, messageHash, reward);
  });

  it("should disallow the wrong signer from claiming", async () => {
    const [signer1, signer2] = await ethers.getSigners();
    const nextNonce = await gameDistributor.nextNonce(signer2.address);
    const someId = "this_is_some_random_id";
    const reward = ethers.utils.parseEther("7000");
    const messageHash = ethers.utils.solidityKeccak256(
      ["bytes"],
      [ethers.utils.solidityPack(["string", "string", "uint256", "uint256"], [someId, "Nemesis_Downfall", nextNonce, reward])]
    );
    const signature = await signer1.signMessage(ethers.utils.arrayify(messageHash));
    await expect(gameDistributor.distributeReward(signer2.address, someId, nextNonce, signature, reward)).to.be.revertedWith(
      "player_can't_claim_now"
    );
  });

  it("should allow only distributor to call contract", async () => {
    const [, signer2] = await ethers.getSigners();
    const nextNonce = await gameDistributor.nextNonce(signer2.address);
    const someId = "this_is_some_random_id";
    const reward = ethers.utils.parseEther("7000");
    const messageHash = ethers.utils.solidityKeccak256(
      ["bytes"],
      [ethers.utils.solidityPack(["string", "string", "uint256", "uint256"], [someId, "Nemesis_Downfall", nextNonce, reward])]
    );
    const signature = await signer2.signMessage(ethers.utils.arrayify(messageHash));
    await expect(gameDistributor.connect(signer2).distributeReward(signer2.address, someId, nextNonce, signature, reward)).to.be.revertedWith(
      "only_distributor"
    );
  });
});
