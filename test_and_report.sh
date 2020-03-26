#!/bin/bash 

#Simple script to upload random data of a fixed size many times and log result
# thanks to @davidpbrown on https://safenetworkforum.org for the vast bulk of this work

## Setup
#Expects safe baby-fleming to be setup and running

TEST_SIZE=0
RUNS=0

clear
echo "----------------------------------------------------------------------"
echo ""
echo "    --  Test baby-fleming network and provide reports --"
echo ""
echo "    @davidpbrown and @southside of the SAFE community March 2020"
echo "              https://safenetwork.org"
echo ""
echo "           Is your baby-fleming network running?"
echo ""
echo "   If not press Ctrl-C, start your network and run this script again."
echo ""
echo "----------------------------------------------------------------------"
echo ""
echo ""
echo ""

read -p 'How much random data do you want to put to the network (kb) ? : '  TEST_SIZE
echo ""
read -p 'How many test runs do you want? : ' RUNS
echo ""
echo ""
echo "PUTing " $TEST_SIZE"kb of random data to the network "$RUNS "times"
echo "--------------------------------------------------------------------------"


# set up logging location
mkdir ./zzz_log 2>/dev/null
mkdir ./to-upload 2>/dev/null

## Base state
#log base state
touch ./zzz_log/report
touch ./time-out.txt
echo "### START" > ./zzz_log/report
date >> ./zzz_log/report
lscpu | grep -P 'Model name|^CPU\(s\)' >> ./zzz_log/report
vmstat -s | grep -P 'total memory|total swap' >> ./zzz_log/report
cat /etc/*-release |grep -P DISTRIB_DESCRIPTION  >> ./zzz_log/report
uname -mrs  >> ./zzz_log/report
echo ""  >> ./zzz_log/report
echo "PUT " $TEST_SIZE "kb of random data to the network " $RUNS "times" >> ./zzz_log/report
echo ""  >> ./zzz_log/report

## Start
COUNTER=0
while [ $COUNTER -lt $RUNS ]; do
    let COUNTER=COUNTER+1 
    #create fresh random data for each test run
    dd if=/dev/urandom of=./to-upload/file.dat bs=1k count=$TEST_SIZE 2>/dev/null
    printf $COUNTER","$(ls -hs ./to-upload/file.dat | sed 's/^\([^ ]*\).*/\1/')"," >> ./zzz_log/report
    /usr/bin/time -o ./zzz_log/report -a -f "\t%E "  safe files put ./to-upload/file.dat | sed 's/^\([^ ]*\).*/\1/' |tee -a ./zzz_log/report   #| sed 's/^\([^ ]*\).*/\1/'
    echo >> ./zzz_log/report
done
date >> ./zzz_log/report
echo "### END" >> ./zzz_log/report
cat ./zzz_log/report > ./zzz_log/report.csv
## Summary pivot
echo -ne "\tfile:\t0\tsize: 0\t#\t\t\t\treal\t0\tuser\t0\tsys\t0\t\t" > ./zzz_log/summary_table_report; tail -n +7 ./zzz_log/report | tr '\n' '@' | sed 's/############/\n/g' | sed 's/@/\t/g' | sed 's/file: /file:\t/' >> ./zzz_log/summary_table_report

echo ""
echo "----------------------------------------------------------------"
echo ""
echo "    The logs for your test run are located in ./zzz_log/"
echo ""
echo "      Thank you for helping to test the SAFE network."
echo ""
echo "----------------------------------------------------------------"
exit