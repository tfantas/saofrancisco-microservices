--------------------------------------------------------
--  File created - Thursday-October-19-2017   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Procedure SP_CONSULTA_MAPEAMENTO
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "SINCRONISMO"."SP_CONSULTA_MAPEAMENTO" 
(
    v_nm_origem   IN  VARCHAR2,
    v_nm_coluna   IN  VARCHAR2,
    v_fl_mapeado  OUT INTEGER,
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

    SELECT COUNT(0)
    INTO v_fl_mapeado
      FROM COLUNA   COL
      JOIN ENTIDADE ENT
        ON COL.cod_entidade = ENT.cod_entidade
      JOIN OWNER    ONR
        ON ENT.cod_owner  = ONR.cod_owner
      JOIN ORIGEM   ORI
        ON ONR.cod_origem = ORI.cod_origem
     WHERE UPPER(ORI.nm_origem) = UPPER(v_nm_origem)
       AND ONR.nm_owner         = v_nm_own
       AND ENT.nm_entidade      = v_nm_ent
       AND COL.nm_coluna        = v_nm_col;

EXCEPTION
    WHEN others THEN
        v_cod_retorno := -1;
        v_msg_retorno := TO_CHAR(SQLCODE) || ' - ' || SQLERRM;

        ROLLBACK;
END sp_consulta_mapeamento;

/
