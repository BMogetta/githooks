[![Conventional Commits](https://img.shields.io/badge/Conventional%20Commits-1.0.0-%23FE5196?logo=conventionalcommits&logoColor=white)](https://conventionalcommits.org)

```bash
git clone https://github.com/bats-core/bats-core.git
cd bats-core
sudo ./install.sh /usr/local
bats --version
```

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

## The commit contains the following structural elements, to communicate intent to the consumers of your library:

1. fix: a commit of the type fix patches a bug in your codebase (this correlates with PATCH in Semantic Versioning).
2. feat: a commit of the type feat introduces a new feature to the codebase (this correlates with MINOR in Semantic Versioning).
3. BREAKING CHANGE: a commit that has a footer BREAKING CHANGE:, or appends a ! after the type/scope, introduces a breaking API change (correlating with MAJOR in Semantic Versioning). A BREAKING CHANGE can be part of commits of any type.


```bash
#!/bin/bash

# Get the name of the current branch
branch_name=$(git symbolic-ref --short HEAD)

# Define the pattern or consistency criteria for branch names
branch_pattern="^[A-Za-z0-9_-]+$"

# Check if the branch name matches the pattern
if ! [[ $branch_name =~ $branch_pattern ]]; then
    echo "Error: Branch name '$branch_name' does not match the required pattern."
    echo "Branch names should only contain alphanumeric characters, dashes, and underscores."
    exit 1
fi
```

```bash
## BODY ##
body_missing_new_line="Aborting commit. Your commit body must begin one blank line after the description.
i.e-> feat: add new feature

This is the commit body."
breaking_change_pattern="^(BREAKING CHANGE|BREAKING-CHANGE): .*$"
# Check if the body starts with an empty line
if [[ -n $commit_body && ! $commit_body =~ ^\n ]]; then
  if echo "$commit_body$commit_header" | grep -qiE "BREAKING[- ]CHANGE.*|(^|\n)(.*)!.*:.*"; then
    if ! echo "$commit_body$commit_header" | grep -qE "$breaking_change_pattern|(^|\n)(.*)!.*:.*"; then
      echo "Aborting commit. Breaking changes must be indicated in the commit footer or header as 'BREAKING CHANGE: description' or 'BREAKING-CHANGE: description'." >&2
      exit 1
    fi
  else
    echo "$body_missing_new_line"
  fi
else
  echo "$body_missing_new_line"
fi
```