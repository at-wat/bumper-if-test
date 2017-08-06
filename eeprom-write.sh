#!/bin/bash

prefix=2017

num=1
num_max=30
dev=/dev/ttyACM0

if [ $# -gt 0 ];
then
  num=$1
fi

if [ $# -gt 1 ];
then
  num_max=$2
fi

sudo true

while true;
do

  if [ $num -lt 10 ];
  then
    padding='00'
  elif [ $num -lt 100 ];
  then
    padding='0'
  fi

  echo '-------------------'
  echo "- Configuring $prefix$padding$num"

  echo > /tmp/firm.txt

  stty -F $dev raw -echo
  echo > $dev
  sleep 0.1
  echo 'QT' > $dev
  sleep 0.1

  echo "\$SSN\"$prefix$padding$num\"" > $dev
  sleep 0.1
  echo "\$STH010" > $dev
  sleep 0.1
  echo "\$SRE-01" > $dev
  sleep 0.1
  echo "\$SDI0010" > $dev
  sleep 0.1
  echo "\$SFR-01" > $dev

  echo '- Resetting'
  echo 'RB' > $dev
  sleep 2


  stty -F $dev raw -echo
  echo > $dev
  sleep 0.1

  cat $dev >/tmp/firm.txt &
  pid=$!
  sleep 0.1
  echo 'VV' > $dev
  sleep 0.1
  echo 'PP' > $dev
  sleep 0.4

  kill $pid
  wait $pid 2>/dev/null

  cat /tmp/firm.txt

  version=`grep /tmp/firm.txt -e '^FIRM:'`
  if grep /tmp/firm.txt -e '^FIRM:9e731b9;g$' > /dev/null 2> /dev/null;
  then
    echo "Firmware version check: passed ($version)"
  else
    echo "Firmware version check: failed ($version)"
  fi

  echo > $dev
  sudo sync


  bash -c "set -eu; grep $dev -e \"^ME\" -A 3 --line-buffered | grep -e \".\{16,\}\" --line-buffered | sed -e 's/\\(.\\{3,3\\}\\)\\(.\\{3,3\\}\\)\\(.\\{3,3\\}\\)\\(.\\{3,3\\}\\)\\(.\\{3,3\\}\\)\\(.\\{3,3\\}\\)\\(.\\{3,3\\}\\)\\(.\\{3,3\\}\\).*$/\\1(\\2) \\3(\\4) \\5(\\6) \\7(\\8)/' --unbuffered | tr \\\\n \\\\r" &
  pid=$!
  
  echo
  echo 'Hit enter to stop testing.'
  echo 'ME0000000300000' > $dev
  read
  echo 'QT' > $dev

  kill $pid
  wait $pid 2>/dev/null
  
  echo
  echo 'Hit enter to configure next.'
  read

  num=`expr $num + 1`
  
  if [ $num -gt $num_max ];
  then
    break
  fi

done
