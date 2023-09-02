#!/bin/bash

function process_commit() {
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

# The below line allows you to run the script standalone for manual testing if required.
# [[ "$0" == "${BASH_SOURCE[0]}" ]] && process_commit "$@"
