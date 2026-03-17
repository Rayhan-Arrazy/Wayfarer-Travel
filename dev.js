const { spawn, exec } = require('child_process');
const http = require('http');

const PORTS = {
    backend: 5000,
    app: 3000,
    admin: 3001
};

// 1. CLEANUP
function clean() {
    return new Promise((resolve) => {
        console.log('🧹 Cleaning up old sessions...');
        const portsToKill = Object.values(PORTS);
        let completed = 0;
        
        portsToKill.forEach(port => {
            const findCmd = `netstat -ano | findstr :${port}`;
            exec(findCmd, (err, stdout) => {
                if (stdout) {
                    const lines = stdout.trim().split('\n');
                    lines.forEach(line => {
                        const parts = line.trim().split(/\s+/);
                        const pid = parts[parts.length - 1];
                        if (pid && pid !== '0') {
                            exec(`taskkill /F /PID ${pid} /T`, () => {});
                        }
                    });
                }
                completed++;
                if (completed === portsToKill.length) resolve();
            });
        });
        
        // Give it a moment to release ports
        if (portsToKill.length === 0) resolve();
    });
}

// 2. WAIT FOR PORT
function waitForPort(port) {
    return new Promise((resolve) => {
        const check = () => {
            const req = http.request({ host: 'localhost', port, path: '/', method: 'GET' }, (res) => {
                resolve();
            });
            req.on('error', () => {
                setTimeout(check, 1000);
            });
            req.end();
        };
        check();
    });
}

async function start() {
    await clean();
    
    console.log('🚀 Launching Wayfarer Suite...');

    // Start Backend
    const backend = spawn('cmd.exe', ['/c', 'cd backend && npm run dev'], { stdio: 'inherit' });

    // Start App (Web Server Mode)
    console.log('📦 Initializing Customer App (3000)...');
    const app = spawn('cmd.exe', ['/c', 'cd wayfarer && flutter run -d web-server --web-port=3000 --web-hostname=localhost'], { stdio: 'pipe' });
    app.stdout.on('data', (data) => {
        if (data.toString().includes('localhost:3000')) {
            console.log('✅ Customer App is ready.');
        }
    });

    // Start Admin (Web Server Mode)
    console.log('⚙️ Initializing Admin Panel (3001)...');
    const admin = spawn('cmd.exe', ['/c', 'cd wayfarer_admin && flutter run -d web-server --web-port=3001 --web-hostname=localhost'], { stdio: 'pipe' });
    admin.stdout.on('data', (data) => {
        if (data.toString().includes('localhost:3001')) {
            console.log('✅ Admin Panel is ready.');
        }
    });

    // Wait for both to be accessible
    await Promise.all([
        waitForPort(3000),
        waitForPort(3001)
    ]);

    // Use 'start' to launch default browser. Windows will group these if it's the same browser.
    exec('start "" "http://localhost:3000"');
    setTimeout(() => {
        exec('start "" "http://localhost:3001"');
    }, 500);

    console.log('\n✨ ALL SYSTEMS GO!');
    console.log('------------------------------------------');
    console.log('App:   http://localhost:3000');
    console.log('Admin: http://localhost:3001');
    console.log('API:   http://localhost:5000');
    console.log('------------------------------------------\n');

    // Handle process termination
    const cleanup = () => {
        console.log('\n🛑 Shutting down all services...');
        backend.kill();
        app.kill();
        admin.kill();
        process.exit();
    };

    process.on('SIGINT', cleanup);
    process.on('SIGTERM', cleanup);

    // Keep the process alive
    setInterval(() => {}, 1000);
}

start();
