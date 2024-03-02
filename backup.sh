#!/bin/bash

# Check if required environment variables are set
if [[ -z "$MONGO_URI" || -z "$DATABASE_NAME" || -z "$GITHUB_USERNAME" || -z "$GITHUB_REPO" || -z "$GITHUB_TOKEN" ]]; then
    echo "Error: Required environment variables are not set."
    exit 1
fi

# Dump MongoDB database to JSON
mongodump --uri="$MONGO_URI" --db="$DATABASE_NAME" --out="mongo_dump"

# Commit and push the dump to GitHub repository
cd mongo_dump || exit 1
git init
git config --global user.email "$GITHUB_EMAIL"
git config --global user.name "$GITHUB_USERNAME"
git add .
git commit -m "MongoDB dump $(date +'%Y-%m-%d %H:%M:%S')"
git push "https://${GITHUB_USERNAME}:${GITHUB_TOKEN}@github.com/${GITHUB_USERNAME}/${GITHUB_REPO}.git" master
