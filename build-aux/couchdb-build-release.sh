#!/bin/sh -ex

RELDIR=apache-couchdb
# make release dir
rm -rf $RELDIR
mkdir $RELDIR

REPOS="b64url cassim couch_log config chttpd couch couch_index \
couch_replicator couch_dbupdates couch_plugins couch_event couch_stats \
docs ddoc_cache ets_lru fauxton global_changes ioq khash mem3 rexi \
setup mango couchdb"

CONTRIB_EMAIL_SED_COMMAND="s/^[[:blank:]]{5}[[:digit:]]+[[:blank:]]/ * /"

function get_contributors {
  if [$! == "couchdb"]; then


  else
    cd src/$1
    git shortlog -se HEAD \
      | grep -v @apache.org \
      | sed $SED_ERE_FLAG -e "$CONTRIB_EMAIL_SED_COMMAND"
    cd ..
    cd ..
  fi
}

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

  # unix pipes!
  # get all single commits of persons over the repos and count them
  { for i in $REPOS; do
      get_contributors $i
    done | awk '
    BEGIN {

    }
    {
      all[$NF] = 1;
      if ($1 ~ /\*/) {
        single[length(all)] = $0;
      }
    }
    END {
      for (i in single) {
        print substr(single[i],3)
      }

    }' | sort | uniq -c;
  # get multiple commits from git shortlog that already got numbers
    for i in $REPOS; do
      get_contributors $i
    done | awk '
    BEGIN {
    }
    {
      if ($1 ~ /[0-9]/) {
        count = $1
        $1=""
        committer[$0] = committer[$0] + count;
      }
    }
    END {
      for (i in committer) {
        print committer[i], i
      }
    }'
  # pipe them into an awk which sums them all up
  } | awk '
    BEGIN {

    }
    {
      count = $1
      $1=""
      committer[$0] = committer[$0] + count;
    }
    END {
      for (i in committer) {
        print committer[i], i
      }
    }' > $RELDIR/THANKS

    echo "" >> $RELDIR/THANKS
fi


