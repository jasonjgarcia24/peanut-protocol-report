// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {console} from "forge-std/console.sol";
import {Test} from "forge-std/Test.sol";

import {PeanutV3} from "contracts_v3/PeanutV3.sol";
import {PeanutV3__REPAIRED} from "contracts_v3/PeanutV3__REPAIRED.sol";
import {ECDSA} from "contracts_v3/ECDSA.sol";

import {PeanutUtils, DemoERC721, DemoERC1155} from "test/PeanutUtils.sol";
import {ERC1155Holder} from "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";

interface PeanutV3Events {
    event DepositEvent(
        uint256 _index,
        uint8 _contractType,
        uint256 _amount,
        address indexed _senderAddress
    );
}

contract PeanutV3Test is PeanutUtils, PeanutV3Events, ERC1155Holder {
    address public signerAddress = vm.envAddress("DEAD_ADDRESS");
    uint256 public signerPrivKey = vm.envUint("DEAD_PRIVATE_KEY");

    PeanutV3 public peanut = new PeanutV3();
    PeanutV3__REPAIRED public peanutRepaired = new PeanutV3__REPAIRED();
    DemoERC721 public demoERC721;
    DemoERC1155 public demoERC1155;

    function setUp() public {
        demoERC721 = _erc721Fixture();
        demoERC1155 = _erc1155Fixture();
    }

    /** ------------- onERC721Received ------------- **/
    function testOnERC721Received_Fail() public {
        // Get the token IDs and values to batch transfer.
        (uint256[] memory _dealtIds, ) = _getBatchTxParams();

        // Conduct the batch transfer.
        vm.expectRevert(
            bytes("ERC721: transfer to non ERC721Receiver implementer")
        );
        demoERC721.safeTransferFrom(
            address(this),
            address(peanut),
            _dealtIds[0],
            abi.encodePacked(address(this))
        );
    }

    function testOnERC721Received_Pass() public {
        uint256 _depositCount = peanutRepaired.getDepositCount();

        // Get the token IDs and values to batch transfer.
        (uint256[] memory _dealtIds, ) = _getBatchTxParams();

        // Conduct the batch transfer.
        vm.expectEmit(true, false, false, true, address(peanutRepaired));
        emit DepositEvent(_depositCount, 2, 1, address(this));
        demoERC721.safeTransferFrom(
            address(this),
            address(peanutRepaired),
            _dealtIds[0],
            abi.encodePacked(address(this))
        );
    }

    /** ------------- onERC1155Received ------------- **/
    function testOnERC1155Received_Fail() public {
        // Get the token IDs and values to batch transfer.
        (
            uint256[] memory _dealtIds,
            uint256[] memory _values
        ) = _getBatchTxParams();

        // Conduct the batch transfer.
        vm.expectRevert(
            bytes("ERC1155: transfer to non-ERC1155Receiver implementer")
        );
        demoERC1155.safeTransferFrom(
            address(this),
            address(peanut),
            _dealtIds[0],
            _values[0],
            abi.encodePacked(address(this))
        );
    }

    function testOnERC1155Received_Pass() public {
        uint256 _depositCount = peanutRepaired.getDepositCount();

        // Get the token IDs and values to batch transfer.
        (
            uint256[] memory _dealtIds,
            uint256[] memory _values
        ) = _getBatchTxParams();

        // Conduct the batch transfer.
        vm.expectEmit(true, false, false, true, address(peanutRepaired));
        emit DepositEvent(_depositCount++, 3, _values[0], address(this));
        demoERC1155.safeTransferFrom(
            address(this),
            address(peanutRepaired),
            _dealtIds[0],
            _values[0],
            abi.encodePacked(address(this))
        );
    }

    /** ------------- onERC1155BatchReceived ------------- **/
    function testOnERC1155BatchReceived_Fail() public {
        // Get the token IDs and values to batch transfer.
        (
            uint256[] memory _dealtIds,
            uint256[] memory _values
        ) = _getBatchTxParams();

        // Conduct the batch transfer.
        vm.expectRevert(
            bytes("ERC1155: transfer to non-ERC1155Receiver implementer")
        );
        demoERC1155.safeBatchTransferFrom(
            address(this),
            address(peanut),
            _dealtIds,
            _values,
            abi.encodePacked(address(this), address(this))
        );
    }

    function testOnERC1155BatchReceived_Pass() public {
        uint256 _depositCount = peanutRepaired.getDepositCount();

        // Get the token IDs and values to batch transfer.
        (
            uint256[] memory _dealtIds,
            uint256[] memory _values
        ) = _getBatchTxParams();

        // Conduct the batch transfer.
        vm.expectEmit(true, false, false, true, address(peanutRepaired));
        emit DepositEvent(_depositCount++, 4, _values[0], address(this));
        vm.expectEmit(true, false, false, true, address(peanutRepaired));
        emit DepositEvent(_depositCount, 4, _values[1], address(this));
        demoERC1155.safeBatchTransferFrom(
            address(this),
            address(peanutRepaired),
            _dealtIds,
            _values,
            abi.encodePacked(address(this), address(this))
        );
    }
}
