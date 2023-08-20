// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {console} from "forge-std/console.sol";

import {PeanutV4} from "contracts_v4/PeanutV4.sol";
import {PeanutV4__REPAIRED} from "contracts_v4/PeanutV4__REPAIRED.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

import {PeanutUtils, DemoERC721, DemoERC1155} from "test/PeanutUtils.sol";
import {ERC1155Holder} from "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";

interface PeanutV4Events {
    event DepositEvent(
        uint256 indexed _index,
        uint8 indexed _contractType,
        uint256 _amount,
        address indexed _senderAddress
    );
}

contract PeanutV4Test is PeanutUtils, PeanutV4Events, ERC1155Holder {
    address public signerAddress = vm.envAddress("DEAD_ADDRESS");
    uint256 public signerPrivKey = vm.envUint("DEAD_PRIVATE_KEY");

    PeanutV4 public peanut = new PeanutV4();
    PeanutV4__REPAIRED public peanutRepaired = new PeanutV4__REPAIRED();

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
        emit DepositEvent(_depositCount, 3, _values[0], address(this));
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
        vm.expectEmit(true, true, true, true, address(peanutRepaired));
        emit DepositEvent(_depositCount++, 3, _values[0], address(this));
        vm.expectEmit(true, true, true, true, address(peanutRepaired));
        emit DepositEvent(_depositCount, 3, _values[1], address(this));
        demoERC1155.safeBatchTransferFrom(
            address(this),
            address(peanutRepaired),
            _dealtIds,
            _values,
            abi.encodePacked(address(this), address(this))
        );
    }
}
