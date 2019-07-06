#!/bin/bash

BASEFILE="icon1024.png"

HEADER="icon"
FOOTER=".png"

SIZES="
  20 40 60
  29 58 87
  80 120
  180
  76 152
  167
"

for SIZE in $SIZES
do
    RESIZEFILE=$HEADER$SIZE$FOOTER
    cp $BASEFILE $RESIZEFILE
    sips -z $SIZE $SIZE $RESIZEFILE
done
