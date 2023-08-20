# Bug Report to Peanut Protocol

## Finding #1-3

Lines 218, 274, and 335 are incorrect and will result in an EVM error due to the restricted length of `_data` and `_pubKey20Bytes` being restricted to 20 bytes. Solidity's `abi.decode()` function expects a 32-byte encoded data set.<br>

Therefore, all direct external transfers of ERC721 and ERC1155 tokens will fail for failing to implement their expected receiver.<br>

```js
    address _pubKey20 = abi.decode(_data, (address));
    ...
    _pubKey20 = abi.decode(_data, (address));
   ...
    _pubKey20 = abi.decode(_pubKey20Bytes, (address));
```

Run the following commands to reproduce the bug:

```bash
$ FOUNDRY_PROFILE=peanut_v3 forge test
```

```bash
$ FOUNDRY_PROFILE=peanut_v4 forge test
```

## Finding #4

<strong>Resolved in V4</strong><br>

<i>No impact due to the above finding for ERC1155 batch transfers.</i><br>

Should the ERC1155 batch transfer issue be resolved in the previous finding, a batch transfer into this contract would forever lock up that asset within the contract. This is due to the fact that the `onERC1155BatchReceived()` function deposits the token(s) with a `_contractType` of `4`, and the `withdrawDeposit()` function would bypass all transfers and delete the deposit record.
