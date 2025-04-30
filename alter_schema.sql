/* Se volvio a crear el esquema ya que nos parecio mas organizado, y lo que se modifico
son las correciones sobre el modelo relacional, eliminando las tablas innecesarias, Admin, digital, fisico
y se agrego donacion recompensa para poder responder las consultas de las recompensas dadas al donar un libro 
 */

-- USUARIO (incluye ADMIN/NORMAL)
CREATE TABLE USUARIO (
  idUsuario        NUMBER(10)       PRIMARY KEY,
  nombre           VARCHAR2(50)     NOT NULL,
  email            VARCHAR2(100)    UNIQUE NOT NULL,
  contrasenia      VARCHAR2(50)     NOT NULL,
  tipoUsuario      VARCHAR2(10)     DEFAULT 'NORMAL' NOT NULL
                      CHECK (tipoUsuario IN ('ADMIN','NORMAL')),
  puntosDonacion   NUMBER(10),       -- sólo para NORMAL
  nivelPrivilegio  VARCHAR2(15),     -- sólo para NORMAL
  telefono         VARCHAR2(20),
  direccion        VARCHAR2(100)
);

-- LIBRO (incluye ISBN)
CREATE TABLE LIBRO (
  idLibro    NUMBER(10)    PRIMARY KEY,
  isbn       VARCHAR2(20)  UNIQUE NOT NULL,
  titulo     VARCHAR2(100) NOT NULL,
  afinidad   NUMBER(6),
  leido      NUMBER(2)
);

-- AUTOR
CREATE TABLE AUTOR (
  idAutor     NUMBER(10)     PRIMARY KEY,
  nombres     VARCHAR2(50)   NOT NULL,
  apellidos   VARCHAR2(50)   NOT NULL
);

-- GENERO
CREATE TABLE GENERO (
  idGenero      NUMBER(10)     PRIMARY KEY,
  nombreGenero  VARCHAR2(50)   UNIQUE NOT NULL
);

-- Relación M:N LIBRO–AUTOR
CREATE TABLE LIBRO_AUTOR (
  idLibro   NUMBER(10)  NOT NULL,
  idAutor   NUMBER(10)  NOT NULL,
  PRIMARY KEY (idLibro, idAutor),
  CONSTRAINT fk_la_libro FOREIGN KEY(idLibro) REFERENCES LIBRO(idLibro) ON DELETE CASCADE,
  CONSTRAINT fk_la_autor FOREIGN KEY(idAutor) REFERENCES AUTOR(idAutor) ON DELETE CASCADE
);

-- Relación M:N LIBRO–GENERO
CREATE TABLE LIBRO_GENERO (
  idLibro    NUMBER(10)  NOT NULL,
  idGenero   NUMBER(10)  NOT NULL,
  PRIMARY KEY (idLibro, idGenero),
  CONSTRAINT fk_lg_libro  FOREIGN KEY(idLibro)  REFERENCES LIBRO(idLibro)  ON DELETE CASCADE,
  CONSTRAINT fk_lg_genero FOREIGN KEY(idGenero) REFERENCES GENERO(idGenero) ON DELETE CASCADE
);

-- DONACION
CREATE TABLE DONACION (
  idDonacion      NUMBER(10)     PRIMARY KEY,
  fechaSolicitud  DATE           NOT NULL,
  fechaAprobacion DATE,
  estado          VARCHAR2(20),
  puntosAsignados NUMBER(10),
  idUsuario       NUMBER(10)     NOT NULL,
  CONSTRAINT fk_donacion_usuario FOREIGN KEY(idUsuario)
    REFERENCES USUARIO(idUsuario) ON DELETE CASCADE
);

-- EJEMPLAR (unifica DIGITAL/FISICO)
CREATE TABLE EJEMPLAR (
  idEjemplar      NUMBER(10)       PRIMARY KEY,
  idDonacion      NUMBER(10)       NOT NULL,
  idLibro         NUMBER(10)       NOT NULL,
  calidad         VARCHAR2(20),      -- antes "estado"
  disponibilidad  NUMBER(1),
  tipoEjemplar    VARCHAR2(10)     DEFAULT 'FISICO' NOT NULL
                    CHECK (tipoEjemplar IN ('DIGITAL','FISICO')),
  formato         VARCHAR2(20),      -- sólo para DIGITAL
  tamanioArchivo  NUMBER(10),        -- sólo para DIGITAL
  CONSTRAINT fk_ejemplar_donacion FOREIGN KEY(idDonacion)
    REFERENCES DONACION(idDonacion) ON DELETE CASCADE,
  CONSTRAINT fk_ejemplar_libro    FOREIGN KEY(idLibro)
    REFERENCES LIBRO(idLibro)      ON DELETE CASCADE
);

