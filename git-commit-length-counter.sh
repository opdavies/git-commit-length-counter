#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

# Default to running in the current directory, but allow for overriding the
# repo path using an environment variable.
# e.g. `REPO=../somewhere-else ./git-commit-length-counter`
REPO="${REPO:-$(pwd)}"

# Return early if the repository directory doesn't exist.
[[ ! -d "${REPO}" ]] && exit 2

result_file="./result"
if [[ ! -f "${result_file}" ]]; then
  for commit_id in $(git -C "${REPO}" rev-list --all --no-merges); do
      echo "Processing commit ${commit_id}..."
      # Calculate the legnth of the commit message.
      commit_message=$(GIT_PAGER=cat git -C "${REPO}" show "${commit_id}" -s --format=%B)
      commit_message_length=$(echo "${commit_message}" | wc -l)

      # Store the commit IDs and the message length.
      echo "${commit_message_length} ${commit_id}" >> "${result_file}"
  done
fi

# Sort the result file so all files are sorted by the length of the message.
sort "${result_file}" --reverse --numeric-sort --output "${result_file}"

head "${result_file}" --lines 5

# Show the commit with the longest message.
commit_with_the_longest_message=$(head "${result_file}" --lines 1 | cut -d " " -f2)
git -C "${REPO}" show "${commit_with_the_longest_message}"
