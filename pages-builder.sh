#!/bin/bash
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

buildDirectory=_build
SOURCEDIR=/home/fmoreews/git/pax2graphml_src/docs
# get a clean master branch assuming
git checkout master
git pull origin master
git clean -df
git checkout -- .
git fetch --all

echo "step 1"
# build html docs from sphinx files
#sphinx-build -b html . "$buildDirectory"

cp -r  $SOURCEDIR/* ./ 
dat=`date "+%D" `
echo "" > build.log
sed -ri "1s#(.*)#\#auto-build ${dat}\\n\1#" build.log 



# create or use orphaned gh-pages branch
branch_name=gh-pages
if [ $(git branch --list "$branch_name") ]
then

        echo "step 2"

	git stash
	git checkout $branch_name
	git pull origin $branch_name --allow-unrelated-histories
	#git stash apply
	git checkout stash -- . # force git stash to overwrite added files
else
        echo "step 3"

	git checkout --orphan "$branch_name"
fi

if [ -d "$buildDirectory" ]
then

        echo "step 4"
	ls | grep -v _build | xargs rm -r
	mv _build/* . && rm -rf _build
	git add .
        
	git commit -m "new pages version $(date)"
	git push origin gh-pages
        echo "step 5"

	# github.com recognizes gh-pages branch and create pages
	# url scheme https//:[github-handle].github.io/[repository]
else
	echo "directory $buildDirectory does not exists"
fi
echo "step 6"
git checkout master

