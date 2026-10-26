@echo off
cd /d "C:\Users\Lenovo\Desktop\works\MVP_Poker\tournament_clock"
git add web/index.html
git commit -m "feat: add cache-busting to apple-touch-icon"
git push origin HEAD:deploy
echo Done!
pause
