```
exit 0  # Indicate successful validation
im creating a bash script to follow conventional commit standars.
I'm splitting the commit message with:
#!/bin/bash
commit_message=$(cat "$1")

# Extract parts of the commit message
commit_header=$(echo "$commit_message" | sed -n '1p')
commit_body=$(echo "$commit_message" | sed -n '2,$p' | sed '/./,$!d')
body_missing_new_line="Aborting commit. Your commit body must begin one blank line after the description.
i.e-> feat: add new feature

This is the commit body."
I need to check that the body starts with an empty line. if not, it should echo body_missing_new_line
If starts with an empty line, the we should check that in case that another line break is present, its now alone, paragraph should be separated with empy lines in between them, and no more that one empty line.
But there is a catch, single line breaks are allowed if they are separating footer elements, so we must define a function that check that is an actual footer, and echo errors if the footer is not appropiately formated, here is the example of a footer check:
breaking_change_pattern="^(BREAKING CHANGE|BREAKING-CHANGE): .*$"
# Check for BREAKING CHANGE in footer or header
if echo "$commit_body$commit_header" | grep -qiE "BREAKING[- ]CHANGE.*|(^|\n)(.*)!.*:.*"; then
    if ! echo "$commit_body$commit_header" | grep -qE "$breaking_change_pattern|(^|\n)(.*)!.*:.*"; then
        echo "Aborting commit. Breaking changes must be indicated in the commit footer or header as 'BREAKING CHANGE: description' or 'BREAKING-CHANGE: description'." >&2
        exit 1
    fi
fi
so if it has a linebreak with no empty line and is not a footer element, it should echo 'TODO'
```