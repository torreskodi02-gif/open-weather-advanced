#!/data/data/com.termux/files/usr/bin/bash
set -e

echo "=========================================="
echo "  Open Weather – Setup"
echo "=========================================="

cd "$HOME/open-weather-flutter"

# Check login
if ! gh auth status &>/dev/null; then
  echo "You are not logged in. Run: gh auth login"
  exit 1
fi

echo "Creating git repo and pushing..."

git init -q
git add .
git commit -m "Open Weather – custom UI + update checker" -q || true
git branch -M main

git remote remove origin 2>/dev/null || true
git remote add origin https://github.com/torreskodi02-gif/open-weather-advanced.git

git push -u origin main --force

echo ""
echo "✓ Done! Code pushed."
echo ""
echo "Now open this link:"
echo "https://github.com/torreskodi02-gif/open-weather-advanced/actions"
echo ""
echo "Wait for the Build APK workflow to finish, then download the APK."
echo "=========================================="
