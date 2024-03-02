#!/bin/bash

# Check if required environment variables are set
if [[ -z "$MONGO_URI" || -z "$DATABASE_NAME" || -z "$GITHUB_USERNAME" || -z "$GITHUB_REPO" || -z "$GITHUB_TOKEN" || -z "$COLLECTIONS" ]]; then
    echo "Error: Required environment variables are not set."
    exit 1
fi

# Convert comma-separated list of collections into an array
IFS=',' read -r -a COLLECTION_ARRAY <<< "$COLLECTIONS"

# Create directories if they don't exist
mkdir -p exports new_exports

# Loop through each collection and export it to JSON
for COLLECTION_NAME in "${COLLECTION_ARRAY[@]}"
do
    mongoexport --uri="$MONGO_URI" --db="$DATABASE_NAME" --collection="$COLLECTION_NAME" --out="new_exports/mongo_export_${COLLECTION_NAME}.json" --authenticationDatabase admin || {
        echo "Error: Failed to export collection $COLLECTION_NAME"
        exit 1
    }
done

# Change directory to exports
cd exports || exit 1

# Initialize a Git repository if not already initialized
if [ ! -d ".git" ]; then
    git init || {
        echo "Error: Failed to initialize git repository."
        exit 1
    }
    git config --global user.email "$GITHUB_EMAIL" || {
        echo "Error: Failed to set git user email."
        exit 1
    }
    git config --global user.name "$GITHUB_USERNAME" || {
        echo "Error: Failed to set git username."
        exit 1
    }
fi

# Pull the latest changes from the repository
git pull "https://${GITHUB_USERNAME}:${GITHUB_TOKEN}@github.com/${GITHUB_USERNAME}/${GITHUB_REPO}.git" master --allow-unrelated-histories

# Copy new export files
cp ../new_exports/* ./

# Add all files, commit, and push changes
git add . || {
    echo "Error: Failed to add files to git repository."
    exit 1
}
git commit -m "MongoDB dump $(date +'%Y-%m-%d %H:%M:%S')" || {
    echo "Error: Failed to commit changes."
    exit 1
}
git push "https://${GITHUB_USERNAME}:${GITHUB_TOKEN}@github.com/${GITHUB_USERNAME}/${GITHUB_REPO}.git" master || {
    echo "Error: Failed to push changes to the remote repository."
    exit 1
}
