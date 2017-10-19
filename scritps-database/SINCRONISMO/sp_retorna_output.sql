--------------------------------------------------------
--  File created - Thursday-October-19-2017   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Procedure SP_RETORNA_OUTPUT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "SINCRONISMO"."SP_RETORNA_OUTPUT" 
(
    v_nm_origem       IN  VARCHAR2,
    v_cod_fila_output OUT INTEGER,
    v_script_sql      OUT CLOB,
    v_script_json     OUT CLOB,
    v_cod_retorno     OUT INTEGER,
    v_msg_retorno     OUT VARCHAR2
)
IS
    v_cod_evento INTEGER;
BEGIN

    v_cod_retorno := 0;
    v_msg_retorno := '';

    BEGIN
        SELECT cod_fila_output
          INTO v_cod_fila_output
          FROM (SELECT FOP.cod_fila_output, 
                       row_number() OVER (ORDER BY ENT.nro_ordem_prioridade DESC, FOP.cod_fila_output) rn
                  FROM FILA_OUTPUT FOP
                  JOIN EVENTO      EVE
                    ON FOP.cod_evento         = EVE.cod_evento
                  JOIN COLUNA      COL_O
                    ON EVE.cod_chave          = COL_O.cod_coluna
                  JOIN DADO        DAD
                    ON COL_O.cod_coluna       = DAD.cod_coluna_origem
                  JOIN COLUNA      COL_D
                    ON DAD.cod_coluna_destino = COL_D.cod_coluna
                  JOIN ENTIDADE    ENT
                    ON COL_D.cod_entidade     = ENT.cod_entidade
                  JOIN OWNER       OWN
                    ON ENT.cod_owner          = OWN.cod_owner
                  JOIN ORIGEM      ORI
                    ON OWN.cod_origem         = ORI.cod_origem
                 WHERE FOP.st_output = 0
                   AND ORI.nm_origem = v_nm_origem)
         WHERE rn = 1;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            v_cod_fila_output := NULL;
    END;

    BEGIN
        SELECT FOP.cod_evento
             , FOP.script_sql
             , FOP.script_json
          INTO v_cod_evento
             , v_script_sql
             , v_script_json
          FROM FILA_OUTPUT FOP
         WHERE FOP.cod_fila_output = v_cod_fila_output;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            v_cod_evento := NULL;
            v_script_sql := NULL;
            v_script_json := NULL;
    END;

    UPDATE FILA_OUTPUT SET st_output = -2 WHERE cod_fila_output = v_cod_fila_output;
    COMMIT;
  
    sp_insere_log (v_cod_evento, 'CONSUMO_OUTPUT', ' ');

    v_cod_retorno := 1;
    v_msg_retorno := 'Output retornado com sucesso.';

EXCEPTION
    WHEN others THEN
        v_cod_retorno := -1;
        v_msg_retorno := TO_CHAR(SQLCODE) || ' - ' || SQLERRM;

        ROLLBACK;
END sp_retorna_output;

/
