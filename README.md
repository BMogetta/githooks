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
# Check footer
if ! echo "$commit_footer" | grep -qE "^[-a-zA-Z]+[:#] "; then
    echo "Aborting commit. Your commit footer is not properly formatted. It should be 'token: value' or 'token # value'." >&2
    exit 1
fi
# Check for BREAKING CHANGE in footer or header
if echo "$commit_footer" | grep -qE "^BREAKING CHANGE: "; then
    :
elif echo "$commit_header" | grep -qE "^(feat|fix|chore|docs|test|style|refactor|perf|build|ci|revert)(\(.+?\))?!: "; then
    :
else
    echo "Aborting commit. Breaking changes must be indicated in the type/scope prefix of a commit, or as an entry in the footer." >&2
    exit 1
fi
```