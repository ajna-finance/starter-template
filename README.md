# Ajna Starter Kit

Welcome to the Ajna Starter Kit repository! This repository provides a basic setup and configuration to kick-start your development projects using the Ajna protocol.

## Getting Started

To get started with the Ajna Starter Kit, follow these steps:

1. Clone the repository:
```
git clone https://github.com/ith-harvey/starter-kit.git
```
2. Change into the project directory:
```
cd ajna-starter-kit
```
3. Initialize and update the submodules:
```
git submodule init
git submodule update
```

## Run tests
```
forge test
```

## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

-   **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
-   **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
-   **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
-   **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```
