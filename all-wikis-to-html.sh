#!/bin/bash
set -e
echo "usage for public repos: $0 https://gitlab.whatever.org/  user1/repo1 user2/repo2 ..."
echo "for private repos: GITLAB_SESSION_COOKIE=a1337f0000  $0 ...."
mkdir output/ || rm -r output/
for repo in ${@:2}; do
    mkdir -p output/$repo
    ./gitlabwiki-to-html.sh $1 $repo output/$repo $GITLAB_COOKIE
done
