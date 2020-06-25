#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

function logginfo {
 echo "==INFO===========$1==============="
}

# get a clean master branch assuming
function getcleammaster {
  logginfo "getcleammaster"
  git checkout master
  git pull origin master
  git clean -df
  git checkout -- .
  git fetch --all
}

function docbuild {
  logginfo "docbuild"
  SOURCEDIR=/home/fmoreews/git/pax2graphml_src/docs
  # build html docs from sphinx files
  CDIR=$PWD

  cd $SOURCEDIR && bash build-doc.sh 
  #sphinx-build -b html . "_build"
  cd $CDIR
  cp -r  $SOURCEDIR/* ./ 
  dat=`date "+%D" `
  logginfo "" > build.log
  sed -ri "1s#(.*)#\#auto-build ${dat}\\n\1#" build.log 
}

function initghpages {

  logginfo "initghpages"
  # create or use orphaned gh-pages branch
  BRANCH=gh-pages
  if [ $(git branch --list "$BRANCH") ]
  then

        logginfo "$BRANCH exists"
	git stash
	git checkout $BRANCH
	git pull origin $BRANCH --allow-unrelated-histories
	git checkout stash -- . || logginfo "warning:$?" 
         
  else
        logginfo "GOING tO CREATE $BRANCH"

	git checkout --orphan "$BRANCH"
  fi
}

function listexport {
  logginfo "list export"
  ls | grep -v _build
}

function extractpage {
  logginfo "extractpage"
  mv _build/html tmphtml
  rm -f build.log conf.py index.rst Makefile 
  rm -rf _static _templates _build _modules _sources
  mv tmphtml/* ./
  rm -rf tmphtml
  ls -Rl ./
}
function adddoc {
        logginfo "adddoc"
        
	git add .
         
	git commit -m "new pages version $(date)" || logginfo "warning:$?"
	git push origin gh-pages || logginfo "warning:$?"

}


logginfo "start"
getcleammaster
initghpages
docbuild
if [ -d "_build" ]
then
  listexport
  extractpage
  adddoc
else
	logginfo "directory _build does not exists"
fi
logginfo "checkout master"
git checkout master
logginfo "end"







