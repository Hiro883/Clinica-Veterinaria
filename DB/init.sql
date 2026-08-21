CREATE DATABASE IF NOT EXISTS clinica_veterinaria;
USE clinica_veterinaria;

-- 1. Tabla de Roles
CREATE TABLE IF NOT EXISTS roles (
    id_rol INT AUTO_INCREMENT PRIMARY KEY,
    nombre_rol VARCHAR(50) UNIQUE NOT NULL
);

INSERT INTO roles (id_rol, nombre_rol) VALUES 
(1, 'Administrador'),
(2, 'Veterinario'),
(3, 'Propietario')
ON DUPLICATE KEY UPDATE nombre_rol=VALUES(nombre_rol);

-- 2. Tabla de Propietarios
CREATE TABLE IF NOT EXISTS propietarios (
    id_propietario INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    telefono VARCHAR(20),
    email VARCHAR(150) UNIQUE NOT NULL,
    direccion TEXT
);

-- 3. Tabla de Veterinarios
CREATE TABLE IF NOT EXISTS veterinarios (
    id_veterinario INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    especialidad VARCHAR(100),
    telefono VARCHAR(20),
    email VARCHAR(150) UNIQUE NOT NULL
);

-- 4. Tabla de Usuarios
CREATE TABLE IF NOT EXISTS usuarios (
    id_usuario INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(150) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    id_rol INT NOT NULL,
    estado ENUM('Activo', 'Inactivo') DEFAULT 'Activo',
    id_propietario INT DEFAULT NULL,
    id_veterinario INT DEFAULT NULL,
    fecha_creacion DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_rol) REFERENCES roles(id_rol),
    FOREIGN KEY (id_propietario) REFERENCES propietarios(id_propietario) ON DELETE CASCADE,
    FOREIGN KEY (id_veterinario) REFERENCES veterinarios(id_veterinario) ON DELETE CASCADE
);

-- 5. Tabla de Mascotas
CREATE TABLE IF NOT EXISTS mascotas (
    id_mascota INT AUTO_INCREMENT PRIMARY KEY,
    id_propietario INT NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    especie VARCHAR(50) NOT NULL,
    raza VARCHAR(50),
    sexo ENUM('Macho', 'Hembra') NOT NULL,
    fecha_nacimiento DATE,
    caracteristicas TEXT,
    FOREIGN KEY (id_propietario) REFERENCES propietarios(id_propietario) ON DELETE CASCADE
);

-- 6. Tabla de Servicios
CREATE TABLE IF NOT EXISTS servicios (
    id_servicio INT AUTO_INCREMENT PRIMARY KEY,
    nombre_servicio VARCHAR(100) NOT NULL,
    descripcion TEXT,
    precio DECIMAL(10,2) NOT NULL
);

-- 7. Tabla de Horarios Disponibles
CREATE TABLE IF NOT EXISTS horarios_disponibles (
    id_horario INT AUTO_INCREMENT PRIMARY KEY,
    id_veterinario INT NOT NULL,
    fecha DATE NOT NULL,
    hora_inicio TIME NOT NULL,
    hora_fin TIME NOT NULL,
    estado ENUM('Disponible', 'Reservado', 'No Disponible') DEFAULT 'Disponible',
    FOREIGN KEY (id_veterinario) REFERENCES veterinarios(id_veterinario) ON DELETE CASCADE
);

-- 8. Tabla de Citas
CREATE TABLE IF NOT EXISTS citas (
    id_cita INT AUTO_INCREMENT PRIMARY KEY,
    id_mascota INT NOT NULL,
    id_veterinario INT NOT NULL,
    id_servicio INT NOT NULL,
    fecha_hora DATETIME NOT NULL,
    estado ENUM('Programada', 'Atendida', 'Cancelada') DEFAULT 'Programada',
    FOREIGN KEY (id_mascota) REFERENCES mascotas(id_mascota) ON DELETE CASCADE,
    FOREIGN KEY (id_veterinario) REFERENCES veterinarios(id_veterinario) ON DELETE CASCADE,
    FOREIGN KEY (id_servicio) REFERENCES servicios(id_servicio) ON DELETE CASCADE
);