-- INTERCAMBIO (unifica TEMPORAL/PERMANENTE)
CREATE TABLE INTERCAMBIO (
  idIntercambio           NUMBER(10)     PRIMARY KEY,
  tipoIntercambio         VARCHAR2(12)   DEFAULT 'PERMANENTE' NOT NULL
                            CHECK (tipoIntercambio IN ('TEMPORAL','PERMANENTE')),
  estado                  VARCHAR2(100)  NOT NULL,  -- p.ej. "PENDIENTE", "APROBADO"
  idUsuarioSolicitante    NUMBER(10)     NOT NULL,
  idUsuarioOferente       NUMBER(10)     NOT NULL,
  fechaPropuesta          DATE,                     -- para PERMANENTE
  fechaAprobacion         DATE,                     -- para PERMANENTE
  fechaInicio             DATE,                     -- para TEMPORAL
  fechaFin                DATE,                     -- para TEMPORAL
  CONSTRAINT fk_inter_solicitante FOREIGN KEY(idUsuarioSolicitante)
    REFERENCES USUARIO(idUsuario),
  CONSTRAINT fk_inter_oferente    FOREIGN KEY(idUsuarioOferente)
    REFERENCES USUARIO(idUsuario)
);

-- INTERCAMBIO_LIBRO (rol en cada intercambio)
CREATE TABLE INTERCAMBIO_LIBRO (
  idIntercambio  NUMBER(10)   NOT NULL,
  idEjemplar     NUMBER(10)   NOT NULL,
  rol            VARCHAR2(10) NOT NULL
                   CHECK (rol IN ('ENTREGADO','RECIBIDO')),
  PRIMARY KEY (idIntercambio, idEjemplar),
  CONSTRAINT fk_il_inter    FOREIGN KEY(idIntercambio)
    REFERENCES INTERCAMBIO(idIntercambio) ON DELETE CASCADE,
  CONSTRAINT fk_il_ejemplar FOREIGN KEY(idEjemplar)
    REFERENCES EJEMPLAR(idEjemplar)       ON DELETE CASCADE
);

-- DONACION_RECOMPENSA (vincula donaciones con ejemplares recibidos)
CREATE TABLE DONACION_RECOMPENSA (
  idDonacion      NUMBER(10)   NOT NULL,
  idEjemplar      NUMBER(10)   NOT NULL,
  fechaRecompensa DATE         NOT NULL,
  PRIMARY KEY (idDonacion, idEjemplar),
  CONSTRAINT fk_recomp_donacion FOREIGN KEY(idDonacion)
    REFERENCES DONACION(idDonacion) ON DELETE CASCADE,
  CONSTRAINT fk_recomp_ejemplar FOREIGN KEY(idEjemplar)
    REFERENCES EJEMPLAR(idEjemplar) ON DELETE CASCADE
);
SELECT 'oracle' dbms,ORA_DATABASE_NAME,t.OWNER,t.TABLE_NAME,c.COLUMN_NAME,c.COLUMN_ID,c.DATA_TYPE,c.DATA_LENGTH,n.CONSTRAINT_TYPE,r.OWNER,r.TABLE_NAME,r.COLUMN_NAME FROM ALL_TABLES t LEFT JOIN ALL_TAB_COLS c ON t.OWNER=c.OWNER AND t.TABLE_NAME=c.TABLE_NAME LEFT JOIN ALL_CONS_COLUMNS nc ON c.OWNER=nc.OWNER AND c.TABLE_NAME=nc.TABLE_NAME AND c.COLUMN_NAME=nc.COLUMN_NAME LEFT JOIN ALL_CONSTRAINTS n ON nc.OWNER=n.OWNER AND nc.CONSTRAINT_NAME=n.CONSTRAINT_NAME AND n.CONSTRAINT_TYPE IN('P','U','R')LEFT JOIN ALL_CONS_COLUMNS r ON n.R_OWNER=r.OWNER AND n.R_CONSTRAINT_NAME=r.CONSTRAINT_NAME AND nc.POSITION=r.POSITION WHERE c.COLUMN_NAME IS NOT NULL;
