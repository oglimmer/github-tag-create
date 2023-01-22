#!/bin/bash

set -eu

TAG="$1"
BRANCH="$2"
ACCOUNT="$3"
REPO="$4"
EMAIL="$5"
GITHUB_TOKEN="$6"

SHA=$(git ls-remote "https://$ACCOUNT:$GITHUB_TOKEN@github.com/$ACCOUNT/$REPO.git" $BRANCH | cut -f1)
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