-- 9. Tabla de Consultas
CREATE TABLE IF NOT EXISTS consultas (
    id_consulta INT AUTO_INCREMENT PRIMARY KEY,
    id_cita INT UNIQUE,
    id_mascota INT NOT NULL,
    id_veterinario INT NOT NULL,
    fecha_consulta DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    diagnostico TEXT NOT NULL,
    observaciones TEXT,
    tratamiento TEXT,
    FOREIGN KEY (id_cita) REFERENCES citas(id_cita) ON DELETE SET NULL,
    FOREIGN KEY (id_mascota) REFERENCES mascotas(id_mascota) ON DELETE CASCADE,
    FOREIGN KEY (id_veterinario) REFERENCES veterinarios(id_veterinario) ON DELETE CASCADE
);

-- ========================================================
-- INSERCIÓN DE DATOS DE PRUEBA
-- ========================================================

INSERT INTO propietarios (id_propietario, nombre, apellido, telefono, email, direccion) VALUES
(1, 'Carlos', 'Mendoza', '555-0101', 'carlos.mendoza@email.com', 'Av. Las Flores #123, Ciudad'),
(2, 'Ana', 'García', '555-0102', 'ana.garcia@email.com', 'Calle Los Olivos #456, Ciudad');

INSERT INTO veterinarios (id_veterinario, nombre, apellido, especialidad, telefono, email) VALUES
(1, 'Dra. María', 'López', 'Cirugía General y Medicina Felina', '555-0201', 'maria.lopez@veterinaria.com'),
(2, 'Dr. Jorge', 'Sánchez', 'Dermatología y Nutrición Canina', '555-0202', 'jorge.sanchez@veterinaria.com');

INSERT INTO usuarios (email, password, id_rol, estado, id_propietario, id_veterinario) VALUES
('admin@veterinaria.com', '$2y$10$e0MYzXyjpJS7Pd0RVvHwHe11yv.RkR8ZqLw.a4e5I2sK5q8xP3Mde', 1, 'Activo', NULL, NULL),
('maria.lopez@veterinaria.com', '$2y$10$e0MYzXyjpJS7Pd0RVvHwHe11yv.RkR8ZqLw.a4e5I2sK5q8xP3Mde', 2, 'Activo', NULL, 1),
('carlos.mendoza@email.com', '$2y$10$e0MYzXyjpJS7Pd0RVvHwHe11yv.RkR8ZqLw.a4e5I2sK5q8xP3Mde', 3, 'Activo', 1, NULL);

INSERT INTO mascotas (id_mascota, id_propietario, nombre, especie, raza, sexo, fecha_nacimiento, caracteristicas) VALUES
(1, 1, 'Max', 'Perro', 'Golden Retriever', 'Macho', '2021-05-10', 'Pelaje dorado, mancha blanca en la pata izquierda.'),
(2, 1, 'Luna', 'Gato', 'Siamés', 'Hembra', '2022-01-15', 'Ojos azules, temperamento tranquilo.');

INSERT INTO servicios (id_servicio, nombre_servicio, descripcion, precio) VALUES
(1, 'Consulta General', 'Evaluación médica preventiva y diagnóstico general.', 25.00),
(2, 'Vacunación', 'Aplicación de vacunas del esquema básico.', 20.00);

INSERT INTO citas (id_cita, id_mascota, id_veterinario, id_servicio, fecha_hora, estado) VALUES
(1, 1, 1, 1, '2026-08-15 09:00:00', 'Atendida'),
(2, 2, 1, 2, '2026-08-25 08:00:00', 'Programada');

INSERT INTO consultas (id_consulta, id_cita, id_mascota, id_veterinario, fecha_consulta, diagnostico, observaciones, tratamiento) VALUES
(1, 1, 1, 1, '2026-08-15 09:30:00', 'Chequeo de rutina aceptable.', 'Mascota responde bien a la palpación.', 'Monitoreo preventivo.');