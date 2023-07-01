#!/usr/bin/env bats

# The script being tested
script=./commit-msg.sh
types='feat|fix|chore|docs|test|style|refactor|perf|build|ci|revert'
commit_header_failure="Aborting commit. Your commit message header is invalid. Please follow the standards: type(scope)!: description
Commits MUST be prefixed with a type, which consists of one of $types,
followed by the OPTIONAL scope -between parenthesis- OPTIONAL ! -for breaking chages- and REQUIRED terminal colon and space."
long_header_failure="Aborting commit. Your description is too long.
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
  captured_stderr=$output
  captured_stdout=$status
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
  echo "feat: add new feature\n\nThis is the commit body." > temp.txt
  run $script temp.txt
  [ "$status" -eq 0 ]
  [ "$output" = "" ] # Validate that the stdout is empty
}

# Test valid BREAKING CHANGE in footer
@test "valid BREAKING CHANGE in footer" {
  echo -e "feat: add new feature\n\nBREAKING CHANGE: changes break API" > temp.txt
  run $script temp.txt
  [ "$status" -eq 0 ]
  [ "$output" = "" ] # Validate that the stdout is empty
}

# Test valid BREAKING-CHANGE in footer
@test "valid BREAKING-CHANGE in footer" {
  echo -e "fix: resolve issue\n\nBREAKING-CHANGE: changes break API" > temp.txt
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
  [ "$status" -ne 0 ]
  [ "$output" = "$long_header_failure" ]
}

# Test missing blank line after commit header
@test "missing blank line after commit header" {
  echo "feat: add new feature\nThis is the commit body." > temp.txt
  run $script temp.txt
  [ "$status" -ne 0 ]
  [ "$output" = "$body_missing_new_line" ]
}

# Test BREAKING CHANGE without colon
@test "BREAKING CHANGE without colon" {
  echo -e "feat: add new feature\n\nBREAKING CHANGE changes break API" > temp.txt
  run $script temp.txt
  [ "$status" -ne 0 ]
  [ "$output" = "Aborting commit. Breaking changes must be indicated in the commit footer or header as 'BREAKING CHANGE: description' or 'BREAKING-CHANGE: description'." ]
}

# Test BREAKING-CHANGE without colon
@test "BREAKING-CHANGE without colon" {
  echo -e "fix: resolve issue\n\nBREAKING-CHANGE changes break API" > temp.txt
  run $script temp.txt
  [ "$status" -ne 0 ]
  [ "$output" = "Aborting commit. Breaking changes must be indicated in the commit footer or header as 'BREAKING CHANGE: description' or 'BREAKING-CHANGE: description'." ]
}

# Test invalid 'BREAKING CHANGE' and 'BREAKING-CHANGE' with different cases
@test "invalid 'BREAKING CHANGE' and 'BREAKING-CHANGE' with different cases" {
  echo -e "feat: add new feature\n\nbreaking change: changes break API" > temp.txt
  run $script temp.txt
  echo "Status: $status"
  echo "Output: $output"
  [ "$status" -ne 0 ]
  [ "$output" = "Aborting commit. Breaking changes must be indicated in the commit footer or header as 'BREAKING CHANGE: description' or 'BREAKING-CHANGE: description'." ]
  
  echo -e "fix: resolve issue\n\nbreaking-change: changes break API" > temp.txt
  run $script temp.txt
  echo "Status: $status"
  echo "Output: $output"
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
