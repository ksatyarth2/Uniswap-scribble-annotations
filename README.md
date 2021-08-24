# Uniswap V2 with ConsenSys Scribble Annotations
!The original repo belongs to [uniswap.org](https://uniswap.org). I've used it to annotate only 2 files to check vulnerabilities.

[![Actions Status](https://github.com/Uniswap/uniswap-v2-core/workflows/CI/badge.svg)](https://github.com/Uniswap/uniswap-v2-core/actions)
[![Version](https://img.shields.io/npm/v/@uniswap/v2-core)](https://www.npmjs.com/package/@uniswap/v2-core)


In this exercise we're going to have a look at two contracts:
  - https://github.com/ksatyarth2/Uniswap-scribble-annotations/blob/main/contracts/UniswapV2Pair.sol
  - https://github.com/ksatyarth2/Uniswap-scribble-annotations/blob/main/contracts/UniswapV2ERC20.sol
We'll use Scribble to annotate it with properties, and use Mythril to automatically check the properties (and try to find bugs).


# Local Development

The following assumes the use of `node 10-12`.

## Installation

```
# We'll use Mythril to automatically test specifications

pip3 install mythril

npm install eth-scribble --global
npm install truffle --global
npm install ganache-cli --global
```


## Setting up the target

```
git clone https://github.com/ksatyarth2/Uniswap-scribble-annotations.git
cd Uniswap-scribble-annotations
```

## Finding the bug using Mythril

```
scribble --arm -m files ./contracts/UniswapV2Pair.sol
myth analyze ./contracts/UniswapV2Pair.sol

# Always clean up after yourself 😉
scribble --disarm -m files ./contracts/vulnerableERC20.sol

```

## Support Links
- Scribble Repository -> https://github.com/ConsenSys/Scribble
- Mythril Repository -> https://github.com/ConsenSys/Mythril
- Scribble Docs -> https://docs.scribble.codes/
- In-depth documentation on Uniswap V2 is available at [uniswap.org](https://uniswap.org/docs).
