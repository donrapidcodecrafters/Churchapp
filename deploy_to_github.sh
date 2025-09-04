#!/bin/bash
# ==========================================
# Deploy Church App Bundle to GitHub
# ==========================================

ZIP_FILE="church_app_hdmi_bundle.zip"
PROJECT_DIR="Churchapp"
REPO_URL="https://github.com/donrapidcodecrafters/Churchapp.git"

# 1. Unzip bundle
echo "Unzipping bundle..."
rm -rf $PROJECT_DIR
unzip -q $ZIP_FILE -d $PROJECT_DIR

cd $PROJECT_DIR || { echo "Failed to enter project dir"; exit 1; }

# 2. Init Git if not already
if [ ! -d ".git" ]; then
  git init
fi

# 3. Add remote (overwrite if exists)
if git remote | grep origin > /dev/null; then
  git remote set-url origin $REPO_URL
else
  git remote add origin $REPO_URL
fi

# 4. Stage all files
git add .

# 5. Commit
git commit -m "Deploy: Church App with HDMI, Pastor Notes, OCR, Docker SSL, CI/CD" || echo "Nothing to commit"

# 6. Push to GitHub
git branch -M main
git push -u origin main

echo "✅ Deployment complete! Repo updated at $REPO_URL"
