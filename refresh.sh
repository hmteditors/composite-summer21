#!/bin/bash
export GIT=`which git`
export PWD=`which pwd`
export LS=`which ls`
export CP=`which cp`
export CAT=`which cat`

export ROOT=`pwd`

export REPOLIST=repos.txt
#export REPOLIST=ava.txt

for REPONAME in $(cat $REPOLIST) ; do
  REPOPATH=https://github.com/hmteditors
  echo $REPOPATH
  cd ..
  if [ ! -d $REPONAME ]
  then  
    echo "Cloning " $REPOPATH
    $GIT clone $REPOPATH
  else
    echo "Pulling in " $ROOT/$REPONAME
    (cd $REPONAME && $GIT pull)
  fi
  cd $ROOT
done;
