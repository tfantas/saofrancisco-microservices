--------------------------------------------------------
--  File created - Thursday-October-19-2017   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Procedure SP_INSERE_CONTEUDO
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "SINCRONISMO"."SP_INSERE_CONTEUDO" 
(
    v_cod_evento   IN  INTEGER,
    v_nm_coluna    IN  VARCHAR2,
    v_valor_coluna IN  VARCHAR2,
    v_cod_retorno  OUT INTEGER,
    v_msg_retorno  OUT VARCHAR2
)
IS
    v_p1         INTEGER;
    v_p2         INTEGER;
    v_nm_own     VARCHAR2(30);
    v_nm_ent     VARCHAR2(30);
    v_nm_col     VARCHAR2(30);
    v_cod_origem INTEGER;
BEGIN

    v_cod_retorno := 0;
    v_msg_retorno := '';

    v_p1         := INSTR(v_nm_coluna, '.');
    v_p2         := INSTR(v_nm_coluna, '.', v_p1+1);

    v_nm_own     := UPPER(SUBSTR(v_nm_coluna, 1, v_p1-1));
    v_nm_ent     := UPPER(SUBSTR(v_nm_coluna, v_p1+1, v_p2-v_p1-1));
    v_nm_col     := UPPER(SUBSTR(v_nm_coluna, v_p2+1, LENGTH(v_nm_coluna)-v_p2));

    SELECT ONR.cod_origem
      INTO v_cod_origem
      FROM EVENTO   EVE
      JOIN COLUNA   COL
        ON EVE.cod_chave    = COL.cod_coluna
      JOIN ENTIDADE ENT
        ON COL.cod_entidade = ENT.cod_entidade
      JOIN OWNER    ONR
        ON ENT.cod_owner    = ONR.cod_owner
     WHERE EVE.cod_evento   = v_cod_evento;

    INSERT
      INTO CONTEUDO (cod_evento, cod_coluna, valor_coluna)
    SELECT v_cod_evento
         , COL.cod_coluna
         , v_valor_coluna
      FROM COLUNA   COL
      JOIN ENTIDADE ENT
        ON COL.cod_entidade = ENT.cod_entidade
      JOIN OWNER    ONR
        ON ENT.cod_owner    = ONR.cod_owner
     WHERE ONR.cod_origem   = v_cod_origem
       AND ONR.nm_owner     = v_nm_own
       AND ENT.nm_entidade  = v_nm_ent
       AND COL.nm_coluna    = v_nm_col;

    IF (SQL%rowcount = 0) THEN
        v_cod_retorno := 0;
        v_msg_retorno := 'Coluna não encontrada';
    ELSE
        v_cod_retorno := 1;
        v_msg_retorno := 'Coluna/Valor inseridos com sucesso';
    END IF;

    sp_insere_log (v_cod_evento, 'CRIACAO_CONTEUDO', 'Coluna: ' || v_nm_coluna || ' = ' || v_valor_coluna);

    COMMIT;

EXCEPTION
    WHEN others THEN
        v_cod_retorno := -1;
        v_msg_retorno := TO_CHAR(SQLCODE) || ' - ' || SQLERRM;

        ROLLBACK;
END sp_insere_conteudo;

/
