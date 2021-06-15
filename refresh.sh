#!/bin/bash
#
# 1. Update content in all repos.
# 2. Build web site for updated content.
# 3. Push updated website to gh

export GIT=`which git`
export PWD=`which pwd`
export LS=`which ls`
export CP=`which cp`
export CAT=`which cat`
export JULIA=`which julia`


# 1. Update content in all repos.
export ROOT=`pwd`
export REPOLIST=repos.txt

for REPONAME in $(cat $REPOLIST) ; do
  REPOPATH=https://github.com/hmteditors/$REPONAME
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
echo "Pulled all repos"

# 2. Build web site for updated content.
echo "Updating web site..."
$JULIA $ROOT/coverage.jl

# 3. Push updated website to gh
echo "Pushing updated site to github..."
$GIT add $ROOT/docs/*/*md
$GIT add $ROOT/data/*cex
$GIT commit -m "Automatically updated site"
$GIT push
echo "Done."