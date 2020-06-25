#!/bin/bash

set -euo pipefail
IFS=$'\n\t'


# get a clean master branch assuming
function getcleammaster {
  echo "getcleammaster"
  git checkout master
  git pull origin master
  git clean -df
  git checkout -- .
  git fetch --all
}

function docbuild {
  echo "docbuild"
  SOURCEDIR=/home/fmoreews/git/pax2graphml_src/docs
  # build html docs from sphinx files
  CDIR=$PWD

  cd $SOURCEDIR/.. && bash build-doc.sh 
  #sphinx-build -b html . "_build"
  cd $CDIR
  cp -r  $SOURCEDIR/* ./ 
  dat=`date "+%D" `
  echo "" > build.log
  sed -ri "1s#(.*)#\#auto-build ${dat}\\n\1#" build.log 
}

function initghpages {

  echo "initghpages"
  # create or use orphaned gh-pages branch
  BRANCH=gh-pages
  if [ $(git branch --list "$BRANCH") ]
  then

        echo "$BRANCH exists"
	git stash
	git checkout $BRANCH
	git pull origin $BRANCH --allow-unrelated-histories
	git checkout stash -- . || echo "warning:$?" 
         
  else
        echo "GOING tO CREATE $BRANCH"

	git checkout --orphan "$BRANCH"
  fi
}

function listexport {
  echo "list export"
  ls | grep -v _build
}

function adddoc {
        echo "adddoc"
        ls | grep -v _build | xargs rm -r
	mv _build/* . && rm -rf _build
	git add .
         
	git commit -m "new pages version $(date)" || echo "warning:$?"
	git push origin gh-pages || echo "warning:$?"

}


echo "start"
getcleammaster
initghpages
docbuild
if [ -d "_build" ]
then
  listexport
  #adddoc
else
	echo "directory _build does not exists"
fi
echo "checkout master"
git checkout master
echo "end"







