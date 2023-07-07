from git import Repo
import re

def write_to_changelog(commit):
    with open('CHANGELOG.md', 'a') as f:
        f.write(f"- {commit.hexsha[:7]}: {commit.message}\n")

def update_version():
    with open('version.txt', 'r') as f:
        version = f.read().strip()
        major, minor, patch = map(int, version.split('.'))

        patch += 1
        if patch > 9:
            patch = 0
            minor += 1
        if minor > 9:
            minor = 0
            major += 1

        version = f"{major}.{minor}.{patch}"

    with open('version.txt', 'w') as f:
        f.write(version)

    return version

def main():
    repo = Repo('.')
    commits = list(repo.iter_commits('main'))  # or any branch

    # Reverse the list to start from the first commit
    commits.reverse()

    for commit in commits:
        write_to_changelog(commit)

    version = update_version()

    print(f"Changelog created for {len(commits)} commits.")
    print(f"Version updated to {version}")

if __name__ == "__main__":
    main()
