var CowsGoneMad = artifacts.require("../contracts/CowsGoneMad_Mock.sol");

module.exports = async function(deployer) {
  // deployment steps
  await deployer.deploy(CowsGoneMad,
    'Cows Gone Mad',
    'CGM',
    'https://CGM-baseURI.com/',
    true,
    '0x8652d3c05403e6839439915dec1292f5935f0dedfab23ebe6904147a32a96ebf'
  );
};