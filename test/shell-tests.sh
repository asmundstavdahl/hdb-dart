#!/bin/bash

require(){
    OK=0
    for bin in $@; do
        if which $bin >/dev/null; then
            echo -e "\e[2;32mRequirement '$bin' satisfied by $(which $bin)\e[0m"
        else
            echo -e "\e[1;31mRequirement '$bin' satisfied by $(which $bin)\e[0m"
            OK=1
        fi
    done
    [ $OK ] || exit 1
    return 0
}

Test(){
    echo -e "#### \e[1m$1\e[0m"
    export TEST_OK=0
    export TEST_NAME="$1"
}
Ok?(){
    OK=$?
    if [ $OK -eq 0 ]; then
        echo -en "\e[32m  OK "
    else
        echo -en "\e[31mFAIL "
    fi
    echo -e "\e[0;1m$TEST_NAME\e[0m"
    export TEST_OK=
    export TEST_NAME=

    return $OK
}

require curl grep

HDB_PORT=9999
HDB_HOST=localhost:$HDB_PORT
HDB_PERSISTANCE_FILE="$(dirname $0)/../data.json"


Test "values are saved to persistance file immediately after set"
value=$(head -c 100 /dev/urandom | md5sum)
# Launch an hdb server
dart "$(dirname $0)/../bin/hdb-restful-server.dart" $HDB_PORT >/dev/null &
# Wait for server to come online
sleep 0.2
# Use this index to find our data
retrievedIndex=$(curl -X PUT -d "$value" --silent $HDB_HOST/random)
# Kill the hdb server
pkill -P $$
# Check if the value was stored
grep -qF "$value" $HDB_PERSISTANCE_FILE
Ok? || echo "'$value' not in '$(cat $HDB_PERSISTANCE_FILE)'"

Test "values persist across instances"
value="value to check for"
# Launch an hdb server
dart "$(dirname $0)/../bin/hdb-restful-server.dart" $HDB_PORT >/dev/null &
# Wait for server to come online
sleep 0.2
# Use this index to find our data
retrievedIndex=$(curl -X POST -d "$value" --silent $HDB_HOST/z)
# Kill the hdb server
pkill -P $$
# Launch an hdb server
sleep 0.1
dart "$(dirname $0)/../bin/hdb-restful-server.dart" $HDB_PORT >/dev/null &
# Wait for server to come online
sleep 0.2
# This should be equal to $value
retrievedValue=$(curl -X GET --silent $HDB_HOST/z/$retrievedIndex)
# Kill the hdb server
pkill -P $$
# Check if the value persisted
[ "$retrievedValue" == "$value" ]
Ok? || echo "'$retrievedValue' != '$value'"
