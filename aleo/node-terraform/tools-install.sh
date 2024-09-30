#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# Install Rust
echo "Installing Rust..."
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Source Cargo's environment
echo "Configuring Cargo environment..."
source "$HOME/.cargo/env"

# Check Rust installation
echo "Verifying Rust installation..."
rustc --version

# Update package lists
echo "Updating package lists..."
sudo apt update

# Install build essentials
echo "Installing build-essential..."
sudo apt install -y build-essential

# Confirmation message
echo "Rust and build-essential have been installed successfully!"

# Install snarkOS

echo "Cloning snarkOS..."
git clone https://github.com/AleoHQ/snarkOS.git --depth 1
echo "snarkOS installation successful!"

cd snarkOS
./build_ubuntu.sh

cargo install --path .