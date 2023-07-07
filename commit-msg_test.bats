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

################ SUCCESS ################

# Test a valid commit message
@test "valid commit message" {
  echo "feat: add new feature" > temp.txt
  run $script temp.txt
  [ "$status" -eq 0 ]
  [ "$output" = "" ] # Validate that the stdout is empty
}

# Test a valid commit message with scope
@test "valid commit message with scope" {
  echo "feat(parser): add new parser" > temp.txt
  run $script temp.txt
  [ "$status" -eq 0 ]
  [ "$output" = "" ] # Validate that the stdout is empty
}

# Test a valid commit message with scope and optional
@test "valid commit message with scope and optional" {
  echo "feat(parser)!: add new parser" > temp.txt
  run $script temp.txt
  [ "$status" -eq 0 ]
  [ "$output" = "" ] # Validate that the stdout is empty
}
# Test a valid commit message with optional
@test "valid commit message with optional" {
  echo "feat!: add new feature" > temp.txt
  run $script temp.txt
  [ "$status" -eq 0 ]
  [ "$output" = "" ] # Validate that the stdout is empty
}

# Test valid types with different cases
@test "valid types with different cases" {
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

# Test valid scopes with different cases
@test "valid scopes with different cases" {
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

# Test valid '!' in type/scope prefix with different cases
@test "valid '!' in type/scope prefix with different cases" {
  echo "feat!: add new breaking feature" > temp.txt
  run $script temp.txt
  [ "$status" -eq 0 ]
  echo "Feat(SCOPE)!: add new breaking feature" > temp.txt
  run $script temp.txt
  [ "$status" -eq 0 ]
}

# Test with blank line after commit header
@test "blank line after commit header" {
  echo -e $'feat: add new feature\n\nThis is the commit body.' > temp.txt
  run $script temp.txt
  [ "$status" -eq 0 ]
  [ "$output" = "" ] # Validate that the stdout is empty
}

# Test valid BREAKING CHANGE in footer
@test "valid BREAKING CHANGE in footer" {
  echo -e $'feat: add new feature\n\nBREAKING CHANGE: changes break API' > temp.txt
  run $script temp.txt
  [ "$status" -eq 0 ]
  [ "$output" = "" ] # Validate that the stdout is empty
}

# Test valid BREAKING-CHANGE in footer
@test "valid BREAKING-CHANGE in footer" {
  echo -e $'fix: resolve issue\n\nBREAKING-CHANGE: changes break API' > temp.txt
  run $script temp.txt
  [ "$status" -eq 0 ]
  [ "$output" = "" ] # Validate that the stdout is empty
}

# Test valid '!' in type/scope prefix
@test "valid '!' in type/scope prefix" {
  echo "feat!: add new feature" > temp.txt
  run $script temp.txt
  [ "$status" -eq 0 ]
  [ "$output" = "" ] # Validate that the stdout is empty
}

# Test valid '!' in type/scope prefix with scope
@test "valid '!' in type/scope prefix with scope" {
  echo "feat(parser)!: add new feature" > temp.txt
  run $script temp.txt
  [ "$status" -eq 0 ]
  [ "$output" = "" ] # Validate that the stdout is empty
}

@test "Header + Normal footer" {
    temp_file=$(mktemp)
    echo "feat: add new feature

body of the commit

issue: #123" > "$temp_file"
    run bash commit-msg.sh "$temp_file"
    rm "$temp_file"
    [ "$status" -eq 0 ]
}

@test "Header + Multiple normal footer" {
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

@test "Header + Normal footer + Breaking change" {
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

@test "Header + Multiple normal footer + Multiple breaking changes" {
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

@test "With multiple body paragraphs" {
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

# Test with empty commit header
@test "empty commit header" {
  echo ": description without type" > temp.txt
  run $script temp.txt
  [ "$status" -ne 0 ]
  [ "$output" = "$commit_header_failure" ]
}

# Test an invalid commit message
@test "invalid commit message" {
  echo "Invalid commit message" > temp.txt
  run $script temp.txt
  [ "$status" -ne 0 ]
  [ "$output" = "$commit_header_failure" ]
}

# Test an invalid commit type
@test "invalid commit type" {
  echo "invalid: commit type" > temp.txt
  run $script temp.txt
  [ "$status" -ne 0 ]
  [ "$output" = "$commit_header_failure" ]
}

# Test correct type but missing colon
@test "correct type but missing colon" {
  echo "feat no colon after header" > temp.txt
  run $script temp.txt
  [ "$status" -ne 0 ]
  [ "$output" = "$commit_header_failure" ]
}

# Test empty scope
@test "empty scope but present parenthesis" {
  echo "feat(): empty scope" > temp.txt
  run $script temp.txt
  [ "$status" -ne 0 ]
  [ "$output" = "$commit_header_failure" ]
}

# Test missing parenthesis in scope
@test "missing parenthesis in scope" {
  echo "feat parser: missing parenthesis in scope" > temp.txt
  run $script temp.txt
  [ "$status" -ne 0 ]
  [ "$output" = "$commit_header_failure" ]
}

# Test white space between type and scope
@test "white space between type and scope" {
  echo "feat (parser): missing parenthesis in scope" > temp.txt
  run $script temp.txt
  [ "$status" -ne 0 ]
  [ "$output" = "$commit_header_failure" ]
}

# Test white space after scope
@test "white space after scope" {
  echo "feat(parser) : missing parenthesis in scope" > temp.txt
  run $script temp.txt
  [ "$status" -ne 0 ]
  [ "$output" = "$commit_header_failure" ]
}

# Test white space before colon
@test "white space before colon" {
  echo "feat(parser)! : missing parenthesis in scope" > temp.txt
  run $script temp.txt
  [ "$status" -ne 0 ]
  [ "$output" = "$commit_header_failure" ]
}

# Test white space before breaking symbol
@test "white space before breaking symbol" {
  echo "feat(parser) !: missing parenthesis in scope" > temp.txt
  run $script temp.txt
  [ "$status" -ne 0 ]
  [ "$output" = "$commit_header_failure" ]
}

# Test bad optional symbol
@test "bad optional symbol" {
  echo "test?: bad optional symbol" > temp.txt
  run $script temp.txt

  [ -n "$output" ]
  [ "$output" = "$commit_header_failure" ]
  [ "$status" -ne 0 ]
}

# Test bad optional symbol with scope
@test "bad optional symbol with scope" {
  echo "test(scope)?: bad optional symbol" > temp.txt
  run $script temp.txt

  [ -n "$output" ]
  [ "$output" = "$commit_header_failure" ]
  [ "$status" -ne 0 ]
}

# Test header that is too long
@test "header too long" {
  header="feat: $(printf '%*s' 89)"
  echo "$header" > temp.txt
  run $script temp.txt
  echo "status:  $status"
  echo "output:  $output"
  [ "$status" -ne 0 ]
  [ "$output" = "$commit_header_too_long" ]
}

# Test missing blank line after commit header
@test "missing blank line after commit header" {
  echo -e $'feat: add new feature\nThis is the commit body.' > temp.txt
  run $script temp.txt
  echo -e $'feat: add new feature\nThis is the commit body.'
  [ "$status" -ne 0 ]
  [ "$output" = "$body_missing_new_line" ]
}

# Test invalid body paragraph spacing
@test "invalid body paragraph spacing" {
  echo -e $'feat: add new feature\n\ndescription of the feature\nmore description of the feature' > temp.txt
  run $script temp.txt
  [ "$status" -ne 0 ]
  [ "$output" = "TODO" ]
  
  echo -e $'feat: add new feature\n\nThis is the first paragraph\nThis is the second paragraph\nThis is the third paragraph' > temp.txt
  run $script temp.txt
  [ "$status" -ne 0 ]
  [ "$output" = "TODO" ]

  echo -e $'feat: add new feature\n\ndescription of the feature\nmore description of the feature\n\neven more description of the feature' > temp.txt
  run $script temp.txt
  [ "$status" -ne 0 ]
  [ "$output" = "TODO" ]
}

# Test BREAKING CHANGE without colon
@test "BREAKING CHANGE without colon" {
  echo -e $'feat: add new feature\n\nBREAKING CHANGE changes break API' > temp.txt
  run $script temp.txt
  echo "status:  $status"
  echo "output:  $output"
  [ "$status" -ne 0 ]
  [ "$output" = "Aborting commit. Breaking changes must be indicated in the commit footer or header as 'BREAKING CHANGE: description' or 'BREAKING-CHANGE: description'." ]
}

# Test BREAKING-CHANGE without colon
@test "BREAKING-CHANGE without colon" {
  echo -e $'fix: resolve issue\n\nBREAKING-CHANGE changes break API' > temp.txt
  run $script temp.txt
  echo "status:  $status"
  echo "output:  $output"
  [ "$status" -ne 0 ]
  [ "$output" = "Aborting commit. Breaking changes must be indicated in the commit footer or header as 'BREAKING CHANGE: description' or 'BREAKING-CHANGE: description'." ]
}

# Test invalid 'BREAKING CHANGE' and 'BREAKING-CHANGE' with different cases
@test "invalid 'BREAKING CHANGE' and 'BREAKING-CHANGE' with different cases" {
  echo -e $'feat: add new feature\n\nbreaking change: changes break API' > temp.txt
  run $script temp.txt
  echo "status:  $status"
  echo "output:  $output"
  [ "$status" -ne 0 ]
  [ "$output" = "Aborting commit. Breaking changes must be indicated in the commit footer or header as 'BREAKING CHANGE: description' or 'BREAKING-CHANGE: description'." ]
  
  echo -e $'fix: resolve issue\n\nbreaking-change: changes break API' > temp.txt
  run $script temp.txt
  echo "status:  $status"
  echo "output:  $output"
  [ "$status" -ne 0 ]
  [ "$output" = "Aborting commit. Breaking changes must be indicated in the commit footer or header as 'BREAKING CHANGE: description' or 'BREAKING-CHANGE: description'." ]
}

# Test '!' in type/scope prefix without subsequent colon
@test "'!' in type/scope prefix without subsequent colon" {
  echo "feat! add new feature" > temp.txt
  run $script temp.txt
  [ "$status" -ne 0 ]
  [ "$output" = "$commit_header_failure" ]
}

# Test '!' in type/scope prefix with scope but without subsequent colon
@test "'!' in type/scope prefix with scope but without subsequent colon" {
  echo "feat(parser)! add new feature" > temp.txt
  run $script temp.txt
  [ "$status" -ne 0 ]
  [ "$output" = "$commit_header_failure" ]
}

@test "Footer without ':' or '#'" {
    temp_file=$(mktemp)
    echo "feat: add new feature

body of the commit

issue 123" > "$temp_file"
    run bash commit-msg.sh "$temp_file"
    echo "status:  $status"
    echo "output:  $output"
    rm "$temp_file"
    [ "$status" -ne 0 ]
}

@test "BREAKING CHANGE or BREAKING-CHANGE without ':'" {
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

@test "Footer with '-' instead of ':'" {
    temp_file=$(mktemp)
    echo "feat: add new feature

body of the commit

issue- #123" > "$temp_file"
    run bash commit-msg.sh "$temp_file"
    echo "status:  $status"
    echo "output:  $output"
    rm "$temp_file"
    [ "$status" -ne 0 ]
}

@test "Two consecutive empty lines in body" {
    temp_file=$(mktemp)
    echo "feat: add new feature

body of the commit


Another paragraph of the body.

issue: #123
BREAKING CHANGE: changes break API" > "$temp_file"
    run bash commit-msg.sh "$temp_file"
    echo "status:  $status"
    echo "output:  $output"
    rm "$temp_file"
    [ "$status" -ne 0 ]
}

@test "Lowercase BREAKING CHANGE or BREAKING-CHANGE" {
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

@test "Footer empty lines" {
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
