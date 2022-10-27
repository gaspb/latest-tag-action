#!/bin/sh

set -e

git config --global --add safe.directory /github/workspace

git fetch --tags
# This suppress an error occurred when the repository is a complete one.
git fetch --prune --unshallow || true

to_grep=''
if [ "${INPUT_SEMVER_ONLY}" = 'false' ]; then
  to_grep="^${INPUT_PREFIX}"
else
  to_grep="^${INPUT_PREFIX}([0-9]+)\.([0-9]+)\.([0-9]+)(?:-([0-9A-Za-z-]+(?:\.[0-9A-Za-z-]+)*))?(?:\+[0-9A-Za-z-]+)?$"
fi

latest_tag=''
latest_version=''

for ref in $(git for-each-ref --sort=-creatordate --format '%(refname)' refs/tags); do
    tag="${ref#refs/tags/}"
    if echo "${tag}" | grep -Eq "${to_grep}"; then
      latest_tag="${tag}"
      latest_version="${tag#*${INPUT_PREFIX}}"
      break
    fi
done

if [ "${latest_tag}" = '' ] && [ "${INPUT_WITH_INITIAL_VERSION}" = 'true' ]; then
  latest_tag="${INPUT_INITIAL_VERSION}"
  latest_version="${INPUT_INITIAL_VERSION}"
fi

echo "tag=${latest_tag}" >> "$GITHUB_OUTPUT"
echo "version=${latest_version}" >> "$GITHUB_OUTPUT"
