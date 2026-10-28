#!/bin/bash

# Script de gestión de base de datos PostgreSQL
# Uso: ./scripts/db-manage.sh [start|stop|create|drop|reset|status]

set -e

POSTGRES_USER="prueba_user"
POSTGRES_PASSWORD="prueba_password"
POSTGRES_DB="prueba_db"
POSTGRES_HOST="localhost"
POSTGRES_PORT="5433"
CONTAINER_NAME="prueba-symplifica-postgres"

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para imprimir mensajes
print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# Función para verificar si Docker está corriendo
check_docker() {
    if ! command -v docker &> /dev/null; then
        print_error "Docker no está instalado"
        exit 1
    fi
}

# Devuelve 0 si el contenedor existe (en cualquier estado)
container_exists() {
    [ -n "$(docker ps -a --filter "name=^/${CONTAINER_NAME}$" -q)" ]
}

# Devuelve 0 si el contenedor está en ejecución.
# Importante: 'docker ps -q' sale con código 0 aunque no encuentre nada, así que
# hay que comprobar que la salida no esté vacía en lugar del código de salida.
container_running() {
    [ -n "$(docker ps --filter "name=^/${CONTAINER_NAME}$" --filter "status=running" -q)" ]
}

# Función para iniciar PostgreSQL
start_postgres() {
    check_docker
    
    print_info "Iniciando PostgreSQL..."
    
    if container_running; then
        print_warning "PostgreSQL ya está corriendo en el puerto $POSTGRES_PORT"
        return 0
    fi
    
    if container_exists; then
        print_info "Iniciando contenedor existente..."
        docker start $CONTAINER_NAME > /dev/null
    else
        print_info "Iniciando nuevo contenedor..."
        docker-compose up -d postgres
    fi
    
    # Esperar a que PostgreSQL esté listo
    print_info "Esperando a que PostgreSQL esté listo..."
    sleep 2
    
    # Verificar conexión
    for i in {1..30}; do
        if docker exec $CONTAINER_NAME pg_isready -U $POSTGRES_USER -d $POSTGRES_DB &> /dev/null; then
            print_success "PostgreSQL está listo en localhost:$POSTGRES_PORT"
            return 0
        fi
        echo -n "."
        sleep 1
    done
    
    print_error "PostgreSQL no respondió después de esperar"
    exit 1
}

# Función para detener PostgreSQL
stop_postgres() {
    check_docker
    
    print_info "Deteniendo PostgreSQL..."
    
    if container_running; then
        docker stop $CONTAINER_NAME > /dev/null
        print_success "PostgreSQL detenido"
    else
        print_warning "PostgreSQL no está corriendo"
    fi
}

# Función para crear la base de datos
create_database() {
    check_docker
    
    print_info "Creando base de datos..."
    
    if ! container_running; then
        print_info "PostgreSQL no está corriendo, iniciando..."
        start_postgres
    fi
    
    # Verificar si la base de datos existe; si no, crearla.
    if docker exec $CONTAINER_NAME psql -U $POSTGRES_USER -d postgres -tc "SELECT 1 FROM pg_database WHERE datname = '$POSTGRES_DB'" | grep -q 1; then
        print_info "La base de datos '$POSTGRES_DB' ya existe"
    else
        docker exec $CONTAINER_NAME psql -U $POSTGRES_USER -d postgres -c "CREATE DATABASE $POSTGRES_DB" > /dev/null
        print_info "Base de datos '$POSTGRES_DB' creada"
    fi

    # Asegurar extensiones (necesario tras un reset, ya que CREATE DATABASE
    # no ejecuta los scripts de inicialización del contenedor).
    docker exec $CONTAINER_NAME psql -U $POSTGRES_USER -d $POSTGRES_DB -c \
        'CREATE EXTENSION IF NOT EXISTS "uuid-ossp"; CREATE EXTENSION IF NOT EXISTS pgcrypto;' > /dev/null 2>&1 || true

    if docker exec $CONTAINER_NAME psql -U $POSTGRES_USER -d $POSTGRES_DB -c "SELECT 1" &> /dev/null; then
        print_success "Base de datos '$POSTGRES_DB' está lista"
    else
        print_error "No se pudo verificar la base de datos"
        exit 1
    fi
}

# Función para eliminar la base de datos
drop_database() {
    check_docker
    
    print_warning "Esto eliminará la base de datos '$POSTGRES_DB' y todos sus datos"
    read -p "¿Estás seguro? (escribe 'si' para confirmar): " confirmation
    
    if [ "$confirmation" != "si" ]; then
        print_info "Operación cancelada"
        exit 0
    fi
    
    print_info "Eliminando base de datos..."
    
    if container_running; then
        # Conectar a la base de mantenimiento 'postgres' (no a prueba_db, que es
        # justo la que vamos a eliminar).
        docker exec $CONTAINER_NAME psql -U $POSTGRES_USER -d postgres -tc "SELECT 1 FROM pg_database WHERE datname = '$POSTGRES_DB'" | grep -q 1 && \
        docker exec $CONTAINER_NAME psql -U $POSTGRES_USER -d postgres -c "DROP DATABASE IF EXISTS $POSTGRES_DB;" || true
        print_success "Base de datos eliminada"
    else
        print_warning "PostgreSQL no está corriendo. No se puede eliminar la base de datos"
        exit 1
    fi
}

# Función para mostrar el estado
show_status() {
    check_docker
    
    print_info "Estado de PostgreSQL:"
    echo ""
    
    if container_running; then
        print_success "PostgreSQL está corriendo"
        echo "  Puerto: $POSTGRES_PORT"
        echo "  Usuario: $POSTGRES_USER"
        echo "  Base de datos: $POSTGRES_DB"
        echo ""
        
        # Mostrar información del contenedor
        echo "  Información del contenedor:"
        docker ps --filter "name=$CONTAINER_NAME" --format "table {{.ID}}\t{{.Image}}\t{{.Status}}"
    else
        print_warning "PostgreSQL no está corriendo"
    fi
}

# Main
case "${1:-status}" in
    start)
        start_postgres
        ;;
    stop)
        stop_postgres
        ;;
    create)
        create_database
        ;;
    drop)
        drop_database
        ;;
    reset)
        print_info "Reseteando base de datos..."
        drop_database
        sleep 1
        create_database
        print_success "Base de datos reseteada"
        ;;
    status)
        show_status
        ;;
    *)
        print_error "Comando no reconocido: $1"
        echo ""
        echo "Uso: $0 {start|stop|create|drop|reset|status}"
        echo ""
        echo "Comandos:"
        echo "  start   - Inicia PostgreSQL"
        echo "  stop    - Detiene PostgreSQL"
        echo "  create  - Crea la base de datos"
        echo "  drop    - Elimina la base de datos"
        echo "  reset   - Elimina y recrea la base de datos"
        echo "  status  - Muestra el estado de PostgreSQL"
        exit 1
        ;;
esac
