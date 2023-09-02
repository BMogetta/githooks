#!/usr/bin/env bats

source './splitter.sh'

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


# 01
@test "01 - Only body" {
  run process_commit "This is the body."
  [ "$status" -eq 0 ]

  # Split the output based on the delimiter
  body=$(echo "$output" | sed -n '/#####UNIQUEDELIMITER#####/q;p')
  footer=$(echo "$output" | sed -e '1,/#####UNIQUEDELIMITER#####/d')

  # Trim newlines from body and footer
  body=$(trim_newlines "$body")
  footer=$(trim_newlines "$footer")

  [ "$body" = "This is the body." ]
  [ -z "$footer" ]
}

# 02
@test "02 - Footer only" {
  run process_commit "issue: #123"
  [ "$status" -eq 0 ]

  # Split the output based on the delimiter
  body=$(echo "$output" | sed -n '/#####UNIQUEDELIMITER#####/q;p')
  footer=$(echo "$output" | sed -e '1,/#####UNIQUEDELIMITER#####/d')

  # Trim newlines from body and footer
  body=$(trim_newlines "$body")
  footer=$(trim_newlines "$footer")

  # Check if body is empty and footer is as expected.
  [ -z "$body" ]
  [ "$footer" = "issue: #123" ]
}

@test "03 - Body with footer" {
  run process_commit "This is the body.\nissue: #123"
  [ "$status" -eq 0 ]

  # Split the output based on the delimiter
  body=$(echo "$output" | sed -n '/#####UNIQUEDELIMITER#####/q;p')
  footer=$(echo "$output" | sed -e '1,/#####UNIQUEDELIMITER#####/d')

  # Trim newlines from body and footer
  body=$(trim_newlines "$body")
  footer=$(trim_newlines "$footer")

  [ "$body" = "This is the body." ]
  [ "$footer" = "issue: #123" ]
}


