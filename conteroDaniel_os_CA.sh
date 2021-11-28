#!/bin/bash
input=$1

getfilecontent() {
    local input=$1
    if [ "$input"!=""]
    then
        test="/home/${input}/.backup"
        ls -a $test
        while IFS= read -r line || [ -n "$line" ]
        do
            echo "$line"
        done < "$test"
    else
        echo "test"
    fi
}

while IFS= read -r line || [ -n "$line" ]
do
  getfilecontent $line
done < "$input"