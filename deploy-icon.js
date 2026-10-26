const { execSync } = require('child_process');
process.chdir('C:/Users/Lenovo/Desktop/works/MVP_Poker/tournament_clock');
execSync('git add web/index.html web/icons/icon-192.png');
execSync('git commit -m "feat: add custom VEGAS icon for iOS home screen"');
execSync('git push origin HEAD:deploy');
console.log('Done!');
