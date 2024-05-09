const fs = require('fs');
const { StandardMerkleTree } = require("@openzeppelin/merkle-tree");

// const tree = StandardMerkleTree.load(JSON.parse(fs.readFileSync("tree.json", "utf8")));

function findMerkleProof(treeInputFile, targetAddress) {
const tree = StandardMerkleTree.load(JSON.parse(fs.readFileSync(treeInputFile, "utf8")));
  for (const [i, v] of tree.entries()) {
    if (v[0] === targetAddress) {
      return tree.getProof(i);
    }
  }
  return null;
}

module.exports = { findMerkleProof };