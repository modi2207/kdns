#!/bin/bash

# Load UIO kernel module
echo "Loading UIO kernel module..."
# modprobe uio

# Insert the DPDK igb_uio kernel module
# echo "Inserting igb_uio kernel module..."
# insmod ./src/build/igb_uio.ko || { echo "Failed to insert igb_uio.ko"; exit 1; }

# # Insert the DPDK KNI kernel module
# echo "Inserting rte_kni kernel module..."
# insmod ./src/build/rte_kni.ko || { echo "Failed to insert rte_kni.ko"; exit 1; }

# Bring down the specified network interface
INTERFACE="enp2s0"
echo "Bringing down interface $INTERFACE..."
# ip link set down $INTERFACE || { echo "Failed to bring down $INTERFACE"; exit 1; }

# Bind the network interface to igb_uio
# PCI_ADDRESS="02:05.0"
# echo "Binding PCI device $PCI_ADDRESS to igb_uio..."
# ./src/build/dpdk-devbind.py -b igb_uio $PCI_ADDRESS || { echo "Failed to bind $PCI_ADDRESS to igb_uio"; exit 1; }

# Allocate hugepages
# HUGEPAGES=1024
# echo "Setting hugepages to $HUGEPAGES..."
# echo $HUGEPAGES > /sys/kernel/mm/hugepages/hugepages-2048kB/nr_hugepages || { echo "Failed to set hugepages"; exit 1; }

# Start the kDNS application
echo "Starting kDNS..."
mkdir -p /etc/kdns
cp kdns.cfg /etc/kdns/kdns.cfg
./src/build/kdns &

# Wait for 5 seconds to ensure kDNS is running
echo "Waiting for 5 seconds..."
sleep 5

# Send a POST request to kDNS to add a domain
echo "Sending POST request to kDNS..."
curl -H "Content-Type:application/json;charset=UTF-8" -X POST \
    -d '{"type":"A","zoneName":"example.com","domainName":"chen.example.com","host":"192.168.2.2"}' \
    'http://127.0.0.1:5500/kdns/domain' || { echo "Failed to send POST request"; exit 1; }

echo "Script execution completed successfully."
