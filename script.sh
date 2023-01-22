#!/bin/bash

set -eu

TAG="$1"
BRANCH="$2"
ACCOUNT="$3"
REPO="$4"
EMAIL="$5"
GITHUB_TOKEN="$6"

[ -z "$TAG" ] && exit 1
[ -z "$BRANCH" ] && exit 1
[ -z "$ACCOUNT" ] && exit 1
[ -z "$REPO" ] && exit 1
[ -z "$EMAIL" ] && exit 1
[ -z "$GITHUB_TOKEN" ] && exit 1

URL="git@github.com:$ACCOUNT/$REPO.git"
SHA=$(git ls-remote $URL $BRANCH | cut -f1)
DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

cat > tag_object_req.json <<EOF
{
  "tag": "$TAG",
  "object": "$SHA",
  "message": "Creating tag $TAG",
  "tagger": {
    "name": "auto-tag-creator",
    "email": "$EMAIL",
    "date": "$DATE"
  },
  "type": "commit"
}
EOF

TAG_OBJECT_RESP=$(curl -s -X POST -d @tag_object_req.json --header "Content-Type:application/json" --header "Authorization: token $GITHUB_TOKEN" "https://api.github.com/repos/$ACCOUNT/$REPO/git/tags")

#echo "$TAG_OBJECT_RESP"

SHA_TAG=$(echo "$TAG_OBJECT_RESP" | jq -r '.sha')

cat > tag_ref_req.json <<EOF
{
  "ref": "refs/tags/$TAG",
  "sha": "$SHA_TAG"
}
EOF

TAG_REF_RESP=$(curl -s -X POST -d @tag_ref_req.json --header "Content-Type:application/json" --header "Authorization: token $GITHUB_TOKEN" "https://api.github.com/repos/$ACCOUNT/$REPO/git/refs")

#echo "$TAG_REF_RESP"

rm tag_object_req.json
rm tag_ref_req.json
