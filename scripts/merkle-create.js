const { StandardMerkleTree } = require("@openzeppelin/merkle-tree");
const fs = require('fs');

function createWhitelist(inputs, outputFile) {
    const tree = StandardMerkleTree.of(inputs, ["address", "uint256"]);
    fs.writeFileSync(outputFile, JSON.stringify(tree.dump()));
    return tree.root;
  }
  
  module.exports = { createWhitelist };