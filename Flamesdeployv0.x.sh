#!/usr/bin/env bash

# Web3 Development Environment Setup Script (Optimized for M1/M2 Macs)
# This script installs various Web3 development tools, ensuring efficiency, error handling, and proper environment setup.

# Exit on undefined variable use and error in piped commands (for safety).
set -u
set -o pipefail

# --- 1. Rosetta 2 (for Apple Silicon compatibility) ---
if [[ "$(uname -m)" == "arm64" ]]; then
    # Check if Rosetta is already running (oahd is the Rosetta translation service)
    if /usr/bin/pgrep oahd >/dev/null 2>&1; then
        echo "Rosetta 2 is already installed."
    else
        echo "Installing Rosetta 2 (to support x86_64 binaries on Apple Silicon)..."
        /usr/sbin/softwareupdate --install-rosetta --agree-to-license || {
            echo "Warning: Rosetta 2 installation failed or was declined.&#8203;:contentReference[oaicite:3]{index=3}"
        }
    fi
fi

# --- 2. Homebrew Installation ---
if ! command -v brew >/dev/null 2>&1; then
    echo "Homebrew not found. Installing Homebrew (this may prompt for your password)..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || {
        echo "Error: Homebrew installation failed. Some tools may not install." >&2
        BREW_FAILED=true
    }
    # Add Homebrew to PATH for immediate use in this session and future sessions
    if [[ -x "/opt/homebrew/bin/brew" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"  # Update this shell's environment&#8203;:contentReference[oaicite:4]{index=4}
        # Persist Homebrew PATH for future terminals
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.zprofile"
    elif [[ -x "/usr/local/bin/brew" ]]; then
        eval "$(/usr/local/bin/brew shellenv)"
        echo 'eval "$(/usr/local/bin/brew shellenv)"' >> "$HOME/.zprofile"
    fi
else
    echo "Homebrew is already installed. Updating Homebrew..."
    brew update >/dev/null 2>&1 || echo "Warning: 'brew update' failed."
fi

# If Homebrew failed to install, mark it to skip Homebrew-dependent steps
: "${BREW_FAILED:=false}"  # default to false if not set
if [[ "$BREW_FAILED" == true ]]; then
    echo "Skipping Homebrew package installations due to previous error."
fi

# --- 3. Node.js, npm, and Yarn ---
if [[ "$BREW_FAILED" != true ]]; then
    echo "Installing Node.js and Yarn via Homebrew..."
    brew install node >/dev/null 2>&1 || echo "Warning: Node.js installation (via brew) failed."
    brew install yarn >/dev/null 2>&1 || echo "Warning: Yarn installation (via brew) failed."
else
    echo "Homebrew unavailable. Skipping Node.js and Yarn installation."
fi

# Ensure Node and npm are available before installing Node-based tools
if ! command -v npm >/dev/null 2>&1; then
    echo "npm is not available. Skipping installation of Node-based tools (Hardhat, Truffle, etc)."
else
    # --- 4. Ethereum Development Tools (Hardhat, Truffle, Ganache) ---
    # Use npm to install global Node.js packages for Ethereum development
    echo "Installing Ethereum development CLI tools (Hardhat, Truffle, Ganache)..."
    # Hardhat – Ethereum development environment
    if ! command -v hardhat >/dev/null 2>&1; then
        npm install -g hardhat >/dev/null 2>&1 && echo "Hardhat installed." || echo "Warning: Hardhat installation failed."
    else
        echo "Hardhat is already installed."
    }
    # Truffle – Development framework for Ethereum
    if ! command -v truffle >/dev/null 2>&1; then
        npm install -g truffle >/dev/null 2>&1 && echo "Truffle installed." || echo "Warning: Truffle installation failed."
    else
        echo "Truffle is already installed."
    }
    # Ganache CLI – Personal Ethereum blockchain for testing
    if ! command -v ganache >/dev/null 2>&1; then
        npm install -g ganache >/dev/null 2>&1 && echo "Ganache CLI installed." || echo "Warning: Ganache installation failed."
    else
        echo "Ganache CLI is already installed."
    }

    # --- 5. NEAR CLI ---
    # NEAR CLI allows interaction with the NEAR protocol from the command line
    echo "Installing NEAR CLI..."
    if ! command -v near >/dev/null 2>&1; then
        npm install -g near-cli >/dev/null 2>&1 && echo "NEAR CLI installed." || echo "Warning: NEAR CLI installation failed."
    else
        echo "NEAR CLI is already installed."
    fi
