const Token = artifacts.require("MyAdvancedToken");

module.exports = function(deployer) {
  deployer.deploy(Token, 1000, "Test Name", "TEST");
}
