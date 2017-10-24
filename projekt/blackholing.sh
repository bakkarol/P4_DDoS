#!/bin/bash
./sswitch_CLI < ../projekt/blackhole_port.txt --thrift-port 9092
printf "\n\n"
./sswitch_CLI < ../projekt/blackhole_port.txt --thrift-port 9093
printf "\n\n"
./sswitch_CLI < ../projekt/blackhole_port.txt --thrift-port 9094
printf "\n\n"
./sswitch_CLI < ../projekt/blackhole_port.txt --thrift-port 9095