fi

# --- 6. Ethereum Foundry (Forge/Cast) ---
echo "Installing Foundry (Forge/Cast for Ethereum)..."
if ! command -v foundryup >/dev/null 2>&1; then
    # Foundryup is a convenient installer for the Foundry toolchain&#8203;:contentReference[oaicite:5]{index=5}
    if [[ "$BREW_FAILED" != true ]]; then
        brew install foundryup >/dev/null 2>&1 && echo "Foundryup installed via Homebrew." || {
            echo "Homebrew foundryup formula not available. Using official script..."
            curl -L https://foundry.paradigm.xyz | bash  >/dev/null 2>&1
        }
    else
        # Fallback to official installation if Homebrew isn't available
        curl -L https://foundry.paradigm.xyz | bash >/dev/null 2>&1
    fi
fi
# Source the profile to make `foundryup` available (the installer adds foundryup to PATH in a profile file)
if command -v foundryup >/dev/null 2>&1; then
    foundryup 2>/dev/null || echo "Warning: Foundry toolchain installation (foundryup) failed."
else
    # If foundryup still not in PATH, try sourcing standard shell profiles
    [[ -f "$HOME/.bash_profile" ]] && source "$HOME/.bash_profile"
    [[ -f "$HOME/.zprofile" ]] && source "$HOME/.zprofile"
    if command -v foundryup >/dev/null 2>&1; then
        foundryup 2>/dev/null
    else
        echo "Warning: Foundryup not found. Skipping Foundry installation."
    fi
fi

# --- 7. Ethereum Client (Geth) ---
if [[ "$BREW_FAILED" != true ]]; then
    echo "Installing Geth (Go Ethereum client)..."
    brew install ethereum >/dev/null 2>&1 && echo "Geth (Ethereum) installed." || echo "Warning: Geth installation failed."
else
    echo "Skipping Geth installation due to Homebrew unavailability."
fi

# --- 8. IPFS (InterPlanetary File System) CLI ---
if [[ "$BREW_FAILED" != true ]]; then
    echo "Installing IPFS..."
    brew install ipfs >/dev/null 2>&1 && echo "IPFS installed." || echo "Warning: IPFS installation failed."
else
    echo "Skipping IPFS installation due to Homebrew unavailability."
fi

# --- 9. Substrate CLI (Subkey for Polkadot/Substrate) ---
# Installing Substrate development CLI tools requires Rust (cargo)
echo "Installing Substrate CLI (subkey)..."
if ! command -v subkey >/dev/null 2>&1; then
    # Ensure Rust toolchain is installed (for cargo)
    if ! command -v rustup >/dev/null 2>&1; then
        echo "Rust not found. Installing Rust toolchain (rustup)..."
        curl -fsSL https://sh.rustup.rs | bash -s -- -y >/dev/null 2>&1 && source "$HOME/.cargo/env"
    fi
    if command -v cargo >/dev/null 2>&1; then
        cargo install --git https://github.com/paritytech/substrate --force subkey >/dev/null 2>&1 && \
            echo "Substrate subkey installed." || echo "Warning: Substrate subkey installation failed."
    else
        echo "Warning: Rust installation failed. Skipping Substrate CLI."
    fi
else
    echo "Substrate CLI (subkey) is already installed."
fi

# --- 10. Solana CLI ---
if [[ "$BREW_FAILED" != true ]]; then
    echo "Installing Solana CLI..."
    brew install solana >/dev/null 2>&1 && echo "Solana CLI installed." || echo "Warning: Solana CLI installation failed."
