@echo off
REM Script de gestión de base de datos PostgreSQL para Windows
REM Uso: scripts\db-manage.bat [start|stop|create|drop|reset|status]

setlocal enabledelayedexpansion

set POSTGRES_USER=prueba_user
set POSTGRES_PASSWORD=prueba_password
set POSTGRES_DB=prueba_db
set POSTGRES_HOST=localhost
set POSTGRES_PORT=5433
set CONTAINER_NAME=prueba-symplifica-postgres

REM Verificar si se proporcionó un comando
if "%1"=="" (
    set COMMAND=status
) else (
    set COMMAND=%1
)

REM Comprobar si Docker está disponible
docker --version >nul 2>&1
if errorlevel 1 (
    echo.
    echo [ERROR] Docker no está instalado o no está en el PATH
    echo.
    exit /b 1
)

goto %COMMAND%

REM ---------------------------------------------------------------------------
REM Comprueba si el contenedor está en ejecución.
REM OJO: 'docker ps -q' devuelve código 0 aunque no encuentre nada, por lo que
REM hay que comprobar que la SALIDA no esté vacía (no el errorlevel).
REM ---------------------------------------------------------------------------
:is_running
    set "RUNNING_ID="
    for /f "delims=" %%i in ('docker ps --filter "name=^/%CONTAINER_NAME%$" --filter "status=running" -q 2^>nul') do set "RUNNING_ID=%%i"
    if defined RUNNING_ID (exit /b 0) else (exit /b 1)

REM Comprueba si el contenedor existe (en cualquier estado).
:exists
    set "EXISTS_ID="
    for /f "delims=" %%i in ('docker ps -a --filter "name=^/%CONTAINER_NAME%$" -q 2^>nul') do set "EXISTS_ID=%%i"
    if defined EXISTS_ID (exit /b 0) else (exit /b 1)

:start
    echo.
    echo [INFO] Iniciando PostgreSQL...
    echo.
    
    call :is_running
    if not errorlevel 1 (
        echo [ADVERTENCIA] PostgreSQL ya está corriendo en el puerto %POSTGRES_PORT%
        exit /b 0
    )
    
    call :exists
    if not errorlevel 1 (
        echo [INFO] Iniciando contenedor existente...
        docker start %CONTAINER_NAME% >nul 2>&1
    ) else (
        echo [INFO] Iniciando nuevo contenedor...
        docker-compose up -d postgres
    )
    
    echo [INFO] Esperando a que PostgreSQL esté listo...
    timeout /t 2 /nobreak >nul 2>&1
    
    for /L %%i in (1,1,30) do (
        docker exec %CONTAINER_NAME% pg_isready -U %POSTGRES_USER% -d %POSTGRES_DB% >nul 2>&1
        if not errorlevel 1 (
            echo.
            echo [OK] PostgreSQL está listo en localhost:%POSTGRES_PORT%
            echo.
            exit /b 0
        )
        set /p "=." <nul
        timeout /t 1 /nobreak >nul 2>&1
    )
    
    echo.
    echo [ERROR] PostgreSQL no respondió después de esperar
    echo.
    exit /b 1

:stop
    echo.
    echo [INFO] Deteniendo PostgreSQL...
    echo.
    
    call :is_running
    if not errorlevel 1 (
        docker stop %CONTAINER_NAME% >nul 2>&1
        echo [OK] PostgreSQL detenido
    ) else (
        echo [ADVERTENCIA] PostgreSQL no está corriendo
    )
    echo.
    exit /b 0

:create
    echo.
    echo [INFO] Creando base de datos...
    echo.
    
    call :is_running
    if errorlevel 1 (
        echo [INFO] PostgreSQL no está corriendo, iniciando...
        call :start
    )
    
    REM Verificar si la base existe; si no, crearla (necesario tras un reset).
    docker exec %CONTAINER_NAME% psql -U %POSTGRES_USER% -d postgres -tc "SELECT 1 FROM pg_database WHERE datname = '%POSTGRES_DB%'" 2>nul | findstr /C:"1" >nul 2>&1
    if errorlevel 1 (
        docker exec %CONTAINER_NAME% psql -U %POSTGRES_USER% -d postgres -c "CREATE DATABASE %POSTGRES_DB%" >nul 2>&1
        echo [INFO] Base de datos '%POSTGRES_DB%' creada
    ) else (
        echo [INFO] La base de datos '%POSTGRES_DB%' ya existe
    )

    REM Asegurar extensiones tras un reset.
    docker exec %CONTAINER_NAME% psql -U %POSTGRES_USER% -d %POSTGRES_DB% -c "CREATE EXTENSION IF NOT EXISTS \"uuid-ossp\"; CREATE EXTENSION IF NOT EXISTS pgcrypto;" >nul 2>&1

    docker exec %CONTAINER_NAME% psql -U %POSTGRES_USER% -d %POSTGRES_DB% -c "SELECT 1" >nul 2>&1
    if not errorlevel 1 (
        echo [OK] Base de datos '%POSTGRES_DB%' está lista
    ) else (
        echo [ERROR] No se pudo verificar la base de datos
        exit /b 1
    )
    echo.
    exit /b 0

:drop
    echo.
    echo [ADVERTENCIA] Esto eliminará la base de datos '%POSTGRES_DB%' y todos sus datos
    echo.
    set /p confirmation="Estás seguro? (escribe 'si' para confirmar): "
    
    if not "!confirmation!"=="si" (
        echo [INFO] Operación cancelada
        echo.
        exit /b 0
    )
    
    echo.
    echo [INFO] Eliminando base de datos...
    echo.
    
    call :is_running
    if not errorlevel 1 (
        REM Conectar a la base de mantenimiento 'postgres', no a la que vamos a borrar.
        docker exec %CONTAINER_NAME% psql -U %POSTGRES_USER% -d postgres -c "DROP DATABASE IF EXISTS %POSTGRES_DB%;" >nul 2>&1
        echo [OK] Base de datos eliminada
    ) else (
        echo [ADVERTENCIA] PostgreSQL no está corriendo. No se puede eliminar la base de datos
        exit /b 1
    )
    echo.
    exit /b 0

:reset
    echo.
    echo [INFO] Reseteando base de datos...
    echo.
    
    call :drop
    if errorlevel 1 exit /b 1
    
    timeout /t 1 /nobreak >nul 2>&1
    call :create
    
    echo [OK] Base de datos reseteada
    echo.
    exit /b 0

:status
    echo.
    echo [INFO] Estado de PostgreSQL:
    echo.
    
    call :is_running
    if not errorlevel 1 (
        echo [OK] PostgreSQL está corriendo
        echo   Puerto: %POSTGRES_PORT%
        echo   Usuario: %POSTGRES_USER%
        echo   Base de datos: %POSTGRES_DB%
        echo.
        echo   Información del contenedor:
        docker ps --filter "name=%CONTAINER_NAME%" --format "table {{.ID}}\t{{.Image}}\t{{.Status}}"
    ) else (
        echo [ADVERTENCIA] PostgreSQL no está corriendo
    )
    echo.
    exit /b 0

:unknown
    echo.
    echo [ERROR] Comando no reconocido: %1
    echo.
    echo Uso: scripts\db-manage.bat [start^|stop^|create^|drop^|reset^|status]
    echo.
    echo Comandos:
    echo   start   - Inicia PostgreSQL
    echo   stop    - Detiene PostgreSQL
    echo   create  - Crea la base de datos
    echo   drop    - Elimina la base de datos
    echo   reset   - Elimina y recrea la base de datos
    echo   status  - Muestra el estado de PostgreSQL
    echo.
    exit /b 1

endlocal
