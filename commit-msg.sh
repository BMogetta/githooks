#!/bin/sh
commit_message=$(cat "$1")

# Extract parts of the commit message
commit_header=$(echo "$commit_message" | sed -n '1p')
commit_body=$(echo "$commit_message" | sed -n '2,$p' | sed '/./,$!d' | head -n -1)
commit_footer=$(echo "$commit_message" | sed -n '$p')
types='feat|fix|chore|docs|test|style|refactor|perf|build|ci|revert'

## HEADER ##

# Check commit header
if ! echo "$commit_header" | grep -iqE "^($types)(\([^()]+\))?(!)?: .{1,}$"; then
    echo "Aborting commit. Your commit message header is invalid. Please follow the standards: type(scope)!: description"
    echo "Commits MUST be prefixed with a type, which consists of one of $types,"
    echo "followed by the OPTIONAL scope -between parenthesis- OPTIONAL ! -for breaking chages- and REQUIRED terminal colon and space."
    exit 1
fi

# Check commit header length
if ! echo "$commit_header" | grep -iqE "^.{1,88}$"; then
    echo "Aborting commit. Your description is too long."
    echo "The description is a short summary of the code change"
    echo "A longer -free-form- commit body MAY be provided after the short description."
    echo "The body MUST begin one blank line after the description and MAY consist of any number of newline separated paragraphs."
    exit 1
fi

# Check for blank line after commit header
if [ "$(echo "$commit_message" | sed -n '2p')" != "" ]; then
    echo "Aborting commit. Your commit body must begin one blank line after the description."
    echo "i.e-> feat: add new feature\n\nThis is the commit body."
    exit 1
fi

## BODY ##

## FOOTER ##

#add a check for another footer that is not a breaking change like 
#One or more footers MAY be provided one blank line after the body. Each footer MUST consist of a word token, followed by either a :<space> or <space># separator
#A footer’s token MUST use - in place of whitespace characters, e.g., Acked-by

# Check for BREAKING CHANGE in footer or header
if echo "$commit_footer$commit_header" | grep -qE "BREAKING[- ]CHANGE.*|(^|\n)(.*)!.*:.*"; then
    if ! echo "$commit_footer$commit_header" | grep -qE "BREAKING[- ]CHANGE:.*|(^|\n)(.*)!.*:.*"; then
        echo "Aborting commit. Breaking changes must be indicated in the commit footer or header as 'BREAKING CHANGE: description' or 'BREAKING-CHANGE: description'." >&2
        exit 1
    fi
fi
exit 0  # Indicate successful validation
