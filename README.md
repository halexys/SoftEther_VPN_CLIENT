# SoftEther VPN Client Management Script

This script helps you manage SoftEther VPN client on a Linux system. It provides options to set up, connect, disconnect, and remove VPN accounts. It also checks for IP forwarding and ensures it is enabled before proceeding.

## Prerequisites

- **jq**: A command-line JSON processor. Install it using `sudo apt-get install jq`.
- **SoftEther VPN Client**: Ensure you have the SoftEther VPN client source code in your specified client directory.

## Configuration

The script uses a JSON configuration file (`vpn_config.json`) to store VPN account details. If the configuration file does not exist, the script will prompt you to enter the client directory (`CLIENT_DIR`) and the virtual network interface name (`NIC_NAME`).

## Usage

1. **Ensure IP Forwarding is Enabled**
   
   Before running the script, make sure IP forwarding is enabled. The script will check this automatically and alert you if it's not enabled.

   ```bash
   cat /proc/sys/net/ipv4/ip_forward
   ```
