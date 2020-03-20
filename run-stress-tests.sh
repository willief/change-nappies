#! /bin/bash

#simple script to run PUT tests
WD=/tmp
OUTPUT_FILE=test.out
DATETIME="`date '+%Y%m%d%H%M%S'`"
TEST_SIZE=0
RUNS=0
COUNTER=1

clear
echo "----------------------------------------------------------------"
echo ""
read -p 'test data file size (kb) ? : '  TEST_SIZE
echo ""
read -p 'Number of test runs? : ' RUNS
echo ""
echo ""
echo "PUTing " $TEST_SIZE "kb of random data to the network " $RUNS "times"
echo "----------------------------------------------------------------"

cd $WD

if [ -f "$OUTPUT_FILE" ]; then
    rm "$OUTPUT_FILE" 
fi

touch ./test.out


until [ $COUNTER -gt $RUNS ]
do
    echo "test run " $COUNTER
    dd if=/dev/urandom of=/tmp/random.dat bs=1k count=$TEST_SIZE >/dev/null
    time safe files put /tmp/random.dat |tee -a $OUTPUT_FILE
    echo "" |tee -a $OUTPUT_FILE
    echo "------------------------------------------" |tee -a $OUTPUT_FILE
    ((COUNTER++))
done

FILENAME=$TEST_SIZE"_"$RUNS"_"$DATETIME
echo "test logs can be found at /tmp/test-out-"$FILENAME".log"

mv $OUTPUT_FILE test-out-$FILENAME.log

exit 0
