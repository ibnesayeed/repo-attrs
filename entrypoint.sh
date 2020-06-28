#!/usr/bin/env bash

function escapify {
    local res="${1//'%'/'%25'}"
    res="${res//$'\n'/'%0A'}"
    res="${res//$'\r'/'%0D'}"
    echo $res
}

DEAFULT_HEAD="@"
INITIAL_COMMIT=$(git rev-list --max-parents=0 @)
read last prev <<< $(git tag | tail -2 | tac | paste - -)
PREV_TAG=$( [ -z $(git tag --points-at HEAD) ] && echo $last || echo $prev )
DEAFULT_TAIL=${PREV_TAG:-$INITIAL_COMMIT}

HEAD=${INPUT_HEAD:-$DEAFULT_HEAD}
TAIL=${INPUT_TAIL:-$DEAFULT_TAIL}
RANGE=$TAIL..$HEAD
echo ::set-output name=range::$RANGE

commits=$(git log $RANGE --oneline | grep -v "Merge pull request" | awk '{print "- "$0}')
echo ::set-output name=commits::$(escapify "$commits")

prs=$(git log --format="%s %b" $RANGE | grep "Merge pull request" | cut -d' ' -f4,7- | awk '{print "- "$0}')
echo ::set-output name=prs::$(escapify "$prs")

files=$(git diff --stat $RANGE)
echo ::set-output name=files::$(escapify "$files")

contributors=$(git log --format="%an: %s" $RANGE | grep -v "Merge pull request" | cut -d":" -f1 | tr ' ' '#' | sort | uniq -c | sort -nr | awk '{print "- "$2" ("$1" commits)"}' | tr '#' ' ')
echo ::set-output name=contributors::$(escapify "$contributors")
