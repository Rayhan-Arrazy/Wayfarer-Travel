const { execSync, spawn } = require('child_process');

const PORTS = [5000, 3000, 3001];

// Clean ports before starting
for (const port of PORTS) {
  try {
    if (process.platform === 'win32') {
      const stdout = execSync(`netstat -ano | findstr :${port}`, { stdio: 'pipe' }).toString();
      stdout.trim().split('\n').forEach(line => {
        const pid = line.trim().split(/\s+/).pop();
        if (pid && !isNaN(pid)) execSync(`taskkill /F /PID ${pid} /T`, { stdio: 'ignore' });
      });
    }
  } catch (e) {}
}

console.log('Finalizing Wayfarer Launch...');

// Start servers with raw logs so nothing is hidden
const cmd = `npx concurrently --raw ` +
            `"cd backend && node server.js" ` +
            `"cd wayfarer && flutter run -d web-server --web-port=3000" ` +
            `"cd wayfarer_admin && flutter run -d web-server --web-port=3001"`;

spawn('cmd.exe', ['/c', cmd], { stdio: 'inherit', shell: true });

console.log('--- System URLs ---');
console.log('App:   http://localhost:3000');
console.log('Admin: http://localhost:3001');
console.log('API:   http://localhost:5000');
console.log('-------------------');
