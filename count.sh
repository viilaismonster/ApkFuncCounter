#!/bin/bash

# $1 package path
# $2 diff directory
function dumpit {
    echo -n "dump" $1
    java -jar ../s-mali-2.0.2.jar $1 -o $1/classes.dex
    count=`cat $1/classes.dex|head -c 92|tail -c 4|hexdump -e '1/4 "%d\n"'`
    echo -n " ... "$count
    echo $1" ... "$count >> detail.log
    echo $count >> count.log

    if [ "$2" != "" ]; then
        other=`cat ../$2_out/detail.log|grep $1|awk '{print $3}'`
        if [ "$other" == "" ]; then
            cfont -yellow
            echo -n " new"
        else
            if [ $other -lt $count ]; then
                cfont -red
                let abs=$count-$other
                echo -n " +"$abs
            elif [ $other -gt $count ]; then
                cfont -green
                let abs=$other-$count
                echo -n " -"$abs
            else
                echo -n " = "
            fi
        fi
        cfont -reset
    fi
    echo "" # \n
}

. cfont.sh

apk=$1
filter=""
depth=""
diff=""

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
        "-diff")
            shift
            diff=$1
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
    echo "count apk "$apk
    echo "use filter "$filter
    echo "in depth "$depth
    echo "diff with "$diff
    echo "====START===="
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

    cd out
    echo $command
    for path in `echo $command|bash`
    do
        dumpit $path $diff
    done
    cd ..
    echo "current version "$apk
    echo -n "SUM = "
    touch out/count.log
    sum=`awk -F'\t' 'BEGIN{SUM=0}{SUM+=$1}END{print SUM}' out/count.log`
    echo $sum
    echo "SUM = "$sum >> out/detail.log
    if [ "$diff" != "" ]; then
        echo "diff version "$diff
        other=`cat $diff"_out"/detail.log|grep "SUM"|awk '{print $3}'`
        echo "SUM = "$other
    fi
    echo "" # \n
    rm -Rf $apk"_out"
    mv out $apk"_out"
fi
