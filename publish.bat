@echo off
cd /d "%~dp0"
git add -A
git commit -m "Update site" || echo Nothing to commit.
git push
echo.
echo Done. Vercel will redeploy in a few seconds.
pause
