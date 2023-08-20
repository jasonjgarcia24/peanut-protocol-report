// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {Test} from "forge-std/Test.sol";

import {ERC721} from "../lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import {ERC1155} from "../lib/openzeppelin-contracts/contracts/token/ERC1155/ERC1155.sol";

uint256 constant DEALT_AMOUNT = 10000e18;

contract DemoERC721 is ERC721 {
    constructor() ERC721("DemoToken", "DT") {}

    function mint(address _to, uint256 _tokenId) external {
        _mint(_to, _tokenId);
    }
}

contract DemoERC1155 is ERC1155 {
    constructor() ERC1155("https://www.example.com/") {}

    function mint(address _to, uint256 _id, uint256 _amount) external {
        _mint(_to, _id, _amount, "");
    }
}

abstract contract PeanutUtils is Test {
    function _getBatchTxParams()
        internal
        pure
        returns (uint256[] memory, uint256[] memory)
    {
        uint256[] memory _ids = new uint256[](2);
        uint256[] memory _values = new uint256[](2);

        for (uint256 i; i < 2; i++) {
            _ids[i] = i;
            _values[i] = DEALT_AMOUNT;
        }

        return (_ids, _values);
    }

    function _erc721Fixture() internal returns (DemoERC721) {
        DemoERC721 _demoERC721 = new DemoERC721();

        // Get the token IDs and values to deal.
        (uint256[] memory _dealtIds, ) = _getBatchTxParams();

        // Deal token ID 0.
        _demoERC721.mint(address(this), _dealtIds[0]);
        assertEq(_demoERC721.balanceOf(address(this)), 1);

        return _demoERC721;
    }

    function _erc1155Fixture() internal returns (DemoERC1155) {
        DemoERC1155 _demoERC1155 = new DemoERC1155();

        // Get the token IDs and values to deal.
        (
            uint256[] memory _dealtIds,
            uint256[] memory _values
        ) = _getBatchTxParams();

        // Deal token ID 0.
        _demoERC1155.mint(address(this), _dealtIds[0], _values[0]);
        assertEq(
            _demoERC1155.balanceOf(address(this), _dealtIds[0]),
            _values[0]
        );

        // Deal token ID 1.
        _demoERC1155.mint(address(this), _dealtIds[1], _values[1]);
        assertEq(
            _demoERC1155.balanceOf(address(this), _dealtIds[1]),
            _values[1]
        );

        return _demoERC1155;
    }
}
