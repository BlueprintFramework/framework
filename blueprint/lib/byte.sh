#!/bin/bash

# byte.sh
# ╭         ╮   Hello traveler,
# │   o   o │   nice to meet you.
# ╰         ╯   

## default
byteDefault_1=" ╭         ╮   ";
byteDefault_2=" │   o   o │   ";
byteDefault_3=" ╰         ╯   ";

## blink
byteBlink_1=" ╭         ╮   ";
byteBlink_2=" │   -   - │   ";
byteBlink_3=" ╰         ╯   ";

byteThink() {
  clear;echo -e "
  ╭         ╮   _
  │ %^&!@*( │
  ╰         ╯
  "
  sleep 0.05
  clear;echo -e "
  ╭         ╮   _
  │ *#$&#@@ │
  ╰         ╯
  "
  sleep 0.05
  clear;echo -e "
  ╭         ╮   _
  │ #^%&&** │
  ╰         ╯
  "
  sleep 0.05
  byteThink;
};
byteThink;
byteIntroduction() {

};