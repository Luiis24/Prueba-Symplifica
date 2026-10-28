import { execSync } from 'child_process';
import { platform } from 'os';

const currentPlatform = platform();
const isWindows = currentPlatform === 'win32';
const isMac = currentPlatform === 'darwin';
const isLinux = currentPlatform === 'linux';

/**
 * Ejecuta un comando según el SO
 */
function runCommand(command, shell = false) {
  try {
    const options = {
      encoding: 'utf8',
      stdio: ['pipe', 'pipe', 'pipe']
    };
    
    if (isWindows && shell) {
      return execSync(command, { ...options, shell: true });
    }
    return execSync(command, options);
  } catch (error) {
    throw new Error(error.stderr || error.stdout || error.message);
  }
}

/**
 * Valida que Docker está corriendo
 */
function validateDocker() {
  try {
    // Primero obtener la versión
    let versionOutput = '';
    try {
      versionOutput = runCommand('docker --version', true);
    } catch {
      throw new Error('Docker no está instalado o no está en el PATH');
    }

    // Luego verificar que está corriendo
    try {
      runCommand('docker ps', true);
    } catch {
      throw new Error('Docker no está corriendo. Inicia Docker Desktop o el daemon de Docker');
    }

    return {
      passed: true,
      message: versionOutput.trim()
    };
  } catch (error) {
    return {
      passed: false,
      message: error.message
    };
  }
}

/**
 * Valida que Node.js es versión 24
 */
function validateNode() {
  try {
    const output = runCommand('node --version', true).trim();
    const version = output.replace('v', '').split('.')[0];
    
    if (version !== '24') {
      throw new Error(`Se esperaba Node.js 24, pero se encontró ${version}`);
    }

    return {
      passed: true,
      message: output
    };
  } catch (error) {
    return {
      passed: false,
      message: error.message
    };
  }
}

/**
 * Valida que Java es versión 25
 */
function validateJava() {
  try {
    let output = '';
    try {
      // En algunos sistemas java -version escribe a stderr
      output = runCommand('java -version 2>&1', true);
    } catch (error) {
      // Si falla, intenta con solo stdout
      try {
        output = runCommand('java -version', true);
      } catch {
        throw new Error('Java no está instalado o no está en el PATH');
      }
    }

    const match = output.match(/version ["']?(\d+)/);
    if (!match || match[1] !== '25') {
      const foundVersion = match ? match[1] : 'desconocida';
      throw new Error(`Se esperaba Java 25, pero se encontró versión ${foundVersion}`);
    }

    return {
      passed: true,
      message: output.split('\n')[0].trim()
    };
  } catch (error) {
    return {
      passed: false,
      message: error.message
    };
  }
}

/**
 * Valida que Maven está instalado
 */
function validateMaven() {
  try {
    const output = runCommand('mvn --version', true).trim();
    
    if (!output.includes('Apache Maven')) {
      throw new Error('Maven no parece estar correctamente instalado');
    }

    return {
      passed: true,
      message: output.split('\n')[0].trim()
    };
  } catch (error) {
    return {
      passed: false,
      message: error.message
    };
  }
}

/**
 * Ejecuta todas las validaciones
 */
function main() {
  const validations = [
    { name: 'Docker', validate: validateDocker },
    { name: 'Node.js', validate: validateNode },
    { name: 'Java', validate: validateJava },
    { name: 'Maven', validate: validateMaven }
  ];

  console.log('\n🔍 Validando dependencias del proyecto...');
  console.log(`   Sistema operativo: ${currentPlatform === 'win32' ? 'Windows' : currentPlatform === 'darwin' ? 'macOS' : 'Linux'}\n`);

  let allPassed = true;
  const results = [];

  for (const validation of validations) {
    const result = validation.validate();
    
    if (result.passed) {
      console.log(`✅ ${validation.name}: ${result.message}`);
    } else {
      console.log(`❌ ${validation.name}: ${result.message}`);
      allPassed = false;
    }
    
    results.push({ name: validation.name, ...result });
  }

  console.log('');

  if (allPassed) {
    console.log('✨ ¡Todas las dependencias están correctamente configuradas!\n');
    process.exit(0);
  } else {
    console.log('⚠️  Por favor, instala o actualiza las dependencias faltantes.\n');
    console.log('📋 Requisitos:');
    console.log('   - Node.js v24.x (https://nodejs.org)');
    console.log('   - Java 25 (https://www.oracle.com/java/technologies/downloads/)');
    console.log('   - Maven 3.9+ (https://maven.apache.org/download.cgi)');
    console.log('   - Docker (https://www.docker.com/products/docker-desktop)\n');
    process.exit(1);
  }
}

main();
