-- Script de inicialización de la base de datos
-- Este script se ejecuta automáticamente cuando se inicia el contenedor de PostgreSQL

-- Crear extensiones útiles
-- Nota: los nombres de extensión con guiones deben ir entre comillas dobles,
-- de lo contrario PostgreSQL lanza "syntax error at or near -".
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Crear esquemas (opcional)
CREATE SCHEMA IF NOT EXISTS public;

-- Los comentarios aquí indican dónde agregar tu lógica específica
-- Por ejemplo, crear tablas, índices, etc.

-- Ejemplo de tabla (descomenta para usar):
-- CREATE TABLE usuarios (
--   id SERIAL PRIMARY KEY,
--   nombre VARCHAR(255) NOT NULL,
--   email VARCHAR(255) UNIQUE NOT NULL,
--   created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
-- );

GRANT ALL PRIVILEGES ON SCHEMA public TO prueba_user;
