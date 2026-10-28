import { spawn, spawnSync } from 'child_process';
import { platform } from 'os';
import { resolve } from 'path';

/**
 * Levanta TODO el entorno de desarrollo en un solo comando:
 *   1. PostgreSQL (contenedor Docker)
 *   2. Backend  -> Spring Boot en http://localhost:8080
 *   3. Frontend -> Vite dev server en http://localhost:5173 (proxy /api -> :8080)
 *
 * Los procesos del backend y el frontend se ejecutan en paralelo y se
 * detienen todos juntos al pulsar Ctrl+C.
 */

const isWindows = platform() === 'win32';
const rootDir = resolve(import.meta.dirname, '..');

// Colores ANSI (se desactivan en Windows para no ensuciar la consola).
const colors = isWindows
  ? { backend: '', frontend: '', db: '', reset: '' }
  : { backend: '\x1b[36m', frontend: '\x1b[35m', db: '\x1b[33m', reset: '\x1b[0m' };

function log(prefix, color, message) {
  process.stdout.write(`${color}[${prefix}]${colors.reset} ${message}\n`);
}

/**
 * Ejecuta un comando de forma síncrona y hereda la salida.
 */
function runSync(command, args, label) {
  log(label, colors.db, `> ${command} ${args.join(' ')}`);
  const result = spawnSync(command, args, { cwd: rootDir, stdio: 'inherit', shell: isWindows });
  if (result.status !== 0) {
    log(label, colors.db, `El comando terminó con código ${result.status}`);
    process.exit(result.status ?? 1);
  }
}

/**
 * Lanza un proceso hijo en segundo plano, prefijando cada línea de su salida.
 *
 * Se lanza en su propio grupo de procesos (detached) para poder matar luego
 * a todo el árbol (por ejemplo: mvn -> java, o pnpm -> vite) de una sola vez.
 */
function runConcurrently(prefix, color, command, args) {
  const child = spawn(command, args, {
    cwd: rootDir,
    shell: isWindows,
    detached: !isWindows,
    env: { ...process.env, FORCE_COLOR: '1' }
  });

  const prefixLines = (stream) => {
    stream.setEncoding('utf8');
    let buffer = '';
    stream.on('data', (chunk) => {
      buffer += chunk;
      const lines = buffer.split('\n');
      buffer = lines.pop() ?? '';
      for (const line of lines) {
        log(prefix, color, line);
      }
    });
    stream.on('end', () => {
      if (buffer.length > 0) {
        log(prefix, color, buffer);
      }
    });
  };

  prefixLines(child.stdout);
  prefixLines(child.stderr);

  child.on('exit', (code) => {
    log(prefix, color, `El proceso terminó con código ${code}`);
  });

  return child;
}

// ---------------------------------------------------------------------------
// 1. Base de datos
// ---------------------------------------------------------------------------
log('db', colors.db, 'Iniciando PostgreSQL...');
runSync('node', ['scripts/db-cli.js', 'start'], 'db');

// ---------------------------------------------------------------------------
// 2. Backend + Frontend en paralelo
// ---------------------------------------------------------------------------
log('app', colors.db, 'Levantando backend (8080) y frontend (5173) en paralelo...');
log('app', colors.db, 'Pulsa Ctrl+C para detener todo.');

const children = [
  runConcurrently('backend', colors.backend, 'mvn', ['-f', 'backend/pom.xml', 'spring-boot:run']),
  runConcurrently('frontend', colors.frontend, 'pnpm', ['--dir', 'frontend', 'dev'])
];

let shuttingDown = false;

/**
 * Mata un proceso hijo y todo su árbol.
 * En Unix se mata el grupo de procesos completo (pid negativo).
 */
function killTree(child, signal) {
  if (child.killed || child.exitCode !== null) {
    return;
  }
  try {
    if (isWindows) {
      spawnSync('taskkill', ['/pid', String(child.pid), '/T', '/F'], { stdio: 'ignore' });
    } else {
      process.kill(-child.pid, signal);
    }
  } catch {
    // El proceso ya no existe: lo ignoramos.
  }
}

function shutdown(signal) {
  if (shuttingDown) {
    return;
  }
  shuttingDown = true;
  log('app', colors.db, `Recibida señal ${signal}. Deteniendo backend y frontend...`);
  for (const child of children) {
    killTree(child, signal === 'SIGINT' ? 'SIGINT' : 'SIGTERM');
  }
  // Dar un margen y salir.
  setTimeout(() => process.exit(0), 1500);
}

process.on('SIGINT', () => shutdown('SIGINT'));
process.on('SIGTERM', () => shutdown('SIGTERM'));

// Si cualquiera de los dos procesos muere, apagamos el otro.
for (const child of children) {
  child.on('exit', () => {
    if (!shuttingDown) {
      shutdown('SIGTERM');
    }
  });
}
