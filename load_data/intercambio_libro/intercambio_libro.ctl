LOAD DATA
INFILE 'intercambio_libro.csv'
INTO TABLE Intercambio_Libro
REPLACE
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
(
    idIntercambio INTEGER EXTERNAL,
    idEjemplar    INTEGER EXTERNAL,
    rol           CHAR
)
