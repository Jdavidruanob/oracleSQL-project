LOAD DATA
INFILE 'intercambios.csv'
INTO TABLE Intercambio
REPLACE
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
TRAILING NULLCOLS
(
    idIntercambio         INTEGER EXTERNAL,
    tipoIntercambio       CHAR,
    estado                CHAR,
    idUsuarioSolicitante  INTEGER EXTERNAL,
    idUsuarioOferente     INTEGER EXTERNAL,
    fechaPropuesta        DATE "YYYY-MM-DD",
    fechaAprobacion       DATE "YYYY-MM-DD",
    fechaInicio           DATE "YYYY-MM-DD",
    fechaFin              DATE "YYYY-MM-DD"
)
