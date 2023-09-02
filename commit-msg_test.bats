#!/usr/bin/env bats

# The script being tested
script=./commit-msg.sh
types='feat|fix|chore|docs|test|style|refactor|perf|build|ci|revert'
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

breaking_change_in_body="Aborting commit. Breaking changes must be indicated in the commit header with (scope)! or 
in the footer as 'BREAKING CHANGE: description' or 'BREAKING-CHANGE: description'."

################ SUCCESS ################

# 01
@test "01 - valid commit message" {
  echo "feat: add new feature" > temp.txt
  run $script temp.txt
  [ "$status" -eq 0 ]
  [ "$output" = "" ] # Validate that the stdout is empty
}

# 02
@test "02 - valid commit message with scope" {
  echo "feat(parser): add new parser" > temp.txt
  run $script temp.txt
  [ "$status" -eq 0 ]
  [ "$output" = "" ] # Validate that the stdout is empty
}

# 03
@test "03 - valid commit message with scope and optional" {
  echo "feat(parser)!: add new parser" > temp.txt
  run $script temp.txt
  [ "$status" -eq 0 ]
  [ "$output" = "" ] # Validate that the stdout is empty
}
# 04
@test "04 - valid commit message with optional" {
  echo "feat!: add new feature" > temp.txt
  run $script temp.txt
  [ "$status" -eq 0 ]
  [ "$output" = "" ] # Validate that the stdout is empty
}

# 05
@test "05 - valid types with different cases" {
  echo "Feat: add new feature" > temp.txt
  run $script temp.txt
  [ "$status" -eq 0 ]
  echo "FIX: resolve issue" > temp.txt
  run $script temp.txt
  [ "$status" -eq 0 ]
  echo "DoCS: update documentation" > temp.txt
  run $script temp.txt
  [ "$status" -eq 0 ]
  echo "STYLE: adjust code style" > temp.txt
  run $script temp.txt
  [ "$status" -eq 0 ]
  echo "Test: add new test" > temp.txt
  run $script temp.txt
  [ "$status" -eq 0 ]
  echo "rEFACTOR: refactor code" > temp.txt
  run $script temp.txt
  [ "$status" -eq 0 ]
}

# 06
@test "06 - valid scopes with different cases" {
  echo "feat(SCOPE): add new feature" > temp.txt
  run $script temp.txt
  [ "$status" -eq 0 ]
  echo "fix(Scope): resolve issue" > temp.txt
  run $script temp.txt
  [ "$status" -eq 0 ]
  echo "docs(sCoPe): update documentation" > temp.txt
  run $script temp.txt
  [ "$status" -eq 0 ]
}

# 07
@test "07 - valid '!' in type/scope prefix with different cases" {
  echo "feat!: add new breaking feature" > temp.txt
  run $script temp.txt
  [ "$status" -eq 0 ]
  echo "Feat(SCOPE)!: add new breaking feature" > temp.txt
  run $script temp.txt
  [ "$status" -eq 0 ]
}

# 08
@test "08 - blank line after commit header" {
  echo -e $'feat: add new feature\n\nThis is the commit body.' > temp.txt
  run $script temp.txt
  [ "$status" -eq 0 ]
  [ "$output" = "" ] # Validate that the stdout is empty
}

# 09
@test "09 - valid BREAKING CHANGE in footer" {
  echo -e $'feat: add new feature\n\nBREAKING CHANGE: changes break API' > temp.txt
  run $script temp.txt
  echo "Error message: $output"
  [ "$status" -eq 0 ]
  [ "$output" = "" ] # Validate that the stdout is empty
}

# 10
@test "10 - valid BREAKING-CHANGE in footer" {
  echo -e $'fix: resolve issue\n\nBREAKING-CHANGE: changes break API' > temp.txt
  run $script temp.txt
  [ "$status" -eq 0 ]
  [ "$output" = "" ] # Validate that the stdout is empty
}

