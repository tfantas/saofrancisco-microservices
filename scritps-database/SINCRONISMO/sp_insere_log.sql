--------------------------------------------------------
--  File created - Thursday-October-19-2017   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Procedure SP_INSERE_LOG
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "SINCRONISMO"."SP_INSERE_LOG" 
(
    v_cod_evento  IN  INTEGER,
    v_tp_log      IN  VARCHAR2,
    v_dsc_log     IN  VARCHAR2
)
IS
BEGIN

    INSERT INTO LOG (cod_evento, tp_log, dsc_log)
    VALUES (v_cod_evento, v_tp_log, v_dsc_log);

    COMMIT;

EXCEPTION
    WHEN others THEN
        ROLLBACK;
END sp_insere_log;

/
