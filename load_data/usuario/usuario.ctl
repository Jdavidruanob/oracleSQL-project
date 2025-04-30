LOAD DATA
INFILE 'USUARIO.csv'
INTO TABLE USUARIO
APPEND
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
TRAILING NULLCOLS
(
  idUsuario         INTEGER EXTERNAL,
  nombre            CHAR,
  email             CHAR,
  contrasenia       CHAR,
  tipoUsuario       CHAR,
  puntosDonacion    INTEGER EXTERNAL,
  nivelPrivilegio   CHAR,
  telefono          CHAR,
  direccion         CHAR
)
