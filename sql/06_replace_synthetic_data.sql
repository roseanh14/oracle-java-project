-- WARNING: destructive data replacement. Backup the existing database first.
-- Run as SPATIAL_USER in FREEPDB1, after confirming the schema and SRID 4326.
-- Run with @sql/06_replace_synthetic_data.sql; child scripts are resolved relative to this file.
-- Data source: OpenStreetMap contributors, ODbL 1.0.
SET DEFINE OFF
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK

-- Refuse to replace a network containing stored paths.
DECLARE
n_paths NUMBER;
  n_plinks NUMBER;
  n_nodes NUMBER;
  n_links NUMBER;
BEGIN
SELECT COUNT(*) INTO n_paths FROM CITY_NETWORK_PATH$;
SELECT COUNT(*) INTO n_plinks FROM CITY_NETWORK_PLINK$;
SELECT COUNT(*) INTO n_nodes FROM CITY_NETWORK_NODE$;
SELECT COUNT(*) INTO n_links FROM CITY_NETWORK_LINK$;
IF n_paths != 0 OR n_plinks != 0 THEN
    RAISE_APPLICATION_ERROR(-20001, 'Stored paths exist; aborting replacement');
END IF;
  IF NOT ((n_nodes = 30 AND n_links = 60) OR (n_nodes = 0 AND n_links = 0)) THEN
    RAISE_APPLICATION_ERROR(-20002, 'Unexpected existing counts; aborting replacement');
END IF;
END;
/

DELETE FROM CITY_NETWORK_LINK$;
DELETE FROM CITY_NETWORK_NODE$;
@@02_insert_nodes.sql
@@03_insert_links.sql

DECLARE
n_nodes NUMBER;
  n_links NUMBER;
BEGIN
SELECT COUNT(*) INTO n_nodes FROM CITY_NETWORK_NODE$;
SELECT COUNT(*) INTO n_links FROM CITY_NETWORK_LINK$;
IF n_nodes != 45 OR n_links != 60 THEN
    RAISE_APPLICATION_ERROR(-20003, 'Wrong inserted counts; rolling back');
END IF;
  IF SDO_NET.VALIDATE_NETWORK('CITY_NETWORK','TRUE') != 'TRUE' THEN
    RAISE_APPLICATION_ERROR(-20004, 'Network invalid; rolling back');
END IF;
END;
/
COMMIT;
PROMPT Successfully installed 45 junctions and 60 links; validated TRUE.
