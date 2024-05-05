const fs = require('fs');
const { StandardMerkleTree } = require("@openzeppelin/merkle-tree");

const tree = StandardMerkleTree.load(JSON.parse(fs.readFileSync("tree.json", "utf8")));
const targetAddress = '0x1111111111111111111111111111111111111111';

for (const [i, v] of tree.entries()) {
  if (v[0] === targetAddress) {
    const proof = tree.getProof(i);
    console.log('Value:', v);
    console.log('Proof:', `[${proof.map(p => `"${p}"`)}]`);
  }
}
