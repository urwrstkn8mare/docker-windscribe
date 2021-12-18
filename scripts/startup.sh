#! /bin/bash

# Create a TUN device
mkdir -p /dev/net
mknod /dev/net/tun c 10 200
chmod 0666 /dev/net/tun

# Add an route to actual local network.
ip route add `ip route list default | sed -e "s|default|$LOCAL_NET|"`

# Start the windscribe service
service windscribe-cli start
if [ ! $? -eq 0 ]; then
    exit 5;
fi

# Log in, and configure the service

/opt/scripts/login.expect

if [ ! $? -eq 0 ]; then
    exit 5;
fi

/opt/scripts/lanbypass.expect

if [ ! $? -eq 0 ]; then
    exit 5;
fi

/opt/scripts/protocol.expect

if [ ! $? -eq 0 ]; then
    exit 5;
fi

/opt/scripts/port.expect

if [ ! $? -eq 0 ]; then
    exit 5;
fi

/opt/scripts/firewall.expect

if [ ! $? -eq 0 ]; then
    exit 5;
fi

# Set up the windscribe DNS server
echo "nameserver 10.255.255.1" >> /etc/resolv.conf

# Connect to the VPN

/opt/scripts/connect.expect

if [ ! $? -eq 0 ]; then
    exit 5;
fi

# Wait for the connection to come up

i="0"
/opt/scripts/health-check.expect
while [[ ! $? -eq 0 ]]; do
    sleep 2
    echo "Waiting for the VPN to connect... $i"
    i=$[$i+1]
    if [[ $i -eq "10" ]]; then
        exit 5
    fi
    /opt/scripts/health-check.expect
done

# Keep the container running as long as the user wants
trap : TERM INT; sleep infinity & wait
