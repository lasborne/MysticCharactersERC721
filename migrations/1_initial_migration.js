const MysticCharacters = artifacts.require("MysticCharacters.sol");

module.exports = function (deployer) {
  deployer.deploy(MysticCharacters);
};
