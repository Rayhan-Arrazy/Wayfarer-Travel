const { execSync, spawn } = require('child_process');

const open = (url) => {
  const start = process.platform === 'win32' ? 'start' : process.platform === 'darwin' ? 'open' : 'xdg-open';
  try {
    execSync(`${start} ${url}`, { stdio: 'ignore' });
  } catch (e) {}
};

const PORTS = [5000, 3000];

for (const port of PORTS) {
  try {
    if (process.platform === 'win32') {
      const stdout = execSync(`netstat -ano | findstr :${port}`).toString().trim();
      if (stdout) {
        stdout.split('\n').filter(Boolean).forEach(line => {
          const pid = line.trim().split(/\s+/).pop();
          if (pid && !isNaN(pid)) execSync(`taskkill /F /PID ${pid} /T`, { stdio: 'ignore' });
        });
      }
    }
  } catch (e) {}
}

const cmd = `npx concurrently --raw ` +
            `"cd backend && node server.js" ` +
            `"cd wayfarer && flutter run -d web-server --web-port=3000"`;

spawn('cmd.exe', ['/c', cmd], { stdio: 'inherit', shell: true });

setTimeout(() => {
  open('http://localhost:3000');
}, 5000); 
