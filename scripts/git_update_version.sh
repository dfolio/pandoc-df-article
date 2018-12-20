#!/bin/sh
source /lib64/gentoo/functions.sh

# parse arguments
# A POSIX variable
OPTIND=1         # Reset in case getopts has been used previously in the shell.
is_quiet=0
VERBOSE=1
is_test=0

inc_major=0
inc_minor=0
inc_patch=1
opts_vers=
while getopts "h?mnpqtv:" opt; do
  case "$opt" in
    h|\?)
      einfo "HELP!"
      exit $!
      ;;
    m) inc_major=1 ;;
    n) inc_minor=1 ;;
    p) inc_patch=1 ;;
    p) inc_patch=1 ;;
    q) is_quiet=1; VERBOSE=0 ;;
    t) is_test=1 ;;
    
    v|V)  opts_vers=$OPTARG  ;;
  esac
done


shift $((OPTIND-1))

[ "${1:-}" = "--" ] && shift

#einfo  "verbose=$VERBOSE, is_test='$is_test', inc_major=$inc_major vers=$opts_vers Leftovers: $@"

VERSION_FILE="$(git rev-parse --show-toplevel)"/VERSION

if [   -z "$opts_vers" ] ; then
  einfo "No version provided in args, try to guess..."
 
  #Get the highest tag number
  VERSION=`git describe --abbrev=0 --tags`
  vers=`expr "${VERSION}" : '^[v]\?\([0-9]\+\.[0-9]\+\.[0-9]\+\)' `
  [ ! -z "$vers" ] && VERSION=$vers
  [   -z "$VERSION" ] && [ -e VERSION] &&  VERSION=`cat $VERSION_FILE`
  VERSION=${VERSION:-'0.0.0'}

  #Get number parts
  vers=${VERSION}
  MAJOR="${vers%%.*}"; vers="${vers#*.}"
  MINOR="${vers%%.*}"; vers="${vers#*.}"
  PATCH="${vers%%.*}"; vers="${vers#*.}"


  # Taken from gitversion
  # major-version-bump-message: '(breaking|major)'
  # minor-version-bump-message: '(feature|minor|important)'
  # patch-version-bump-message: '(fix|patch)'
  # get last commit message and extract the count for "semver: (major|minor|patch)"
  [ "$inc_major" == "0" ] && inc_major=`git log -1 --pretty=%B | egrep -c '(breaking|major)'`
  if [ $inc_major -gt 0 ] ; then
    MAJOR=$((MAJOR+1)) 
    MINOR=0
    PATCH=0
    einfo "Major update detected: $MAJOR.$MINOR.$PATCH"
  else
    [ "$inc_minor" == "0" ] && inc_minor=`git log -1 --pretty=%B | egrep -c '(feature|minor|important)'`
    if [ $inc_minor -gt 0 ] ; then
      MINOR=$((MINOR+1)) 
      PATCH=0
    einfo "Minor update detected: $MAJOR.$MINOR.$PATCH"
    else
      [ "$inc_patch" == "0" ] && inc_patch=`git log -1 --pretty=%B | egrep -c '(fix|patch)'`
      #Increase version.patch at each commit
      if [ $inc_patch -gt 0 ] ; then
        PATCH=$((PATCH+1))
        einfo "Increase version.patch at each commit?: $MAJOR.$MINOR.$PATCH"
      fi
    fi
  fi

  #create new tag
  NEW_TAG="$MAJOR.$MINOR.$PATCH"
else 
  NEW_TAG="$opts_vers"
fi


if [ "$is_test" -gt 0 ] ; then
  einfo " TEST flag enabled, no futher action performed"
  einfo "... but we will to swicth ${VERSION} to $NEW_TAG"
  exit $!
fi

# count all commits for a branch
#GIT_COMMIT_COUNT=`git rev-list --count HEAD`
#einfo "Commit count: $GIT_COMMIT_COUNT" 
#export BUILD_NUMBER=$GIT_COMMIT_COUNT

NEEDS_TAG=$(expr "$VERSION" != "$NEW_TAG" )

if [ "$NEEDS_TAG" == "1" ] ; then
  einfo "Updating ${VERSION} to $NEW_TAG [$NEEDS_TAG]"
  #exit 1
  if [ -e "_config.yml" ] ; then
    einfo "Seems we were in a Jekyll folder :)"
    einfo "Update version: $NEW_TAG in  _config.yml"
    sed -i 's/version: .*/version: '${NEW_TAG}'/' _config.yml
  fi
  if [ -e " package.json" ] ; then
    einfo "Seems we were with a Node folder :)"
    einfo "Update version: $NEW_TAG in   package.json"
    sed  -i 's/"version": .*/"version": "$(VERSION)",/' package.json
  fi
  
  #get current hash and see if it already has a tag
  GIT_COMMIT=`git rev-parse HEAD`
  NEEDS_TAG=`git describe --contains $GIT_COMMIT 2>/dev/null`

  
  #Only tag if no tag already (would be better if the git describe command above could have a silent option)
  if [ -z "$NEEDS_TAG" ]; then
    einfo " tagging git-repository with $NEW_TAG  "
    git tag "v$NEW_TAG" -m "Releasing version: v$NEW_TAG"
    echo "$NEW_TAG" > ${VERSION_FILE}
    einfo "Commit version update for VERSION"
    git commit -m "Version update  with $NEW_TAG " ${VERSION_FILE}
    if [ -e "_config.yml" ] ; then
      einfo "Commit version update for _config.yml"
      git commit -m "Version update  with $NEW_TAG " _config.yml
    fi
    if [ -e "package.json" ] ; then
      einfo "Commit version update for package.json"
      git commit -m "Version update  with $NEW_TAG " package.json
    fi
    einfo "You may have to run ''git push --tags'' "
  else
    ewarn "Already a tag on this commit"
  fi
fi
