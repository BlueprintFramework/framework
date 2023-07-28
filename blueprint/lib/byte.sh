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

byteSpawn() {
  clear;echo -e "
  ╭         ╮   _
  │         │
  ╰         ╯
  "
  sleep 0.5
  clear;echo -e "
  ╭         ╮   _
  │   -   - │
  ╰         ╯
  "
  sleep 1
  clear;echo -e "
  ╭         ╮   _
  │   o   - │
  ╰         ╯
  "
  sleep 0.2
  clear;echo -e "
  ╭         ╮   _
  │   o   o │
  ╰         ╯
  "
  sleep 0.5
  clear;echo -e "
  ╭         ╮   Hello_
  │   o   o │
  ╰         ╯
  "
  sleep 0.1
  clear;echo -e "
  ╭         ╮   Hello traveler_
  │   o   o │
  ╰         ╯
  "
  sleep 0.05
  clear;echo -e "
  ╭         ╮   Hello traveler,_
  │   o   o │
  ╰         ╯
  "
  sleep 0.1
  clear;echo -e "
  ╭         ╮   Hello traveler,
  │   o   o │   nice_
  ╰         ╯
  "
  sleep 0.05
  clear;echo -e "
  ╭         ╮   Hello traveler,
  │   ^   o │   nice to_
  ╰         ╯
  "
  sleep 0.1
  clear;echo -e "
  ╭         ╮   Hello traveler,
  │   ^   ^ │   nice to meet_
  ╰         ╯
  "
  sleep 0.05
  clear;echo -e "
  ╭         ╮   Hello traveler,
  │   ^   ^ │   nice to meet you_
  ╰         ╯
  "
  sleep 0.1
  clear;echo -e "
  ╭         ╮   Hello traveler,
  │   ^   ^ │   nice to meet you!_
  ╰         ╯
  "
  sleep 1
  clear;echo -e "
  ╭         ╮   Hello traveler,
  │   -   - │   nice to meet you!_
  ╰         ╯
  "
  sleep 0.07
  clear;echo -e "
  ╭         ╮   Hello traveler,
  │   ^   ^ │   nice to meet you!_
  ╰         ╯
  "
  sleep 2
};
byteSpawn;
byteIntroduction() {

};