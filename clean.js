const { exec } = require('child_process');

const ports = [3000, 3001, 5000];

console.log('🧹 Cleaning up Wayfarer processes...');

ports.forEach(port => {
  const cmd = process.platform === 'win32' 
    ? `netstat -ano | findstr :${port}`
    : `lsof -i tcp:${port} | grep LISTEN | awk '{print $2}'`;

  exec(cmd, (err, stdout) => {
    if (stdout) {
      const pids = process.platform === 'win32'
        ? stdout.split('\n').map(line => line.trim().split(/\s+/).pop()).filter(pid => pid && pid !== '0')
        : stdout.split('\n').filter(Boolean);

      const uniquePids = [...new Set(pids)];
      uniquePids.forEach(pid => {
        console.log(`🔫 Terminating process ${pid} on port ${port}`);
        const killCmd = process.platform === 'win32' ? `taskkill /F /PID ${pid} /T` : `kill -9 ${pid}`;
        exec(killCmd);
      });
    }
  });
});

console.log('✨ Ports cleared for fresh start.');
