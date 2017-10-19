--------------------------------------------------------
--  File created - Thursday-October-19-2017   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Procedure SP_LIBERA_EVENTO
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "SINCRONISMO"."SP_LIBERA_EVENTO" 
(
    v_cod_evento  IN  INTEGER,
    v_cod_retorno OUT INTEGER,
    v_msg_retorno OUT VARCHAR2
)
IS
BEGIN

    UPDATE EVENTO
     SET st_evento  = 0
     WHERE cod_evento = v_cod_evento;

    IF (SQL%rowcount = 0) THEN
        v_cod_retorno := 0;
        v_msg_retorno := 'Evento não encontrado';
    ELSE
        v_cod_retorno := 1;
        v_msg_retorno := 'Evento liberado com sucesso';
    END IF;

    sp_insere_log (v_cod_evento, 'LIBERACAO_EVENTO', ' ');

    COMMIT;

EXCEPTION
    WHEN others THEN
        v_cod_retorno := -1;
        v_msg_retorno := TO_CHAR(SQLCODE) || ' - ' || SQLERRM;

        ROLLBACK;
END sp_libera_evento;

/
