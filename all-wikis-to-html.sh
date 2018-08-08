#!/bin/sh
set -e
echo "usage: GITLAB_SESSION_COOKIE=a1337f0000  $0 user1/repo1 user2/repo2 ..."
mkdir output/ || rm -r output/
for repo in $@; do
    mkdir -p output/$repo
    ./gitlabwiki-to-html.sh https://gitlab.cs.fau.de/ $repo output/$repo $GITLAB_COOKIE
done
