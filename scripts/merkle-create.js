const { StandardMerkleTree } = require("@openzeppelin/merkle-tree");
const fs = require('fs');

const whitelist = JSON.parse(fs.readFileSync("./whitelist.json", "utf8"));

const tree = StandardMerkleTree.of(whitelist, ["address", "uint256"]);

console.log('Merkle Root:', tree.root);

fs.writeFileSync("tree.json", JSON.stringify(tree.dump()));
