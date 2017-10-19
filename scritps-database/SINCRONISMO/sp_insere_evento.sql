--------------------------------------------------------
--  File created - Thursday-October-19-2017   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Procedure SP_INSERE_EVENTO
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "SINCRONISMO"."SP_INSERE_EVENTO" 
(
    v_nm_origem   IN  VARCHAR2,
    v_nm_coluna   IN  VARCHAR2,
    v_valor_chave IN  VARCHAR2,
    v_tp_operacao IN  CHAR,
    v_cod_evento  OUT INTEGER,
    v_cod_retorno OUT INTEGER,
    v_msg_retorno OUT VARCHAR2
)
IS
    v_p1         INTEGER;
    v_p2         INTEGER;
    v_nm_own     VARCHAR2(30);
    v_nm_ent     VARCHAR2(30);
    v_nm_col     VARCHAR2(30);
BEGIN

    v_cod_retorno := 0;
    v_msg_retorno := '';

    v_p1         := INSTR(v_nm_coluna, '.');
    v_p2         := INSTR(v_nm_coluna, '.', v_p1+1);

    v_nm_own     := UPPER(SUBSTR(v_nm_coluna, 1, v_p1-1));
    v_nm_ent     := UPPER(SUBSTR(v_nm_coluna, v_p1+1, v_p2-v_p1-1));
    v_nm_col     := UPPER(SUBSTR(v_nm_coluna, v_p2+1, LENGTH(v_nm_coluna)-v_p2));

  v_cod_evento := SQ_EVENTO.NEXTVAL;

    INSERT
      INTO EVENTO (cod_evento, cod_chave, valor_chave, tp_operacao, dt_evento, st_evento)
    SELECT v_cod_evento
         , COL.cod_coluna
         , v_valor_chave
         , v_tp_operacao
         , SYSDATE
         , -2
    FROM COLUNA   COL
    JOIN ENTIDADE ENT
      ON COL.cod_entidade = ENT.cod_entidade
    JOIN OWNER    ONR
      ON ENT.cod_owner  = ONR.cod_owner
    JOIN ORIGEM   ORI
      ON ONR.cod_origem = ORI.cod_origem
   WHERE UPPER(ORI.nm_origem)  = UPPER(v_nm_origem)
     AND ONR.nm_owner          = v_nm_own
     AND ENT.nm_entidade       = v_nm_ent
     AND COL.nm_coluna         = v_nm_col
     AND COL.fl_chave_primaria = 'S';

    IF (SQL%rowcount = 0) THEN
        v_cod_evento  := 0;
        v_cod_retorno := 0;
        v_msg_retorno := 'Primary Key não encontrada';
    ELSE
        v_cod_retorno := 1;
        v_msg_retorno := 'Evento gerado com sucesso';
    END IF;

    sp_insere_log (v_cod_evento, 'CRIACAO_EVENTO', 'Origem: ' || v_nm_origem || chr(13) || 'Operacao: ' || v_tp_operacao || chr(13) || 'Coluna: ' || v_nm_coluna || ' = ' || v_valor_chave);

    COMMIT;

EXCEPTION
    WHEN others THEN
        v_cod_evento  := 0;
        v_cod_retorno := -1;
        v_msg_retorno := TO_CHAR(SQLCODE) || ' - ' || SQLERRM;

        ROLLBACK;
END sp_insere_evento;

/
