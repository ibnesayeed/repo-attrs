#!/usr/bin/env bash

DEAFULT_HEAD="@"
INITIAL_COMMIT=$(git rev-list --max-parents=0 @)
read last prev <<< $(git tag | tail -2 | tac | paste - -)
PREV_TAG=$( [ -z $(git tag --points-at HEAD) ] && echo $last || echo $prev )
DEAFULT_TAIL=${PREV_TAG:-$INITIAL_COMMIT}

HEAD=${INPUT_HEAD:-$DEAFULT_HEAD}
TAIL=${INPUT_TAIL:-$DEAFULT_TAIL}
RANGE=$TAIL..$HEAD
echo ::set-output name=range::$RANGE

commits=$(git log $RANGE --oneline | grep -v "Merge pull request" | awk '{print "* "$0}')
commits="${commits//'%'/'%25'}"
commits="${commits//$'\n'/'%0A'}"
commits="${commits//$'\r'/'%0D'}"
echo ::set-output name=commits::$commits

prs=$(git log --format="%s %b" $RANGE | grep "Merge pull request" | cut -d' ' -f4,7- | awk '{print "* "$0}')
prs="${prs//'%'/'%25'}"
prs="${prs//$'\n'/'%0A'}"
prs="${prs//$'\r'/'%0D'}"
echo ::set-output name=prs::$prs

files=$(git diff --stat $RANGE)
files="${files//'%'/'%25'}"
files="${files//$'\n'/'%0A'}"
files="${files//$'\r'/'%0D'}"
echo ::set-output name=files::$files

contributors=$(git log --format="%an: %s" $RANGE | grep -v "Merge pull request" | cut -d":" -f1 | tr ' ' '#' | sort | uniq -c | sort -nr | awk '{print "* "$2" ("$1" commits)"}' | tr '#' ' ')
contributors="${contributors//'%'/'%25'}"
contributors="${contributors//$'\n'/'%0A'}"
contributors="${contributors//$'\r'/'%0D'}"
echo ::set-output name=contributors::$contributors
