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
	If the output is `0`, enable IP forwarding:
	```bash
	sudo sysctl -w net.ipv4.ip_forward=1
	```	
	<br/>
2. **Run the Script**
	Make the script executable and run it:
	
	```bash
	chmod +x vpn_client_management.sh
	./vpn_client_management.sh
	```
	
3. **Menu Options**
		The script provides a menu for managing VPN accounts:

	-   **Setup VPN Client**
	    
	    -   Prompts for account name, password, and VPN host IPv4.
	        
	    -   Sets up the VPN client, creates the account, and saves the account details to the configuration file.
	        
	-   **Connect to VPN**
	    
	    -   Prompts to select an existing account from the configuration file.
	        
	    -   Connects to the VPN using the selected account.
	        
	-   **Disconnect from VPN**
	    
	    -   Stops the VPN client and restores the default IP route.
	        
	-   **Remove VPN Client**
	    
	    -   Prompts to select an existing account from the configuration file.
	        
	    -   Removes the VPN account and deletes it from the configuration file.
	        
	-   **Exit**
	
	    -   Exits the script.

## Example Usage
1. **Setup VPN Client**

	Select option `1` and enter the required details when prompted:
	
	```bash
	Enter the account name: my_account
	Enter the password: my_password
	Enter the VPN host IPv4: 172.28.117.252
	```
    
2.  **Connect to VPN**
    
    Select option `2` and choose the account you want to connect to:
      
    ```bash
    Select the user account to connect:
    1) my_account
    ```
    
3.  **Disconnect from VPN**
    
    Select option `3` to disconnect from the VPN.
    
4.  **Remove VPN Client**
    
    Select option `4` and choose the account you want to remove:
      
    ```bash
    Select the user account to remove:
    1) my_account
    ```
    
5.  **Exit**
    
    Select option `5` to exit the script.
    

## Notes

-   Ensure that the SoftEther VPN client source code is available in the specified `CLIENT_DIR`.
    
-   The script relies on `jq` to process the JSON configuration file.
