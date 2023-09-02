#!/bin/bash
#The entire commit message is loaded into commit_message
commit_message=$(cat "$1")

# The first line (header) of the commit message is extracted into commit_header
commit_header=$(echo "$commit_message" | sed -n '1p')
# Everything from the second line onwards is extracted into commit_body
commit_body=$(echo "$commit_message" | sed -n '2,$p' | sed '/./,$!d')

# Valid commit types
types='feat|fix|chore|docs|test|style|refactor|perf|build|ci|revert'

# Error Messages
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

## BODY ##

# Check if the commit message has a body, it checks if the second line is empty (standard git convention to separate the commit title from the body).
if [[ -n "$commit_body" && $(echo "$commit_message" | sed -n '2p' | wc -c) -ne 1 ]]; then
    echo "$body_missing_new_line" >&2
    exit 1
fi

breaking_change_pattern="(?<!BREAKING CHANGE[^:]\n|BREAKING-CHANGE[^:]\n)^(BREAKING CHANGE: |BREAKING-CHANGE: ).*$"

# Function to check if a line could be a footer
is_footer_element() {
    local line=$1
    if echo "$line" | grep -qP "$breaking_change_pattern|(^|\n)(.*)!.*:.*"; then
        return 0
    elif echo "$line" | grep -qE "^[^-]+[-| ]# .+$|^[^-]+: .+$"; then
        return 0
    else
        return 1
    fi
}


# Check for more than one line breaks in the commit body that are not separating footer elements
# or for no empty line between non-footer lines
if [[ -n "$commit_body" ]]; then
    IFS=$'\n'
    prev_line=""
    second_last_line=""
    for line in $commit_body; do
        is_footer_element "$line"
        is_footer_element_line=$?
        is_footer_element "$second_last_line"
        is_footer_element_second_last_line=$?
        
        if [[ $is_footer_element_line -eq 0 ]]; then
            :
        # Check for two non-empty lines with no empty line in between
        elif [[ -n $line && -z $prev_line && -n $second_last_line && $is_footer_element_second_last_line -ne 0 ]]; then
            echo "$invalid_spacing" >&2
            exit 1
        fi
        # Update second last and last lines
        second_last_line=$prev_line
        prev_line=$line
    done
fi


exit 0  # Indicate successful validation
