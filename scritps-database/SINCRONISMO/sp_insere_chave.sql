--------------------------------------------------------
--  File created - Thursday-October-19-2017   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Procedure SP_INSERE_CHAVE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "SINCRONISMO"."SP_INSERE_CHAVE" 
(
    v_nm_origem_a VARCHAR2,
    v_nm_coluna_a VARCHAR2,
    v_cod_valor_a INTEGER,
    v_nm_origem_b VARCHAR2,
    v_nm_coluna_b VARCHAR2,
    v_cod_valor_b INTEGER
)
IS
    v_a_p1     INTEGER;
    v_a_p2     INTEGER;
    v_b_p1     INTEGER;
    v_b_p2     INTEGER;
    v_nm_own_a VARCHAR2(30);
    v_nm_ent_a VARCHAR2(30);
    v_nm_col_a VARCHAR2(30);
    v_nm_own_b VARCHAR2(30);
    v_nm_ent_b VARCHAR2(30);
    v_nm_col_b VARCHAR2(30);
BEGIN
    v_a_p1     := INSTR(v_nm_coluna_a, '.');
    v_a_p2     := INSTR(v_nm_coluna_a, '.', v_a_p1+1);
    v_b_p1     := INSTR(v_nm_coluna_b, '.');
    v_b_p2     := INSTR(v_nm_coluna_b, '.', v_b_p1+1);

    v_nm_own_a := UPPER(SUBSTR(v_nm_coluna_a, 1, v_a_p1-1));
    v_nm_ent_a := UPPER(SUBSTR(v_nm_coluna_a, v_a_p1+1, v_a_p2-v_a_p1-1));
    v_nm_col_a := UPPER(SUBSTR(v_nm_coluna_a, v_a_p2+1, LENGTH(v_nm_coluna_a)-v_a_p2));

    v_nm_own_b := UPPER(SUBSTR(v_nm_coluna_b, 1, v_b_p1-1));
    v_nm_ent_b := UPPER(SUBSTR(v_nm_coluna_b, v_b_p1+1, v_b_p2-v_b_p1-1));
    v_nm_col_b := UPPER(SUBSTR(v_nm_coluna_b, v_b_p2+1, LENGTH(v_nm_coluna_b)-v_b_p2));

    INSERT INTO CHAVE (cod_chave_a, valor_a, cod_chave_b, valor_b)
    SELECT (SELECT COL_a.cod_coluna
              FROM COLUNA   COL_a
              JOIN ENTIDADE ENT_a
                ON COL_a.cod_entidade = ENT_a.cod_entidade
              JOIN OWNER    ONR_a
                ON ENT_a.cod_owner    = ONR_a.cod_owner
              JOIN ORIGEM   ORI_a
                ON ONR_a.cod_origem   = ORI_a.cod_origem
             WHERE ORI_a.nm_origem    = v_nm_origem_a
               AND ONR_a.nm_owner     = v_nm_own_a
               AND ENT_a.nm_entidade  = v_nm_ent_a
               AND COL_a.nm_coluna    = v_nm_col_a)
         , v_cod_valor_a
         , (SELECT COL_b.cod_coluna
              FROM COLUNA   COL_b
              JOIN ENTIDADE ENT_b
                ON COL_b.cod_entidade = ENT_b.cod_entidade
              JOIN OWNER    ONR_b
                ON ENT_b.cod_owner    = ONR_b.cod_owner
              JOIN ORIGEM   ORI_b
                ON ONR_b.cod_origem   = ORI_b.cod_origem
             WHERE ORI_b.nm_origem    = v_nm_origem_b
               AND ONR_b.nm_owner     = v_nm_own_b
               AND ENT_b.nm_entidade  = v_nm_ent_b
               AND COL_b.nm_coluna    = v_nm_col_b)
         , v_cod_valor_b
    FROM DUAL;
    COMMIT;

END sp_insere_chave;

/
