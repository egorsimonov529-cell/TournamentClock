const { execSync } = require('child_process');
process.chdir('C:/Users/Lenovo/Desktop/works/MVP_Poker/tournament_clock');
execSync('git add web/index.html');
execSync('git commit -m "feat: add cache-busting to apple-touch-icon"');
execSync('git push origin HEAD:deploy');
console.log('Pushed to GitHub!');
