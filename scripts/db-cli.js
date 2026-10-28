import { execSync, spawnSync } from 'child_process';
import { platform } from 'os';
import { resolve } from 'path';

const currentPlatform = platform();
const isWindows = currentPlatform === 'win32';

const command = process.argv[2] || 'status';

// Ruta del script
const scriptPath = isWindows 
  ? resolve('./scripts/db-manage.bat')
  : resolve('./scripts/db-manage.sh');

console.log('');

try {
  if (isWindows) {
    // En Windows, ejecutar el batch
    const result = spawnSync('cmd.exe', ['/c', `"${scriptPath}" ${command}`], {
      stdio: 'inherit',
      shell: true
    });
    
    process.exit(result.status || 0);
  } else {
    // En Linux/macOS, ejecutar el shell script
    const result = spawnSync('bash', [scriptPath, command], {
      stdio: 'inherit'
    });
    
    process.exit(result.status || 0);
  }
} catch (error) {
  console.error('❌ Error al ejecutar el comando:', error.message);
  process.exit(1);
}
