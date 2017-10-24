#!/bin/bash
./sswitch_CLI < ../projekt/learn_commands/s1-commands.txt --thrift-port 9091
printf "\n\n"
./sswitch_CLI < ../projekt/learn_commands/s2-commands.txt --thrift-port 9092
printf "\n\n"
./sswitch_CLI < ../projekt/learn_commands/s3-commands.txt --thrift-port 9093
printf "\n\n"
./sswitch_CLI < ../projekt/learn_commands/s4-commands.txt --thrift-port 9094
printf "\n\n"
./sswitch_CLI < ../projekt/learn_commands/s5-commands.txt --thrift-port 9095


