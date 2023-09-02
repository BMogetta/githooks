#!/bin/bash

process_commit() {
    local commit=$1
    local rest_of_commit=$(echo -e "$commit")

    local body=""
    local footer=""
    local footer_started=false

    IFS=$'\n'   # set internal field separator to newline for loop iteration
    for line in $rest_of_commit; do
        if [[ "$line" =~ ^[a-zA-Z\-]+:[[:space:]]* ]]; then
            footer_started=true
        fi

        if [[ "$line" =~ ^[a-zA-Z\-]+[[:space:]]\# ]]; then
            footer_started=true
        fi

        local breaking_change_pattern="(?<!BREAKING CHANGE[^:]\n|BREAKING-CHANGE[^:]\n)^(BREAKING CHANGE: |BREAKING-CHANGE: ).*$"
        if echo "$line" | grep -Pq "$breaking_change_pattern"; then
            footer_started=true
        fi

        if $footer_started; then
            footer="${footer}\n${line}"
        else
            body="${body}\n${line}"
        fi
    done

    # Trim the variables to remove leading/trailing whitespace
    body=$(echo -e "$body" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
    footer=$(echo -e "$footer" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')

    echo -e "$body" 
    echo -e "#####UNIQUEDELIMITER#####"
    echo -e "$footer"
}

trim_newlines() {
  local trimmed="$1"
  # Remove all leading newlines or spaces
  while [[ "$trimmed" =~ ^[[:space:]] ]]; do
    trimmed="${trimmed#?}"
  done
  # Remove all trailing newlines or spaces
  while [[ "$trimmed" =~ [[:space:]]$ ]]; do
    trimmed="${trimmed%?}"
  done
  echo -n "$trimmed"
}
#The entire commit message is loaded into commit_message
commit_message=$(cat "$1")

# The first line (header) of the commit message is extracted into commit_header
commit_header=$(echo "$commit_message" | sed -n '1p')

# Everything from the second line onwards is extracted into rest_of_commit
rest_of_commit=$(echo "$commit_message" | sed -n '2,$p' | sed '/./,$!d')

# Valid commit types
types='feat|fix|chore|docs|test|style|refactor|perf|build|ci|revert'

# ALL ERROR MESSAGES
commit_header_failure="Aborting commit. Your commit message header is invalid. Please follow the standards: type(scope)!: description
Commits MUST be prefixed with a type, which consists of one of $types,
followed by the OPTIONAL scope -between parenthesis- OPTIONAL ! -for breaking chages- and REQUIRED terminal colon and space."

commit_header_too_long="Aborting commit. Your description is too long.
The description is a short summary of the code change
A longer -free-form- commit body MAY be provided after the short description.
The body MUST begin one blank line after the description and MAY consist of any number of newline separated paragraphs."

body_missing_new_line="Aborting commit. Your commit body must begin one blank line after the description.
i.e-> feat: add new feature

This is the commit body."

paragraph_error="Aborting commit. Paragraphs in the commit body should be separated with empty lines and no more than one empty line."

invalid_spacing="Aborting commit. Your commit message body should not contain consecutive non-empty lines unless they are footer elements. Make sure to separate body elements with empty lines."

invalid_footer="Aborting commit. Footer lines should be in the format 'token: value' or 'token # value'."

breaking_change_in_body="Aborting commit. Breaking changes must be indicated in the commit header with (scope)! or 
in the footer as 'BREAKING CHANGE: description' or 'BREAKING-CHANGE: description'."

## HEADER ##

header_pattern="^($types)(\([^()]+\))?(!)?: .{1,}$"

# Check if the header matches the defined pattern.
if ! echo "$commit_header" | grep -iqE "$header_pattern"; then
    echo "$commit_header_failure"
    exit 1
fi

# Check if the header's length is less than or equal to 88 characters.
if ! echo "$commit_header" | grep -iqE "^.{1,88}$"; then
    echo "$commit_header_too_long"
    exit 1
fi

## REST ##

# Check if rest_of_commit contains a letter or a number TODO:
#if echo "$rest_of_commit" | grep -q '[a-zA-Z0-9]'; then
#    echo "$body_missing_new_line"
#    exit 1
#fi

# Process rest_of_commit to extract body and footer
output=$(process_commit "$rest_of_commit")
body=$(echo "$output" | sed -n '/#####UNIQUEDELIMITER#####/q;p')
footer=$(echo "$output" | sed -e '1,/#####UNIQUEDELIMITER#####/d')
body=$(trim_newlines "$body")
footer=$(trim_newlines "$footer")

# Check if the body contains lines that start with 'BREAKING CHANGE ' or 'BREAKING-CHANGE '
if echo "$body" | grep -qE '^(BREAKING CHANGE|BREAKING-CHANGE) '; then
    echo "$breaking_change_in_body"
    exit 1
fi

# Check if the body contains lines that start with 'breaking change: ' or 'breaking-change: '
breaking_change_pattern="^(breaking change: |breaking-change: ).*"
if echo "$body" | grep -Pq "$breaking_change_pattern"; then
    echo "$breaking_change_in_body"
    exit 1
fi


exit 0  # Indicate successful validation
