#!/bin/bash
################################################################################
# MERGE SECURITY FIXES TO MAIN AND CLEANUP CLAUDE BRANCH
# Run this script to merge all security improvements to main and remove traces
################################################################################

set -e  # Exit on error

echo "=========================================="
echo " MERGE SECURITY FIXES TO MAIN"
echo "=========================================="
echo ""

# Get current branch name
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
CLAUDE_BRANCH="claude/review-security-config-012qDQTsDSxoQH9fvFqvBWaa"

echo "Current branch: $CURRENT_BRANCH"
echo ""

# Step 1: Make sure we're on the claude branch
if [ "$CURRENT_BRANCH" != "$CLAUDE_BRANCH" ]; then
    echo "❌ Error: Not on claude branch!"
    echo "   Current: $CURRENT_BRANCH"
    echo "   Expected: $CLAUDE_BRANCH"
    exit 1
fi

# Step 2: Get the commit hash with security fixes
SECURITY_COMMIT=$(git log --oneline -1 --grep="security: Major security improvements" --format="%H")

if [ -z "$SECURITY_COMMIT" ]; then
    echo "❌ Error: Could not find security improvements commit!"
    exit 1
fi

echo "✅ Found security commit: $SECURITY_COMMIT"
echo ""

# Step 3: Checkout and update main
echo "📥 Fetching latest main..."
git fetch origin main

echo "🔀 Switching to main..."
git checkout main
git pull origin main

# Step 4: Cherry-pick the security commit
echo ""
echo "🍒 Cherry-picking security improvements..."
git cherry-pick $SECURITY_COMMIT

# Step 5: Push to main
echo ""
echo "📤 Pushing to main..."
git push origin main

# Step 6: Delete claude branch (local and remote)
echo ""
echo "🗑️  Deleting claude branch..."
git branch -D $CLAUDE_BRANCH
git push origin --delete $CLAUDE_BRANCH

# Step 7: Clean up
echo ""
echo "🧹 Cleaning up..."
git remote prune origin

echo ""
echo "=========================================="
echo " ✅ COMPLETED SUCCESSFULLY!"
echo "=========================================="
echo ""
echo "Summary:"
echo "  ✅ Security fixes merged to main"
echo "  ✅ Changes pushed to remote"
echo "  ✅ Claude branch deleted (local + remote)"
echo "  ✅ No traces left"
echo ""
echo "Current branch: $(git rev-parse --abbrev-ref HEAD)"
echo "Latest commit: $(git log --oneline -1)"
echo ""