# 11
@test "11 - valid '!' in type/scope prefix" {
  echo "feat!: add new feature" > temp.txt
  run $script temp.txt
  [ "$status" -eq 0 ]
  [ "$output" = "" ] # Validate that the stdout is empty
}

# 12
@test "12 - valid '!' in type/scope prefix with scope" {
  echo "feat(parser)!: add new feature" > temp.txt
  run $script temp.txt
  [ "$status" -eq 0 ]
  [ "$output" = "" ] # Validate that the stdout is empty
}

# 13
@test "13 - Header + Normal footer" {
    temp_file=$(mktemp)
    echo "feat: add new feature

body of the commit

issue: #123" > "$temp_file"
    run bash commit-msg.sh "$temp_file"
    rm "$temp_file"
    [ "$status" -eq 0 ]
}

# 14
@test "14 - Header + Multiple normal footer" {
    temp_file=$(mktemp)
    echo "feat: add new feature

body of the commit

issue: #123
issue: #456" > "$temp_file"
    run bash commit-msg.sh "$temp_file"
    echo "status:  $status"
    echo "output:  $output"
    rm "$temp_file"
    [ "$status" -eq 0 ]
    [ "$output" = "" ]
}

# 15
@test "15 - Header + Normal footer + Breaking change" {
    temp_file=$(mktemp)
    echo "feat: add new feature

body of the commit

issue: #123
BREAKING CHANGE: changes break API" > "$temp_file"
    run bash commit-msg.sh "$temp_file"
    echo "status:  $status"
    echo "output:  $output"
    rm "$temp_file"
    [ "$status" -eq 0 ]
    [ "$output" = "" ]
}

# 16
@test "16 - Header + Multiple normal footer + Multiple breaking changes" {
    temp_file=$(mktemp)
    echo "feat: add new feature

body of the commit

issue: #123
BREAKING CHANGE: changes break API
BREAKING-CHANGE: another changes that breaks API
issue: #456" > "$temp_file"
    run bash commit-msg.sh "$temp_file"
    echo "status:  $status"
    echo "output:  $output"
    rm "$temp_file"
    [ "$status" -eq 0 ]
    [ "$output" = "" ]
}

# 17
@test "17 - With multiple body paragraphs" {
    temp_file=$(mktemp)
    echo "feat: add new feature

body of the commit

Another paragraph of the body.

issue: #123
issue: #456
BREAKING CHANGE: changes break API
BREAKING-CHANGE: another changes that breaks API
issue: #789" > "$temp_file"
    run bash commit-msg.sh "$temp_file"
    echo "status:  $status"
    echo "output:  $output"
    rm "$temp_file"
    [ "$status" -eq 0 ]
    [ "$output" = "" ]
}



################ FAILURE ################

# 18
@test "18 - empty commit header" {
  echo ": description without type" > temp.txt
  run $script temp.txt
  [ "$status" -ne 0 ]
  [ "$output" = "$commit_header_failure" ]
}

# 19
@test "19 - invalid commit message" {
  echo "Invalid commit message" > temp.txt
  run $script temp.txt
  [ "$status" -ne 0 ]
  [ "$output" = "$commit_header_failure" ]
}

# 20
@test "20 - invalid commit type" {
  echo "invalid: commit type" > temp.txt
  run $script temp.txt
  [ "$status" -ne 0 ]
  [ "$output" = "$commit_header_failure" ]
}

# 21
@test "21 - correct type but missing colon" {
  echo "feat no colon after header" > temp.txt
  run $script temp.txt
  [ "$status" -ne 0 ]
  [ "$output" = "$commit_header_failure" ]
}

# 22
@test "22 - empty scope but present parenthesis" {
  echo "feat(): empty scope" > temp.txt
  run $script temp.txt
  [ "$status" -ne 0 ]
  [ "$output" = "$commit_header_failure" ]
}

# 23
@test "23 - missing parenthesis in scope" {
  echo "feat parser: missing parenthesis in scope" > temp.txt
  run $script temp.txt
  [ "$status" -ne 0 ]
  [ "$output" = "$commit_header_failure" ]
}

