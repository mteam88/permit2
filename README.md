# Permit2 Demo

This repository demonstrates how to use Uniswap's Permit2 contract for gasless token approvals. It includes a Foundry script that shows how to:

1. Deploy Permit2
2. Create a mock ERC20 token
3. Generate and sign Permit2 messages
4. Execute token transfers using Permit2

## Prerequisites

- [Foundry](https://book.getfoundry.sh/getting-started/installation)

## Installation

```bash
# Clone the repository
git clone <your-repo-url>
cd permit2

# Install dependencies
forge install
```

## Usage

1. Start a local Anvil node:
```bash
anvil
```

2. In a separate terminal, run the demo script:
```bash
forge script script/Permit2Demo.s.sol:Permit2Demo --fork-url http://localhost:8545 -vvvv
```

## What the Demo Does

1. Deploys the Permit2 contract
2. Creates a mock ERC20 token with initial supply
3. Approves Permit2 to spend tokens
4. Generates a Permit2 signature for token transfer
5. Executes a transfer using the signature
6. Shows the before and after token balances

## Project Structure

```
.
├── script/
│   └── Permit2Demo.s.sol    # Main demo script
├── foundry.toml             # Foundry configuration
├── remappings.txt          # Dependency remappings
└── README.md               # This file
```

## Dependencies

- [forge-std](https://github.com/foundry-rs/forge-std)
- [Permit2](https://github.com/Uniswap/permit2)
- [OpenZeppelin Contracts](https://github.com/OpenZeppelin/openzeppelin-contracts)

## License

MIT
