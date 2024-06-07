var FastCoin = artifacts.require("FastCoin");
var MenuManagement = artifacts.require("MenuManagement");
var promotions = artifacts.require("promotions");
var RewardsLoyalty = artifacts.require("RewardsLoyalty");
var OrderContract = artifacts.require("OrderContract");


module.exports = function(deployer) {

  deployer.then(async () => {
      await deployer.deploy(FastCoin);
      await deployer.deploy(RewardsLoyalty, FastCoin.address);
      await deployer.deploy(promotions);
      await deployer.deploy(MenuManagement);
      await deployer.deploy(OrderContract, MenuManagement.address, promotions.address, RewardsLoyalty.address, FastCoin.address);

  });
};
