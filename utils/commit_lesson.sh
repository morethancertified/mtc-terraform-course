#!/bin/bash

# Navigate to the correct directory
cd /workspaces/mtc-terraform-course || exit

# Prompt for the lesson name
read -p "Enter lesson name: " lesson_name

# Stage all changes
git add .

# Commit changes
git commit -m "complete $lesson_name"

# Tag the lesson
git tag -f "$lesson_name"

# Push the tags
git push origin --tags

echo "Lesson $lesson_name committed and tagged successfully!"
