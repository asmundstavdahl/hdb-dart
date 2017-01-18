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

HDB_HOST=localhost:44550


Test "can get any value from base path"
curl --silent --include $HDB_HOST | head -n1 | grep "HTTP/.\.. 200 OK"
Ok?


Test "can get set a value to 'z' key"
value="shallabais"
o=$(curl -X PUT -d "$value" --silent --include $HDB_HOST/z)
echo "$o" | head -n1 | grep "HTTP/.\.. 200 OK"
Ok? || echo "response: $o"


Test "can get the new value of the 'z' key"
retrievedValue=$(curl -X GET --silent $HDB_HOST/z)
[ "$retrievedValue" == "$value" ]
Ok? || echo "retrievedValue: $retrievedValue"


Test "can change the value of the 'z' key"
newValue="SHAZZAMM! hahahah..,ads,o2kq09 j=(JHRE)#(HR)=#HD ;ØASL;łĸ µª©œπµn}£"
curl -X PUT -d "$newValue" --silent $HDB_HOST/z >/dev/null
retrievedNewValue=$(curl -X GET --silent $HDB_HOST/z)
[ "$retrievedNewValue" == "$newValue" ]
Ok? || echo "retrievedNewValue: $retrievedNewValue"


Test "gets an incrementing numbered index back when appending a children"
retrievedIndex1=$(curl -X POST -d "v1" --silent $HDB_HOST/z)
retrievedIndex2=$(curl -X POST -d "v2" --silent $HDB_HOST/z)
[ 1$retrievedIndex1 -lt 1$retrievedIndex2 ]
Ok? || echo "retrievedIndex1: $retrievedIndex1, retrievedIndex2: $retrievedIndex2"


Test "can append automatically children"
newValue1="value1"
newValue2="value2"
retrievedIndex=$(curl -X POST -d "$newValue1" --silent $HDB_HOST/z)
curl -X POST -d "$newValue2" --silent $HDB_HOST/z >/dev/null
retrievedNewValue2=$(curl -X GET --silent $HDB_HOST/z/$(echo "1 + $retrievedIndex" | bc))
[ "$retrievedNewValue2" == "$newValue2" ]
Ok? || echo "retrievedNewValue: $retrievedNewValue"


Test "indexes of appended children starts at 1"
key=$(curl -X POST -d "$newValue1" --silent $HDB_HOST/z)
retrievedIndex=$(curl -X POST -d "v" --silent $HDB_HOST/z/$key)
[ "x$retrievedIndex" == "x1" ]
Ok? || echo "retrievedIndex: $retrievedIndex"


Test "can get a list of children of corrent length"
key=$(curl -X POST -d "$newValue1" --silent $HDB_HOST/z)
numberOfChildren=10
for n in $(seq 1 $numberOfChildren); do
    curl -X POST -d "$newValue2" --silent $HDB_HOST/z/$key >/dev/null
done
listOfChildren=$(curl -X GET --silent $HDB_HOST/z/$key/)
numberOfChildren=$(echo "$listOfChildren" | wc -l)
[ $numberOfChildren -eq 10 ]
Ok? || echo -e "numberOfChildren: $numberOfChildren"

Test "can get a list of children of corrent format"
echo "$listOfChildren" | grep -F "/" >/dev/null
[ $? -ne 0 ]
Ok? || echo -e "numberOfChildren: $numberOfChildren, listOfChildren:\n$listOfChildren"
