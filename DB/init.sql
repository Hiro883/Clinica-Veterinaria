-- =============================================================================
-- BASE DE DATOS: CLINICA VETERINARIA (MySQL / MariaDB)
-- BASADA EN REQUERIMIENTOS FUNCIONALES (RF01 - RF12)
-- =============================================================================

CREATE DATABASE IF NOT EXISTS clinica_veterinaria;
USE clinica_veterinaria;

-- 1. TABLA: USUARIOS (RF01 - Iniciar Sesión)
CREATE TABLE usuarios (
    id_usuario INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    correo VARCHAR(150) NOT NULL UNIQUE,
    usuario VARCHAR(50) NOT NULL UNIQUE,
    contrasena VARCHAR(255) NOT NULL, -- Se debe almacenar el hash encriptado (RNF03)
    rol ENUM('administrador', 'veterinario') NOT NULL,
    activo BOOLEAN DEFAULT TRUE,
    fecha_creacion DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- 2. TABLA: VETERINARIOS (RF09 - Gestionar Veterinarios)
CREATE TABLE veterinarios (
    id_veterinario INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT NOT NULL UNIQUE,
    especialidad VARCHAR(100) NOT NULL,
    telefono VARCHAR(20) NOT NULL,
    licencia_medica VARCHAR(50),
    CONSTRAINT fk_veterinario_usuario FOREIGN KEY (id_usuario) 
        REFERENCES usuarios(id_usuario) ON DELETE CASCADE
) ENGINE=InnoDB;

-- 3. TABLA: PROPIETARIOS (RF02, RF12 - Registrar y Gestionar Propietarios)
CREATE TABLE propietarios (
    id_propietario INT AUTO_INCREMENT PRIMARY KEY,
    nombre_completo VARCHAR(150) NOT NULL,
    direccion TEXT NOT NULL,
    telefono VARCHAR(20) NOT NULL,
    correo VARCHAR(150) UNIQUE,
    fecha_registro DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- 4. TABLA: MASCOTAS (RF03, RF12 - Registrar y Gestionar Mascotas)
CREATE TABLE mascotas (
    id_mascota INT AUTO_INCREMENT PRIMARY KEY,
    id_propietario INT NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    especie VARCHAR(50) NOT NULL,
    raza VARCHAR(50) NOT NULL,
    sexo ENUM('Macho', 'Hembra') NOT NULL,
    fecha_nacimiento DATE,
    caracteristicas_relevantes TEXT,
    fecha_registro DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_mascota_propietario FOREIGN KEY (id_propietario) 
        REFERENCES propietarios(id_propietario) ON DELETE CASCADE
) ENGINE=InnoDB;

-- 5. TABLA: SERVICIOS (RF10 - Gestionar Servicios)
CREATE TABLE servicios (
    id_servicio INT AUTO_INCREMENT PRIMARY KEY,
    nombre_servicio VARCHAR(100) NOT NULL UNIQUE,
    descripcion TEXT,
    duracion_estimada_min INT NOT NULL,
    activo BOOLEAN DEFAULT TRUE
) ENGINE=InnoDB;

-- 6. TABLA: HORARIOS DE ATENCIÓN (RF11 - Gestionar Horarios de Atención)
CREATE TABLE horarios_atencion (
    id_horario INT AUTO_INCREMENT PRIMARY KEY,
    id_veterinario INT NOT NULL,
    dia_semana INT NOT NULL CHECK (dia_semana BETWEEN 1 AND 7), -- 1: Lunes, 7: Domingo
    hora_inicio TIME NOT NULL,
    hora_fin TIME NOT NULL,
    CONSTRAINT fk_horario_veterinario FOREIGN KEY (id_veterinario) 
        REFERENCES veterinarios(id_veterinario) ON DELETE CASCADE,
    CONSTRAINT chk_rango_horas CHECK (hora_inicio < hora_fin)
) ENGINE=InnoDB;

-- 7. TABLA: CITAS (RF04, RF05, RF08 - Agendar, Cancelar y Consultar Citas)
CREATE TABLE citas (
    id_cita INT AUTO_INCREMENT PRIMARY KEY,
    id_mascota INT NOT NULL,
    id_veterinario INT NOT NULL,
    id_servicio INT NOT NULL,
    fecha_cita DATE NOT NULL,
    hora_cita TIME NOT NULL,
    estado ENUM('Programada', 'Atendida', 'Cancelada') DEFAULT 'Programada',
    motivo_cancelacion TEXT,
    fecha_creacion DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_cita_mascota FOREIGN KEY (id_mascota) 
        REFERENCES mascotas(id_mascota) ON DELETE RESTRICT,
    CONSTRAINT fk_cita_veterinario FOREIGN KEY (id_veterinario) 
        REFERENCES veterinarios(id_veterinario) ON DELETE RESTRICT,
    CONSTRAINT fk_cita_servicio FOREIGN KEY (id_servicio) 
        REFERENCES servicios(id_servicio) ON DELETE RESTRICT
) ENGINE=InnoDB;

-- 8. TABLA: CONSULTAS VETERINARIAS (RF06, RF07 - Registrar y Consultar Historial Clínico)
CREATE TABLE consultas_veterinarias (
    id_consulta INT AUTO_INCREMENT PRIMARY KEY,
    id_cita INT NOT NULL UNIQUE,
    id_mascota INT NOT NULL,
    id_veterinario INT NOT NULL,
    fecha_atencion DATETIME DEFAULT CURRENT_TIMESTAMP,
    diagnostico TEXT NOT NULL,
    observaciones TEXT,
    tratamiento TEXT NOT NULL,
    servicios_adicionales TEXT,
    CONSTRAINT fk_consulta_cita FOREIGN KEY (id_cita) 
        REFERENCES citas(id_cita) ON DELETE RESTRICT,
    CONSTRAINT fk_consulta_mascota FOREIGN KEY (id_mascota) 
        REFERENCES mascotas(id_mascota) ON DELETE RESTRICT,
    CONSTRAINT fk_consulta_veterinario FOREIGN KEY (id_veterinario) 
        REFERENCES veterinarios(id_veterinario) ON DELETE RESTRICT
) ENGINE=InnoDB;

-- =============================================================================
-- ÍNDICES DE OPTIMIZACIÓN (RNF02)
-- =============================================================================
CREATE INDEX idx_citas_busqueda ON citas(fecha_cita, id_veterinario, estado);
CREATE INDEX idx_historial_mascota ON consultas_veterinarias(id_mascota, fecha_atencion DESC);
CREATE INDEX idx_mascota_propietario ON mascotas(id_propietario);

-- =============================================================================
-- DATOS INICIALES DE PRUEBA
-- =============================================================================
INSERT INTO usuarios (nombre, correo, usuario, contrasena, rol) VALUES 
('Carlos Administrador', 'admin@veterinaria.com', 'admin', '$2b$10$e8Z9xG...', 'administrador'),
('Dra. Maria Lopez', 'mlopez@veterinaria.com', 'mlopez', '$2b$10$k1A2bC...', 'veterinario');

INSERT INTO veterinarios (id_usuario, especialidad, telefono, licencia_medica) VALUES 
(2, 'Medicina General y Cirugía', '7890-1234', 'VET-2026-88');

INSERT INTO servicios (nombre_servicio, descripcion, duracion_estimada_min) VALUES 
('Consulta General', 'Evaluación médica básica de la mascota', 30),
('Vacunación', 'Aplicación de esquemas de vacunas', 15),
('Cirugía Mayor', 'Procedimientos quirúrgicos complejos', 120);

INSERT INTO horarios_atencion (id_veterinario, dia_semana, hora_inicio, hora_fin) VALUES 
(1, 1, '08:00:00', '16:00:00'),
(1, 2, '08:00:00', '16:00:00');