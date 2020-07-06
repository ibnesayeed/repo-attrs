#!/usr/bin/env bash

# A helper function to escape certain characters in the GH Action runner.
function escapify {
    local res="${1//'%'/'%25'}"
    res="${res//$'\n'/'%0A'}"
    res="${res//$'\r'/'%0D'}"
    echo "$res"
}

# If the head is tagged then use that tag otherwise @ to reference it as the default.
THIS_TAG=$(git tag --points-at HEAD)
DEAFULT_HEAD=${THIS_TAG:-@}

# If the head is tagged, then use the second last tag, otherwise the last tag.
# If only the head is tagged or no tags are present, then use the initial commit reference.
INITIAL_COMMIT=$(git rev-list --max-parents=0 @)
read last prev <<< $(git tag --sort=-committerdate | head -2 | paste - -)
PREV_TAG=$( [ -z $THIS_TAG ] && echo $last || echo $prev )
DEAFULT_TAIL=${PREV_TAG:-$INITIAL_COMMIT}

# Use user-supplied values to determine the history range, otherwise fallback to above defaults.
HEAD=${INPUT_HEAD:-$DEAFULT_HEAD}
TAIL=${INPUT_TAIL:-$DEAFULT_TAIL}
RANGE=$TAIL..$HEAD

echo "::set-output name=head::$HEAD"
echo "::set-output name=tail::$TAIL"

commits=$(git log $RANGE --no-merges --oneline | awk '{print "- "$0}')
commits=$(escapify "$commits")
echo "::set-output name=commits::$commits"

prs=$(git log --format="%s %b" --merges $RANGE | cut -d' ' -f4,7- | awk '{print "- "$0}')
prs=$(escapify "$prs")
echo "::set-output name=prs::$prs"

files=$(git diff --stat $RANGE)
files=$(escapify "$files")
echo "::set-output name=files::$files"

authors=$(git log --format="%an" --no-merges $RANGE)
coauthors=$(git log --format="%(trailers)" --no-merges $RANGE | grep -oP "Co-authored-by: \K.+(?= <)")
contributors=$(echo -e "$authors\n$coauthors" | sed '/^$/d' | grep -v "\[bot\]" | tr ' ' '#' | sort | uniq -c | sort -nr | awk '{print "- "$2" ("$1" commits)"}' | tr '#' ' ')
contributors=$(escapify "$contributors")
echo "::set-output name=contributors::$contributors"
