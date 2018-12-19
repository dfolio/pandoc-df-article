#!/bin/bash

TARGET=${1:-'html'}
shift
WATCHED=${*:-'_md/  assets/'}
INOT_OPTS="-rq"
TIMER='/usr/bin/time -f "Elapsed Time = %E"'

trap ctrl_c INT
function ctrl_c() {
	msg "ctrl_c trapped ($*) stop watching...\n"
	exit 0;
}
function msg() {
	 printf " $(tput sgr0)$(tput bold)$(tput setaf 2)[`date +"%F %T"`]$(tput sgr0) $*"
	 return 0
}

while file=$(inotifywait -rq -e delete -e create -e modify -e move --exclude '/\..+' --format %f $WATCHED); do
  msg "Detected change for: '$file'\n"
  case "$file" in
    *.md | *.scss | *.svg | *.png | *.pp )
    /usr/bin/time -f "Elapsed Time = %E" make $TARGET
    ;;
    *)
     msg "ignore $file\n"
    ;;
  esac
done


