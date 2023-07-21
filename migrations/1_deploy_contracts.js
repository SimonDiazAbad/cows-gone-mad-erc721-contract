var CowsGoneMad = artifacts.require("../contracts/CowsGoneMad_Mock.sol");

module.exports = async function(deployer) {
  // deployment steps
  await deployer.deploy(CowsGoneMad,
    'Cows Gone Mad',
    'CGM',
    'https://CGM-baseURI.com/',
    'https://CGM-NotRevealURI.com/',
    'pause'
  );
};