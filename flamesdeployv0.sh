#!/usr/bin/env bash

###############################################################
# install_web3.sh
#
# A script to install common Web3 development tools on an M1 Mac.
# This script:
#   1. Checks if you have Rosetta 2, installs if missing (for M1).
#   2. Installs Homebrew if not installed.
#   3. Installs Node.js, Yarn, Hardhat, Truffle, Ganache, Foundry, Geth, IPFS, Substrate, Solana, etc.
#   4. Checks for and installs the Solidity compiler (solc).
#
###############################################################

# Exit immediately on error
set -e

# Helper function to print messages
info() {
  echo -e "\\033[1;34m[INFO]\\033[0m $1"
}

error() {
  echo -e "\\033[1;31m[ERROR]\\033[0m $1"
  exit 1
}

###############################################################
# 0. Rosetta 2 check and install (for Apple Silicon)
###############################################################
if [[ "$(uname -m)" == "arm64" ]]; then
  if ! /usr/bin/pgrep oahd >/dev/null 2>&1; then
    info "Rosetta 2 not detected. Installing..."
    /usr/sbin/softwareupdate --install-rosetta --agree-to-license
  else
    info "Rosetta 2 is already installed."
  fi
else
  info "Not on Apple Silicon (arm64); skipping Rosetta 2 installation."
fi

###############################################################
# 1. Homebrew installation
###############################################################
if ! command -v brew &> /dev/null; then
  info "Homebrew not found. Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  
  # Add Homebrew to PATH for this script (M1 typical path)
  echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
  eval "$(/opt/homebrew/bin/brew shellenv)"
else
  info "Homebrew is already installed. Updating Homebrew..."
  brew update
fi

###############################################################
# 2. Install Node.js (LTS) + npm + Yarn
###############################################################
info "Installing Node.js (LTS) and Yarn..."
brew install node@18  # or node@20 if preferred
brew link --overwrite node@18
brew install yarn

# Check versions
info "Node version: $(node -v)"
info "npm version: $(npm -v)"
info "Yarn version: $(yarn -v)"

###############################################################
# 3. Install Ethereum dev tools (Hardhat, Truffle, Ganache, Foundry)
###############################################################
info "Installing Hardhat, Truffle, Ganache CLI, Foundry..."

# Hardhat (npm package)
npm install -g hardhat

# Truffle (npm package)
npm install -g truffle

# Ganache (npm package)
npm install -g ganache

# Foundry (EVM toolkit in Rust)
curl -L https://foundry.paradigm.xyz | bash
# After the script finishes, foundry will be installed under ~/.foundry/bin
export PATH="$HOME/.foundry/bin:$PATH"

info "Hardhat version: $(hardhat --version || true)"
info "Truffle version: $(truffle version || true)"
info "Ganache version: $(ganache --version || true)"
info "Foundry (forge) version: $(forge --version || true)"

###############################################################
# 4. Install Geth (Go Ethereum)
###############################################################
info "Installing Geth (Go Ethereum)..."
brew tap ethereum/ethereum
brew install ethereum
info "Geth version: $(geth version || true)"

###############################################################
# 5. Install IPFS
###############################################################
info "Installing IPFS..."
brew install ipfs
info "IPFS version: $(ipfs version || true)"

###############################################################
# 6. Install Substrate (Polkadot) CLI/Tooling
###############################################################
info "Installing Substrate (Polkadot) development environment..."
curl https://getsubstrate.io -sSf | bash
if [[ -f "$HOME/.cargo/env" ]]; then
  source "$HOME/.cargo/env"
fi
info "Substrate install done."

###############################################################
# 7. Install Solana CLI
###############################################################
info "Installing Solana CLI..."
sh -c "$(curl -sSfL https://release.solana.com/stable/install)"
export PATH="$HOME/.local/share/solana/install/active_release/bin:$PATH"
info "Solana CLI version: $(solana --version || true)"

###############################################################
# 8. Install NEAR CLI
###############################################################
info "Installing NEAR CLI..."
npm install -g near-cli
info "NEAR CLI version: $(near --version || true)"

###############################################################
# 9. (Optional) Install Docker (for containerized dev)
###############################################################
info "Optionally installing Docker (cask)..."
brew install --cask docker

###############################################################
# 10. Check for Solidity compiler (solc)
###############################################################
if ! command -v solc &> /dev/null; then
  info "Solidity compiler (solc) not found. Installing via Homebrew..."
  brew tap ethereum/ethereum
  brew install solidity
  info "Installed solc version: $(solc --version || true)"
else
  info "Solidity compiler (solc) found. Version: $(solc --version || true)"
fi

###############################################################
# Final Info
###############################################################
info "All done! Installed a variety of Web3 dev tools. Versions recap:"
echo "Node: $(node -v)"
echo "NPM: $(npm -v)"
echo "Yarn: $(yarn -v)"
echo "Hardhat: $(hardhat --version 2>/dev/null || echo 'Not Found')"
echo "Truffle: $(truffle version 2>/dev/null | head -n 1 || echo 'Not Found')"
echo "Ganache: $(ganache --version 2>/dev/null || echo 'Not Found')"
echo "Forge: $(forge --version 2>/dev/null || echo 'Not Found')"
echo "Geth: $(geth version 2>/dev/null | head -n 1 || echo 'Not Found')"
echo "IPFS: $(ipfs version 2>/dev/null || echo 'Not Found')"
echo "Solana: $(solana --version 2>/dev/null || echo 'Not Found')"
echo "NEAR: $(near --version 2>/dev/null || echo 'Not Found')"
echo "solc: $(solc --version 2>/dev/null | grep -Eo 'Version:.*' || echo 'Not Found')"

info "Please open a new shell (or source your env) to ensure PATH changes take effect."
