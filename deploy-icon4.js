const { execFile } = require('child_process');
const path = require('path');

const gitPath = 'C:\\Program Files\\Git\\cmd\\git.exe';
const workDir = 'C:\\Users\\Lenovo\\Desktop\\works\\MVP_Poker\\tournament_clock';

function runGit(args) {
  return new Promise((resolve, reject) => {
    execFile(gitPath, args, { cwd: workDir }, (error, stdout, stderr) => {
      if (error) {
        console.error('Error:', error.message);
        reject(error);
        return;
      }
      console.log(stdout.toString());
      if (stderr.toString()) console.error(stderr.toString());
      resolve(stdout.toString());
    });
  });
}

async function deploy() {
  try {
    console.log('Adding files...');
    await runGit(['add', 'web/index.html']);
    
    console.log('Committing...');
    await runGit(['commit', '-m', 'feat: add cache-busting to apple-touch-icon']);
    
    console.log('Pushing...');
    await runGit(['push', 'origin', 'HEAD:deploy']);
    
    console.log('SUCCESS!');
  } catch (e) {
    console.error('FAILED:', e.message);
  }
}

deploy();
