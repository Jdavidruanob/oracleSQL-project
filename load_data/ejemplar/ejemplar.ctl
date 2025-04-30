LOAD DATA
INFILE 'ejemplares.csv'
INTO TABLE ejemplar
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
TRAILING NULLCOLS
(
  idEjemplar,
  idDonacion,
  idLibro,
  calidad,
  disponibilidad,
  tipoEjemplar,
  formato,
  tamanioArchivo
)
