#!/bin/bash

function dumpit {
    echo -n "dump" $1
    java -jar ../s-mali-2.0.2.jar $1 -o $1/classes.dex
    count=`cat $1/classes.dex|head -c 92|tail -c 4|hexdump -e '1/4 "%d\n"'`
    echo " ... "$count
    echo $1" ... "$count >> detail.log
    echo $count >> count.log
}

apk=$1
filter=""
depth=""

shift

while [ $# -gt 0 ]
do
    case $1 in
        "-n")
            shift
            filter=\^\.\\\{1,$1\\\}\$
            ;;
        "-d")
            shift
            let depth=$1-1
            ;;
        *)
            filter=$1
            ;;
    esac
    shift
done

if [ "$apk" == "" ]; then
    echo "need apk"
else
    rm out -Rf
    mkdir out
    echo "run baksmali"
    java -jar ./b-aksmali-2.0.2.jar $apk -o ./out
    if [ "$depth" != "" ]; then
        command="find * -type d -mindepth $depth -maxdepth $depth"
    else
        command="find * -type d"
    fi

    if [ "$filter" != "" ]; then
        command=$command"|grep -r \"$filter\""
    fi

    command=$command"| xargs -I{} echo {}"

    echo $command
    cd out
    for path in `echo $command|bash`
    do
        dumpit $path
    done
    cd ..
    echo -n "SUM = "
    touch out/count.log
    sum=`awk -F'\t' 'BEGIN{SUM=0}{SUM+=$1}END{print SUM}' out/count.log`
    echo $sum
    echo "SUM = "$sum >> out/detail.log
    rm -Rf $apk"_out"
    mv out $apk"_out"
fi