# 24
@test "24 - white space between type and scope" {
  echo "feat (parser): missing parenthesis in scope" > temp.txt
  run $script temp.txt
  [ "$status" -ne 0 ]
  [ "$output" = "$commit_header_failure" ]
}

# 25
@test "25 - white space after scope" {
  echo "feat(parser) : missing parenthesis in scope" > temp.txt
  run $script temp.txt
  [ "$status" -ne 0 ]
  [ "$output" = "$commit_header_failure" ]
}

# 26
@test "26 - white space before colon" {
  echo "feat(parser)! : missing parenthesis in scope" > temp.txt
  run $script temp.txt
  [ "$status" -ne 0 ]
  [ "$output" = "$commit_header_failure" ]
}

# 27
@test "27 - white space before breaking symbol" {
  echo "feat(parser) !: missing parenthesis in scope" > temp.txt
  run $script temp.txt
  [ "$status" -ne 0 ]
  [ "$output" = "$commit_header_failure" ]
}

# 28
@test "28 - bad optional symbol" {
  echo "test?: bad optional symbol" > temp.txt
  run $script temp.txt

  [ -n "$output" ]
  [ "$output" = "$commit_header_failure" ]
  [ "$status" -ne 0 ]
}

# 29
@test "29 - bad optional symbol with scope" {
  echo "test(scope)?: bad optional symbol" > temp.txt
  run $script temp.txt

  [ -n "$output" ]
  [ "$output" = "$commit_header_failure" ]
  [ "$status" -ne 0 ]
}

# 30
@test "30 - header too long" {
  header="feat: $(printf '%*s' 89)"
  echo "$header" > temp.txt
  run $script temp.txt
  echo "status:  $status"
  echo "output:  $output"
  [ "$status" -ne 0 ]
  [ "$output" = "$commit_header_too_long" ]
}

# 31
@test "31 - missing blank line after commit header" {
  echo -e $'feat: add new feature\nThis is the commit body.' > temp.txt
  run $script temp.txt
  echo -e $'feat: add new feature\nThis is the commit body.'
  [ "$status" -ne 0 ]
  [ "$output" = "$body_missing_new_line" ]
}

# 32
@test "32 - Valid body paragraph spacing" {
  echo -e $'feat: add new feature\n\ndescription of the feature\nmore description of the feature' > temp.txt
  run $script temp.txt
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
  
  echo -e $'feat: add new feature\n\nThis is the first paragraph\nThis is the second paragraph\nThis is the third paragraph' > temp.txt
  run $script temp.txt
  [ "$status" -eq 0 ]
  [ "$output" = "" ]

  echo -e $'feat: add new feature\n\ndescription of the feature\nmore description of the feature\n\neven more description of the feature' > temp.txt
  run $script temp.txt
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}

# 33
@test "33 - '!' in type/scope prefix without subsequent colon" {
  echo "feat! add new feature" > temp.txt
  run $script temp.txt
  [ "$status" -ne 0 ]
  [ "$output" = "$commit_header_failure" ]
}

# 34
@test "34 - '!' in type/scope prefix with scope but without subsequent colon" {
  echo "feat(parser)! add new feature" > temp.txt
  run $script temp.txt
  [ "$status" -ne 0 ]
  [ "$output" = "$commit_header_failure" ]
}

## FOOTER

# 35A
@test "35A - Body should not include any line starting with BREAKING CHANGE without colon" {
  echo -e $'feat: add new feature\n\nBREAKING CHANGE changes break API' > temp.txt
  run $script temp.txt
  [ "$status" -ne 0 ]
  [ "$output" = "$breaking_change_in_body" ]

  echo -e $'feat: add new feature\n\nThis is body\n\nBREAKING CHANGE changes break API' > temp.txt
  run $script temp.txt
  [ "$status" -ne 0 ]
  [ "$output" = "$breaking_change_in_body" ]
}