else
    echo "Skipping Solana CLI installation due to Homebrew unavailability."
fi

# --- 11. Docker (optional) ---
echo
read -r -p "Do you want to install Docker (Docker Desktop)? [y/N]: " RESP
if [[ "$RESP" =~ ^[Yy] ]]; then
    if [[ "$BREW_FAILED" != true ]]; then
        echo "Installing Docker (Docker Desktop)..."
        brew install --cask docker >/dev/null 2>&1 && echo "Docker Desktop installed (please open the Docker app to finish setup)." || \
            echo "Warning: Docker installation failed."
    else
        echo "Homebrew not available. Skipping Docker installation."
    fi
else
    echo "Skipping Docker installation."
fi

# --- 12. Solidity Compiler (solc) ---
if [[ "$BREW_FAILED" != true ]]; then
    echo "Installing Solidity compiler (solc)..."
    brew install solidity >/dev/null 2>&1 && echo "Solidity compiler (solc) installed." || echo "Warning: Solidity compiler installation failed."
else
    echo "Skipping Solidity compiler installation due to Homebrew unavailability."
fi

# --- 13. Installation Summary ---
echo
echo "================ Installation Summary ================"
# Homebrew
if command -v brew >/dev/null 2>&1; then
    echo "Homebrew: $(brew --version | head -n1)"
else
    echo "Homebrew: Not installed"
fi
# Node, npm, Yarn
if command -v node >/dev/null 2>&1; then echo "Node.js: $(node -v)"; else echo "Node.js: Not installed"; fi
if command -v npm >/dev/null 2>&1; then echo "npm: v$(npm -v)"; else echo "npm: Not installed"; fi
if command -v yarn >/dev/null 2>&1; then echo "Yarn: v$(yarn -v)"; else echo "Yarn: Not installed"; fi
# Ethereum tools
if command -v hardhat >/dev/null 2>&1; then 
    echo "Hardhat: $(hardhat --version 2>/dev/null | grep -m1 -o 'Hardhat version.*' || echo 'Installed')" 
else 
    echo "Hardhat: Not installed"
fi
if command -v truffle >/dev/null 2>&1; then echo "Truffle: $(truffle version | grep -m1 'Truffle')" ; else echo "Truffle: Not installed"; fi
if command -v ganache >/dev/null 2>&1; then echo "Ganache CLI: $(ganache --version 2>/dev/null || echo 'Installed')" ; else echo "Ganache CLI: Not installed"; fi
# Foundry (Forge)
if command -v forge >/dev/null 2>&1; then echo "Foundry (Forge): $(forge --version)"; else echo "Foundry (Forge): Not installed"; fi
# Geth (Ethereum)
if command -v geth >/dev/null 2>&1; then echo "Geth: $(geth version | head -n1)"; else echo "Geth (Ethereum client): Not installed"; fi
# IPFS
if command -v ipfs >/dev/null 2>&1; then echo "IPFS: $(ipfs --version)"; else echo "IPFS: Not installed"; fi
# Substrate (Subkey)
if command -v subkey >/dev/null 2>&1; then echo "Substrate (subkey): $(subkey --version)"; else echo "Substrate (subkey): Not installed"; fi
# Solana
if command -v solana >/dev/null 2>&1; then echo "Solana CLI: $(solana --version)"; else echo "Solana CLI: Not installed"; fi
# NEAR
if command -v near >/dev/null 2>&1; then echo "NEAR CLI: v$(near --version | grep -oE '[0-9.]+')" ; else echo "NEAR CLI: Not installed"; fi
# Docker
if command -v docker >/dev/null 2>&1; then echo "Docker: $(docker --version)"; else echo "Docker: Not installed"; fi
# Solidity Compiler
if command -v solc >/dev/null 2>&1; then echo "Solidity (solc): $(solc --version | head -n1)"; else echo "Solidity (solc): Not installed"; fi
echo "======================================================="
echo "✅ All done - review the summary above to see installed tool versions."
