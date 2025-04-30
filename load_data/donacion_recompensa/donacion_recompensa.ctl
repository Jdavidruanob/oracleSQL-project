LOAD DATA
INFILE 'donacion_recompensa.csv'
INTO TABLE donacion_recompensa
APPEND
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
TRAILING NULLCOLS
(
  idDonacion,
  idEjemplar,
  fechaRecompensa "TO_DATE(:fechaRecompensa, 'YYYY-MM-DD')"
)
