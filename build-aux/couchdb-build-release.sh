#!/bin/sh -ex

RELDIR=apache-couchdb
# make release dir
rm -rf $RELDIR
mkdir $RELDIR

CURRENT_BRANCH=`git rev-parse --abbrev-ref HEAD`

# copy sources over
git archive $CURRENT_BRANCH | tar -xC $RELDIR/
mkdir $RELDIR/src
cd src/

for repo in *; do
  cd $repo
  mkdir ../../$RELDIR/src/$repo
  # todo, make work for tags
  git archive `git rev-parse --abbrev-ref HEAD` | tar -xC ../../$RELDIR/src/$repo/
  cd ..
done

cd ..

# update version
# actual version detection TBD
perl -pi -e 's/\{vsn, git\}/\{vsn, "version"\}/' $RELDIR/src/*/src/*.app.src

cp install.mk $RELDIR/install.mk

# create THANKS file
if test -e .git; then
    OS=`uname -s`
    case "$OS" in
    Linux|CYGWIN*) # GNU sed
        SED_ERE_FLAG=-r
    ;;
    *) # BSD sed
        SED_ERE_FLAG=-E
    ;;
    esac

    sed -e "/^#.*/d" THANKS.in > $RELDIR/THANKS
    CONTRIB_EMAIL_SED_COMMAND="s/^[[:blank:]]{5}[[:digit:]]+[[:blank:]]/ * /"
    git shortlog -se 6c976bd..HEAD \
        | grep -v @apache.org \
        | sed $SED_ERE_FLAG -e "$CONTRIB_EMAIL_SED_COMMAND" >> $RELDIR/THANKS
    echo "" >> $RELDIR/THANKS # simplest portable newline
    echo "For a list of authors see the \`AUTHORS\` file." >> $RELDIR/THANKS
fi
