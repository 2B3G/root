const { spawn } = require('child_process');

const command = 'bash';
const args = ['root/noninteractive.sh'];

// Spawn the process
const process = spawn(command, args, { stdio: 'pipe' }); // Use 'pipe' to enable interaction with stdin

// Log standard output
process.stdout.on('data', (data) => {
    console.log(`STDOUT: ${data.toString()}`);

    // When entered root
    if(data.toString().includes("Mission")){
        process.stdin.write('apt update -y\n');
        process.stdin.write('apt install curl -y\n');
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
