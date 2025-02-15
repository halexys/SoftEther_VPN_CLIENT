#!/bin/bash

# Check if IP forwarding is enabled
IP_FORWARD=$(cat /proc/sys/net/ipv4/ip_forward)
if [ "$IP_FORWARD" -ne 1 ]; then
    echo "IP forwarding is not enabled. Please enable IP forwarding and rerun the script."
    exit 1
fi

# Configuration file path
CONFIG_FILE="vpn_config.json"

# Check if the configuration file exists; if not, prompt for details and create it
if [ ! -f "$CONFIG_FILE" ]; then
    read -p "Enter the client directory (CLIENT_DIR): " CLIENT_DIR
    read -p "Enter the virtual network interface name (NIC_NAME): " NIC_NAME
    echo "{\"CLIENT_DIR\": \"$CLIENT_DIR\", \"NIC_NAME\": \"$NIC_NAME\", \"ACCOUNTS\": []}" > "$CONFIG_FILE"
else
    CLIENT_DIR=$(jq -r '.CLIENT_DIR' $CONFIG_FILE)
    NIC_NAME=$(jq -r '.NIC_NAME' $CONFIG_FILE)
fi

# Function to get the local gateway
get_local_gateway() {
    ip route | grep default | awk '{print $3}' | head -n 1
}

# Function to setup VPN client
setup_client() {
    ACCOUNT_NAME=$1
    PASSWORD=$2
    VPN_HOST_IPv4=$3

    # Check if vpncmd exists in CLIENT_DIR
    if [ ! -f "$CLIENT_DIR/vpncmd" ]; then
        make --directory=$CLIENT_DIR
    fi

    sleep 2
    sudo $CLIENT_DIR/vpnclient start
    sleep 2
    $CLIENT_DIR/vpncmd /TOOLS /CMD check
    sleep 2
    $CLIENT_DIR/vpncmd /CLIENT localhost /CMD NicCreate $NIC_NAME
    sleep 2
    $CLIENT_DIR/vpncmd /CLIENT localhost /CMD AccountCreate $ACCOUNT_NAME
    sleep 2
    $CLIENT_DIR/vpncmd /CLIENT localhost /CMD AccountPasswordSet $ACCOUNT_NAME /PASSWORD:$PASSWORD


    # Add the account to the JSON file
    jq --arg NAME "$ACCOUNT_NAME" --arg PASSWORD "$PASSWORD" --arg VPN_HOST_IPv4 "$VPN_HOST_IPv4" \
        '.ACCOUNTS += [{"NAME": $NAME, "PASSWORD": $PASSWORD, "VPN_HOST_IPv4": $VPN_HOST_IPv4}]' \
        $CONFIG_FILE > temp.json && mv temp.json $CONFIG_FILE
}

# Function to connect to VPN
vpn_connect() {
    ACCOUNT_NAME=$1
    VPN_HOST_IPv4=$2

    sudo $CLIENT_DIR/vpnclient stop
    sleep 2
    sudo $CLIENT_DIR/vpnclient start
    sleep 3
    $CLIENT_DIR/vpncmd /CLIENT localhost /CMD AccountConnect $ACCOUNT_NAME
    sleep 5
    $CLIENT_DIR/vpncmd /CLIENT localhost /CMD AccountList
    sleep 2

    # Get the local gateway
    LOCAL_GATEWAY=$(get_local_gateway)

	echo $LOCAL_GATEWAY
	echo $VPN_HOST_IPv4

    sudo ip route add $VPN_HOST_IPv4/32 via $LOCAL_GATEWAY
    sudo ip route del default via $LOCAL_GATEWAY
    sudo netstat -rn
    sleep 3
    sudo dhclient vpn_$NIC_NAME
    $CLIENT_DIR/vpncmd /CLIENT localhost /CMD AccountList
}

# Function to disconnect from VPN
vpn_disconnect() {
    sudo $CLIENT_DIR/vpnclient stop
    sudo ip route del $VPN_HOST_IPv4/32

    # Get the local gateway
    LOCAL_GATEWAY=$(get_local_gateway)

    sudo ip route add default via $LOCAL_GATEWAY
    sudo netstat -rn
}

# Function to remove VPN client
remove_client() {
    ACCOUNT_NAME=$1

    sudo $CLIENT_DIR/vpnclient stop
    sleep 2
    sudo $CLIENT_DIR/vpnclient start
    sleep 3
    $CLIENT_DIR/vpncmd /CLIENT localhost /CMD AccountDelete $ACCOUNT_NAME
    sleep 2
    sudo $CLIENT_DIR.vpnclient stop

    # Remove the account from the JSON file
    jq --arg NAME "$ACCOUNT_NAME" 'del(.ACCOUNTS[] | select(.NAME == $NAME))' \
        $CONFIG_FILE > temp.json && mv temp.json $CONFIG_FILE
}

# Function to display menu
display_menu() {
    echo "Please select an option:"
    echo "1) Setup VPN Client"
    echo "2) Connect to VPN"
    echo "3) Disconnect from VPN"
    echo "4) Remove VPN Client"
    echo "5) Exit"
}

# Main script
while true; do
    display_menu
    read -p "Enter your choice: " choice
    case $choice in
        1)
            read -p "Enter the account name: " ACCOUNT_NAME
            read -p "Enter the password: " PASSWORD
            read -p "Enter the VPN host IPv4: " VPN_HOST_IPv4
            setup_client $ACCOUNT_NAME $PASSWORD $VPN_HOST_IPv4
            ;;
        2)
            echo "Select the user account to connect:"
            select ACCOUNT in $(jq -r '.ACCOUNTS[].NAME' $CONFIG_FILE); do
                VPN_HOST_IPv4=$(jq -r --arg ACCOUNT "$ACCOUNT" '.ACCOUNTS[] | select(.NAME == $ACCOUNT) | .VPN_HOST_IPv4' $CONFIG_FILE)
                vpn_connect $ACCOUNT $VPN_HOST_IPv4
                break
            done
            ;;
        3) vpn_disconnect ;;
        4)
            echo "Select the user account to remove:"
            select ACCOUNT in $(jq -r '.ACCOUNTS[].NAME' $CONFIG_FILE); do
                remove_client $ACCOUNT
                break
            done
            ;;
        5) exit 0 ;;
        *) echo "Invalid option. Please try again." ;;
    esac
done
