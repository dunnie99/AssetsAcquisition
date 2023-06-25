// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../lib/openzeppelin-contracts/contracts/token/ERC1155/ERC1155.sol";
import "../lib/openzeppelin-contracts/contracts/utils/Strings.sol";
import "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
contract Assets is ERC1155, Ownable {

    constructor() ERC1155("https://ipfs.io/ipfs/bafybeigxgjr3bre3vvro7duzpz2j5tfrhwnarlqw6yq5cce6fo5qh3u7yq/{id}.json") {}

    function setURI(string memory newuri) public {
        _setURI(newuri);
    }

    function mintProperty(address account, uint256 id, uint256 amount)
        public
        onlyOwner
    {
        _mint(account, id, amount, "");
    }

    function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        public
        onlyOwner
    {
        _mintBatch(to, ids, amounts, data);
    }

}