# 35B
@test "35B - Body can include a line with BREAKING CHANGE if is not at the start of a line" {
  echo -e $'feat: add new feature\n\nthis is a BREAKING CHANGE for the API' > temp.txt
  run $script temp.txt
  [ "$status" -eq 0 ]

  echo -e $'feat: add new feature\n\nThis is body\n\nthis is a BREAKING CHANGE for the API' > temp.txt
  run $script temp.txt
  [ "$status" -eq 0 ]
}

# 36A
@test "36A - Body should not include line starting with BREAKING-CHANGE without colon" {
  echo -e $'fix: resolve issue\n\nBREAKING-CHANGE changes break API' > temp.txt
  run $script temp.txt
  [ "$status" -ne 0 ]
  [ "$output" = "$breaking_change_in_body" ]

  echo -e $'feat: add new feature\n\nThis is body\n\nBREAKING-CHANGE changes break API' > temp.txt
  run $script temp.txt
  [ "$status" -ne 0 ]
  [ "$output" = "$breaking_change_in_body" ]
}

# 36B
@test "36B - Body can include a line with BREAKING-CHANGE if is not at the start of a line" {
  echo -e $'feat: add new feature\n\nthis is a BREAKING-CHANGE for the API' > temp.txt
  run $script temp.txt
  [ "$status" -eq 0 ]

  echo -e $'feat: add new feature\n\nThis is body\n\nthis is a BREAKING-CHANGE for the API' > temp.txt
  run $script temp.txt
  [ "$status" -eq 0 ]
}

# 37A
@test "37A - Body should not includ invalid 'breaking change: ' and 'breaking-change: ' descriptions" { 
  echo -e $'feat: add new feature\n\nbreaking change: changes break API' > temp.txt
  run $script temp.txt

  [ "$status" -ne 0 ]
  [ "$output" = "$breaking_change_in_body" ]
  
  echo -e $'fix: resolve issue\n\nbreaking-change: changes break API' > temp.txt #body should not contain a new line that starts with 'breaking-change: '
  run $script temp.txt
  
  echo "status:  $status"
  echo "output:  $output"
  [ "$status" -ne 0 ]
  [ "$output" = "$breaking_change_in_body" ] #TODO: continue from here

  
}

# 37B
@test "37B - Body can includ invalid 'breaking change' and 'breaking-change' in the descriptions" { 
  echo -e $'feat: add new feature\n\nthis is the description of a breaking change in the API' > temp.txt
  run $script temp.txt

  [ "$status" -eq 0 ]
  
  echo -e $'fix: resolve issue\n\nthis is the description of a breaking-change in the API' > temp.txt
  run $script temp.txt

  [ "$status" -eq 0 ]
}

# 38
@test "38 - Lowercase BREAKING CHANGE or BREAKING-CHANGE" { #footer should not containt breaking change in lowercase
    temp_file=$(mktemp)
    echo "feat: add new feature

body of the commit

issue: #123
breaking change: changes break API" > "$temp_file"
    run bash commit-msg.sh "$temp_file"
    echo "status:  $status"
    echo "output:  $output"
    rm "$temp_file"
    [ "$status" -ne 0 ]
}

# 39
@test "39 - BREAKING CHANGE or BREAKING-CHANGE without ':'" { #footer should not contain a line that starts with 'BREAKING CHANGE ' or 'BREAKING-CHANGE ', without a colon
    temp_file=$(mktemp)
    echo "feat: add new feature

body of the commit

issue: #123
BREAKING CHANGE changes break API" > "$temp_file"
    run bash commit-msg.sh "$temp_file"
    echo "status:  $status"
    echo "output:  $output"
    rm "$temp_file"
    [ "$status" -ne 0 ]
}

# 40
@test "40 - Footer empty lines" { #footer should have its elements wiouth extra linebreaks
    temp_file=$(mktemp)
    echo "feat: add new feature

body of the commit

issue: #123

issue: #456" > "$temp_file"
    run bash commit-msg.sh "$temp_file"
    echo "status:  $status"
    echo "output:  $output"
    rm "$temp_file"
    [ "$status" -ne 0 ]
}
