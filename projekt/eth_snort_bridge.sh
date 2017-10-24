#!/bin/bash

sudo ifconfig s2-eth1 0.0.0.0
sudo ifconfig s3-eth1 0.0.0.0
sudo ifconfig s4-eth1 0.0.0.0
sudo ifconfig s5-eth1 0.0.0.0

printf "\n*** Creating Bridge Container \n"
sudo brctl addbr snort_bridge

printf "\n*** Adding interfaces to container \n"
sudo brctl addif snort_bridge s2-eth1
sudo brctl addif snort_bridge s3-eth1
sudo brctl addif snort_bridge s4-eth1
sudo brctl addif snort_bridge s5-eth1

printf "\n*** Starting container \n \n"
sudo ifconfig snort_bridge up

