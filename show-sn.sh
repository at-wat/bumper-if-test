#!/bin/bash

dev=/dev/ttyACM0
prev=

while true;
do

  sleep 0.2

  if [ -c $dev ];
  then

    sleep 1
    stty -F $dev raw -echo
    echo > $dev
    sleep 0.1
    echo 'QT' > $dev
    sleep 0.1

    cat $dev >/tmp/firm.txt &
    pid=$!
    sleep 0.1
    echo 'VV' > $dev
    sleep 0.1
    echo 'PP' > $dev
    sleep 0.2

    kill $pid
    wait $pid 2>/dev/null

    seri=`grep /tmp/firm.txt -e '^SERI:'`

    if [ "x$seri" != "x$prev" ];
    then
      echo "$seri"
    fi
    prev="$seri"

    sleep 1

  fi

done
