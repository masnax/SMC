#!/bin/bash
inapp=$(rev <(echo $1) | cut -d"/" -f2- | rev)

output=$(sed -n -e 4p -e 8p -e 9p <($inapp/smc -f) | /usr/local/bin/tac | awk '{$1=$1};1')

mode=$(echo "$output" | head -1)
rest=$(echo "$output" | tail -2)

echo -e "$mode" | awk '{print $1, $2, "\t","\t","\t" $3}'
echo -e "$rest" | awk '{print $1, $2, $3 "\t \t" $4}'
