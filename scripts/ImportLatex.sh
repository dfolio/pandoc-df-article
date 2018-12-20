#!/usr/bin/env bash

INPUTS=$1
FIGDIR=${2:-"fig"}
TO_MDDIR=${3:-"_md"}
TO_FIGDIR=${4:-"assets/media"}

################################################################################
GOOD="$(tput sgr0)$(tput bold)$(tput setaf 2)"
WARN="$(tput sgr0)$(tput bold)$(tput setaf 3)"
BAD="$(tput sgr0)$(tput bold)$(tput setaf 1)"
HILITE="$(tput sgr0)$(tput bold)$(tput setaf 6)"
BRACKET="$(tput sgr0)$(tput bold)$(tput setaf 4)"
NORMAL="$(tput sgr0)"
RC_INDENTATION=$(printf "%${i}s" '')
einfo(){
  printf " ${GOOD}*${NORMAL} ${RC_INDENTATION}$*\n"
	return 0
}
ewarn(){
  printf " ${WARN}*${NORMAL} ${RC_INDENTATION}$*\n" >&2
	return 0
}
eerror(){
  printf " ${BAD}*${NORMAL} ${RC_INDENTATION}$*\n" >&2
	exit 1
}

if [ -z $INPUTS ] ; then
  eerror "No INPUT provided in args, exit"
fi
################################################################################


for tex in $INPUTS ; do
    einfo "Start importing $tex..."

    einfo "Look for figures from $tex that should be in ${FIGDIR} ..."
    FIGLIST=`egrep -sho "^[^%]*(${FIGDIR}/.*)" ${tex} | egrep  -o '(fig\/[^{}\"\.\)]*)'`
    #  sed -e 's/.*include.*{\(fig\/[^}%\\ ]*\)[}%]*/\1 /g'
    einfo "Figure list: ${FIGLIST}"
    #dir=`basename $tex`
done