# 04
@test "04 - Issue with related issue" {
  run process_commit "issue: #123\nrelated: #456"
  [ "$status" -eq 0 ]

  # Split the output based on the delimiter
  body=$(echo "$output" | sed -n '/#####UNIQUEDELIMITER#####/q;p')
  footer=$(echo "$output" | sed -e '1,/#####UNIQUEDELIMITER#####/d')

  # Trim newlines from body and footer
  body=$(trim_newlines "$body")
  footer=$(trim_newlines "$footer")

  [ -z "$body" ]
    [ "$footer" = "issue: #123
related: #456" ]
}


# 05
@test "05 - Lone colon" {
  run process_commit "This is the body.\n:\nrelated: #456"
  [ "$status" -eq 0 ]

  # Split the output based on the delimiter
  body=$(echo "$output" | sed -n '/#####UNIQUEDELIMITER#####/q;p')
  footer=$(echo "$output" | sed -e '1,/#####UNIQUEDELIMITER#####/d')

  # Trim newlines from body and footer
  body=$(trim_newlines "$body")
  footer=$(trim_newlines "$footer")

  [ "$body" = "This is the body.
:" ]

  [ "$footer" = "related: #456" ]
}

# 06
@test "06 - Two paragraph with no footer" {
  run process_commit "This is the body.\nThis is also body"
  [ "$status" -eq 0 ]

  # Split the output based on the delimiter
  body=$(echo "$output" | sed -n '/#####UNIQUEDELIMITER#####/q;p')
  footer=$(echo "$output" | sed -e '1,/#####UNIQUEDELIMITER#####/d')

  # Trim newlines from body and footer
  body=$(trim_newlines "$body")
  footer=$(trim_newlines "$footer")

  [ "$body" = "This is the body.
This is also body" ]

  [ -z "$footer" ]
}

# 07
@test "07 - Multiple paragraph with no footer" {
  run process_commit "This is the body.\nThis is also body\nand a last paragraph"
  [ "$status" -eq 0 ]

  # Split the output based on the delimiter
  body=$(echo "$output" | sed -n '/#####UNIQUEDELIMITER#####/q;p')
  footer=$(echo "$output" | sed -e '1,/#####UNIQUEDELIMITER#####/d')

  # Trim newlines from body and footer
  body=$(trim_newlines "$body")
  footer=$(trim_newlines "$footer")

  [ "$body" = "This is the body.
This is also body
and a last paragraph" ]

  [ -z "$footer" ]
}

# 08
@test "08 - Multiple linebreak in a paragraph with no footer" {
  run process_commit "This is the body.\n\n\nThis is also body\nand a last paragraph"
  [ "$status" -eq 0 ]

  # Split the output based on the delimiter
  body=$(echo "$output" | sed -n '/#####UNIQUEDELIMITER#####/q;p')
  footer=$(echo "$output" | sed -e '1,/#####UNIQUEDELIMITER#####/d')

  # Trim newlines from body and footer
  body=$(trim_newlines "$body")
  footer=$(trim_newlines "$footer")

  [ "$body" = "This is the body.
This is also body
and a last paragraph" ]

  [ -z "$footer" ]
}

# 09
@test "09 - Body with footer that starts with 'word:<space>'" {
  run process_commit "This is the body.\nissue: #123"
  [ "$status" -eq 0 ]

  # Split the output based on the delimiter
  body=$(echo "$output" | sed -n '/#####UNIQUEDELIMITER#####/q;p')
  footer=$(echo "$output" | sed -e '1,/#####UNIQUEDELIMITER#####/d')

  # Trim newlines from body and footer
  body=$(trim_newlines "$body")
  footer=$(trim_newlines "$footer")

  [ "$body" = "This is the body." ]
  [ "$footer" = "issue: #123" ]
}

# 10
@test "10 - Body with footer that starts with 'word<space>#'" {
  run process_commit "This is the body.\nissue #123"
  [ "$status" -eq 0 ]

  # Split the output based on the delimiter
  body=$(echo "$output" | sed -n '/#####UNIQUEDELIMITER#####/q;p')
  footer=$(echo "$output" | sed -e '1,/#####UNIQUEDELIMITER#####/d')

  # Trim newlines from body and footer
  body=$(trim_newlines "$body")
  footer=$(trim_newlines "$footer")

  [ "$body" = "This is the body." ]
  [ "$footer" = "issue #123" ]
}

# 11
@test "11 - Body with footer that starts with 'multi-word:<space>'" {
  run process_commit "This is the body.\nissue-number: #123"
  [ "$status" -eq 0 ]

  # Split the output based on the delimiter
  body=$(echo "$output" | sed -n '/#####UNIQUEDELIMITER#####/q;p')
  footer=$(echo "$output" | sed -e '1,/#####UNIQUEDELIMITER#####/d')

  # Trim newlines from body and footer
  body=$(trim_newlines "$body")
  footer=$(trim_newlines "$footer")

  [ "$body" = "This is the body." ]
  [ "$footer" = "issue-number: #123" ]
}

# 12
@test "12 - Body with multi word footer that starts with 'multi-word<space>#'" {
  run process_commit "This is the body.\nissue-number #123"
  [ "$status" -eq 0 ]

  # Split the output based on the delimiter
  body=$(echo "$output" | sed -n '/#####UNIQUEDELIMITER#####/q;p')
  footer=$(echo "$output" | sed -e '1,/#####UNIQUEDELIMITER#####/d')

  # Trim newlines from body and footer
  body=$(trim_newlines "$body")
  footer=$(trim_newlines "$footer")

  [ "$body" = "This is the body." ]
  [ "$footer" = "issue-number #123" ]
}

# 13
@test "13 - Body with footer that starts with 'BREAKING CHANGE:'" {
  run process_commit "This is the body.\nBREAKING CHANGE: #123"
  [ "$status" -eq 0 ]

  echo $output
  # Split the output based on the delimiter
  body=$(echo "$output" | sed -n '/#####UNIQUEDELIMITER#####/q;p')
  footer=$(echo "$output" | sed -e '1,/#####UNIQUEDELIMITER#####/d')

  # Trim newlines from body and footer
  body=$(trim_newlines "$body")
  footer=$(trim_newlines "$footer")
  echo $footer
  [ "$body" = "This is the body." ]
  [ "$footer" = "BREAKING CHANGE: #123" ]
}

# 14
@test "14 - Body with footer that starts with 'BREAKING-CHANGE:'" {
  run process_commit "This is the body.\nBREAKING-CHANGE: #123"
  [ "$status" -eq 0 ]

  echo $output
  # Split the output based on the delimiter
  body=$(echo "$output" | sed -n '/#####UNIQUEDELIMITER#####/q;p')
  footer=$(echo "$output" | sed -e '1,/#####UNIQUEDELIMITER#####/d')

  # Trim newlines from body and footer
  body=$(trim_newlines "$body")
  footer=$(trim_newlines "$footer")

  [ "$body" = "This is the body." ]
  [ "$footer" = "BREAKING-CHANGE: #123" ]
}

# add a test somewhere that if breaking change are not in uppercase it should break