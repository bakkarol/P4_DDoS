#!/bin/bash
./sswitch_CLI < ../projekt/clear_blackhole_list.txt --thrift-port 9092
printf "\n\n"
./sswitch_CLI < ../projekt/clear_blackhole_list.txt --thrift-port 9093
printf "\n\n"
./sswitch_CLI < ../projekt/clear_blackhole_list.txt --thrift-port 9094
printf "\n\n"
./sswitch_CLI < ../projekt/clear_blackhole_list.txt --thrift-port 9095


