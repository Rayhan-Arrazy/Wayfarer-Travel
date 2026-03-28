const { execSync, spawn } = require('child_process');

// Auto-open URLs based on platform
const open = (url) => {
  const start = process.platform === 'darwin' ? 'open' : process.platform === 'win32' ? 'start' : 'xdg-open';
  execSync(`${start} ${url}`);
};

const PORTS = [5000, 3000, 3001];

// Clean ports before starting
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

console.log('--- Launching Wayfarer Total Ecosystem ---');

const cmd = `npx concurrently --raw ` +
            `"cd backend && node server.js" ` +
            `"cd wayfarer && flutter run -d web-server --web-port=3000" ` +
            `"cd wayfarer_admin && flutter run -d web-server --web-port=3001"`;

spawn('cmd.exe', ['/c', cmd], { stdio: 'inherit', shell: true });

// Wait for servers to settle then open browser
setTimeout(() => {
  console.log('\n--- URLs Ready ---');
  console.log('App: http://localhost:3000');
  console.log('Admin: http://localhost:3001');
  open('http://localhost:3000');
  open('http://localhost:3001');
}, 8000); // 8-second delay to allow web servers to start
