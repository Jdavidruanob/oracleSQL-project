LOAD DATA
INFILE 'donaciones.csv'
INTO TABLE donacion
APPEND
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
TRAILING NULLCOLS
(
  idDonacion          INTEGER EXTERNAL,
  fechaSolicitud      DATE "YYYY-MM-DD",
  fechaAprobacion     DATE "YYYY-MM-DD",
  estado              CHAR,
  puntosAsignados     INTEGER EXTERNAL,
  idUsuario           INTEGER EXTERNAL
)
