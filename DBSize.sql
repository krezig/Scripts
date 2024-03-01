--Consulta SQL para el DBA de Oracle que muestra los tablespaces, el espacio utilizado, el espacio libre y los ficheros de datos de los mismos:

Select t.tablespace_name  "Tablespace",  t.status "Estado",  
    ROUND(MAX(d.bytes)/1024/1024,2) "MB Tamaño",
    ROUND((MAX(d.bytes)/1024/1024) - 
    (SUM(decode(f.bytes, NULL,0, f.bytes))/1024/1024),2) "MB Usados",   
    ROUND(SUM(decode(f.bytes, NULL,0, f.bytes))/1024/1024,2) "MB Libres", 
    t.pct_increase "% incremento", 
    SUBSTR(d.file_name,1,80) "Fichero de datos"  
FROM DBA_FREE_SPACE f, DBA_DATA_FILES d,  DBA_TABLESPACES t  
WHERE t.tablespace_name = d.tablespace_name  AND 
    f.tablespace_name(+) = d.tablespace_name    
    AND f.file_id(+) = d.file_id GROUP BY t.tablespace_name,   
    d.file_name,   t.pct_increase, t.status ORDER BY 1,3 DESC

--Tamaño de los ficheros de datos de la base de datos:

select sum(bytes)/1024/1024 MB 
from dba_data_files

--Espacio ocupado por usuario:

SELECT owner, SUM(BYTES)/1024/1024 
FROM DBA_EXTENTS MB
GROUP BY owner

--Espacio ocupado por los diferentes segmentos (tablas, índices, undo, rollback, cluster, ...):

SELECT SEGMENT_TYPE, SUM(BYTES)/1024/1024 
FROM DBA_EXTENTS MB
GROUP BY SEGMENT_TYPE


--tamaño actual de la base de datos en GB

SELECT SUM (bytes) /1024/1024/1024 AS GB FROM dba_data_files;


--tamaño ocupado por datos en la base de datos
SELECT SUM (bytes)/1024/1024/1024 AS GB FROM dba_segments;

--descripcion de dba_segments

describe dba_segments;

--tamaño de esquemaS

 select owner,segment_name,segment_type, bytes
from dba_segments
order by owner;

--para un esquema ene specifico, tamaño en MB

select
   sum(bytes)/1024/1024 as size_in_mega,
   segment_type
from
   dba_segments
where
   owner like '%TEST%'
group by
   segment_type;
   
   --para todos los esquemas, Tamaño en GB
   
   select
   sum(bytes)/1024/1024/1024 as size_in_giga, owner
from
   dba_segments
group by
  owner order by owner desc;