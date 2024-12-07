const { spawn } = require('child_process');

const command = 'bash';
const args = ['root.sh'];

// Spawn the process
const process = spawn(command, args, { stdio: 'pipe' }); // Use 'pipe' to enable interaction with stdin

// Log standard output
process.stdout.on('data', (data) => {
    console.log(`STDOUT: ${data.toString()}`);

    // When entered root
    if(data.toString().includes("Mission")){
        process.stdin.write('apk update\n');
        process.stdin.write('sudo tar -xvzf ./ngrok-v3-stable-linux-amd64.tgz -C /usr/local/bin\n');
        process.stdin.write('apk add curl\n');
        process.stdin.write('curl -sSf https://sshx.io/get | sh\n');
    }
});

// Log standard error
process.stderr.on('data', (data) => {
    console.error(`STDERR: ${data.toString()}`);
});

// Handle process exit
process.on('close', (code) => {
    console.log(`Process exited with code: ${code}`);
});
