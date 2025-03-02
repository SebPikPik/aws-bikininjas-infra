#!/bin/bash

# Script to clean up old and unused tags

# Get the latest commit hash
LATEST_COMMIT=$(git rev-parse HEAD)

# Get all beta tags
BETA_TAGS=$(git tag -l "beta-*")

# Get all version tags
VERSION_TAGS=$(git tag -l "v*")

# Keep track of tags to delete
TAGS_TO_DELETE=()

# Process beta tags - keep only the most recent one
LATEST_BETA=""
LATEST_BETA_COMMIT=""

for tag in $BETA_TAGS; do
    commit=$(git rev-list -n 1 $tag)
    if [[ -z "$LATEST_BETA" || $(git log --format=%ct -1 $commit) -gt $(git log --format=%ct -1 $LATEST_BETA_COMMIT) ]]; then
        LATEST_BETA=$tag
        LATEST_BETA_COMMIT=$commit
    fi
done

# Mark all beta tags for deletion except the latest one
for tag in $BETA_TAGS; do
    if [[ "$tag" != "$LATEST_BETA" ]]; then
        TAGS_TO_DELETE+=("$tag")
    fi
done

# Keep only the highest version for each minor version
declare -A HIGHEST_VERSIONS
for tag in $VERSION_TAGS; do
    # Extract the minor version (e.g., v0.1 from v0.1.1-beta.12)
    minor_version=$(echo $tag | grep -o "v[0-9]*\.[0-9]*")
    
    if [[ -z "${HIGHEST_VERSIONS[$minor_version]}" ]]; then
        HIGHEST_VERSIONS[$minor_version]=$tag
    else
        # Compare version numbers to keep the highest
        current=${HIGHEST_VERSIONS[$minor_version]}
        # Simple string comparison - might need improvement for complex versioning
        if [[ "$tag" > "$current" ]]; then
            TAGS_TO_DELETE+=("$current")
            HIGHEST_VERSIONS[$minor_version]=$tag
        else
            TAGS_TO_DELETE+=("$tag")
        fi
    fi
done

# Print summary
echo "Tags to keep:"
echo "- $LATEST_BETA (latest beta tag)"
for version in "${!HIGHEST_VERSIONS[@]}"; do
    echo "- ${HIGHEST_VERSIONS[$version]} (highest for $version)"
done

echo -e "\nTags to delete:"
for tag in "${TAGS_TO_DELETE[@]}"; do
    echo "- $tag"
done

# Confirm deletion
echo -e "\nDo you want to delete these tags? (y/n)"
read -r confirm

if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
    # Delete tags locally
    for tag in "${TAGS_TO_DELETE[@]}"; do
        echo "Deleting local tag: $tag"
        git tag -d "$tag"
    done
    
    # Delete tags on remote
    for tag in "${TAGS_TO_DELETE[@]}"; do
        echo "Deleting remote tag: $tag"
        git push origin --delete "$tag"
    done
    echo "Tags cleaned up successfully!"
else
    echo "Operation cancelled. No tags were deleted."
fi
