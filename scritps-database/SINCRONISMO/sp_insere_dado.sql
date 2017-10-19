--------------------------------------------------------
--  File created - Thursday-October-19-2017   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Procedure SP_INSERE_DADO
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "SINCRONISMO"."SP_INSERE_DADO" 
(
    v_nm_coluna_sis VARCHAR2,
    v_nm_coluna_hig VARCHAR2
)
IS
    v_sis_p1     INTEGER;
    v_sis_p2     INTEGER;
    v_hig_p1     INTEGER;
    v_hig_p2     INTEGER;
    v_nm_own_sis VARCHAR2(30);
    v_nm_ent_sis VARCHAR2(30);
    v_nm_col_sis VARCHAR2(30);
    v_nm_own_hig VARCHAR2(30);
    v_nm_ent_hig VARCHAR2(30);
    v_nm_col_hig VARCHAR2(30);
BEGIN
    v_sis_p1     := INSTR(v_nm_coluna_sis, '.');
    v_sis_p2     := INSTR(v_nm_coluna_sis, '.', v_sis_p1+1);
    v_hig_p1     := INSTR(v_nm_coluna_hig, '.');
    v_hig_p2     := INSTR(v_nm_coluna_hig, '.', v_hig_p1+1);

    v_nm_own_sis := UPPER(SUBSTR(v_nm_coluna_sis, 1, v_sis_p1-1));
    v_nm_ent_sis := UPPER(SUBSTR(v_nm_coluna_sis, v_sis_p1+1, v_sis_p2-v_sis_p1-1));
    v_nm_col_sis := UPPER(SUBSTR(v_nm_coluna_sis, v_sis_p2+1, LENGTH(v_nm_coluna_sis)-v_sis_p2));

    v_nm_own_hig := UPPER(SUBSTR(v_nm_coluna_hig, 1, v_hig_p1-1));
    v_nm_ent_hig := UPPER(SUBSTR(v_nm_coluna_hig, v_hig_p1+1, v_hig_p2-v_hig_p1-1));
    v_nm_col_hig := UPPER(SUBSTR(v_nm_coluna_hig, v_hig_p2+1, LENGTH(v_nm_coluna_hig)-v_hig_p2));

  -- HIGIA -> SIS_SAUDE
    INSERT INTO DADO (cod_coluna_origem, cod_coluna_destino, script_transformacao)
    SELECT (SELECT COL_o.cod_coluna
              FROM COLUNA   COL_o
              JOIN ENTIDADE ENT_o
                ON COL_o.cod_entidade = ENT_o.cod_entidade
              JOIN OWNER    ONR_o
                ON ENT_o.cod_owner    = ONR_o.cod_owner
              JOIN ORIGEM   ORI_o
                ON ONR_o.cod_origem   = ORI_o.cod_origem
             WHERE ORI_o.nm_origem    = 'HIGIA'
               AND ONR_o.nm_owner     = v_nm_own_hig
               AND ENT_o.nm_entidade  = v_nm_ent_hig
               AND COL_o.nm_coluna    = v_nm_col_hig)
         , (SELECT COL_d.cod_coluna
              FROM COLUNA   COL_d
              JOIN ENTIDADE ENT_d
                ON COL_d.cod_entidade = ENT_d.cod_entidade
              JOIN OWNER    ONR_d
                ON ENT_d.cod_owner    = ONR_d.cod_owner
              JOIN ORIGEM   ORI_d
                ON ONR_d.cod_origem   = ORI_d.cod_origem
             WHERE ORI_d.nm_origem    = 'SIS_SAUDE'
               AND ONR_d.nm_owner     = v_nm_own_sis
               AND ENT_d.nm_entidade  = v_nm_ent_sis
               AND COL_d.nm_coluna    = v_nm_col_sis)
         , NULL
    FROM DUAL;

  -- HIGIA -> SIS_ODONTO
    INSERT INTO DADO (cod_coluna_origem, cod_coluna_destino, script_transformacao)
    SELECT (SELECT COL_o.cod_coluna
              FROM COLUNA   COL_o
              JOIN ENTIDADE ENT_o
                ON COL_o.cod_entidade = ENT_o.cod_entidade
              JOIN OWNER    ONR_o
                ON ENT_o.cod_owner    = ONR_o.cod_owner
              JOIN ORIGEM   ORI_o
                ON ONR_o.cod_origem   = ORI_o.cod_origem
             WHERE ORI_o.nm_origem    = 'HIGIA'
               AND ONR_o.nm_owner     = v_nm_own_hig
               AND ENT_o.nm_entidade  = v_nm_ent_hig
               AND COL_o.nm_coluna    = v_nm_col_hig)
         , (SELECT COL_d.cod_coluna
              FROM COLUNA   COL_d
              JOIN ENTIDADE ENT_d
                ON COL_d.cod_entidade = ENT_d.cod_entidade
              JOIN OWNER    ONR_d
                ON ENT_d.cod_owner    = ONR_d.cod_owner
              JOIN ORIGEM   ORI_d
                ON ONR_d.cod_origem   = ORI_d.cod_origem
             WHERE ORI_d.nm_origem    = 'SIS_ODONTO'
               AND ONR_d.nm_owner     = v_nm_own_sis
               AND ENT_d.nm_entidade  = v_nm_ent_sis
               AND COL_d.nm_coluna    = v_nm_col_sis)
         , NULL
    FROM DUAL;

  -- SIS_SAUDE -> HIGIA
    INSERT INTO DADO (cod_coluna_origem, cod_coluna_destino, script_transformacao)
    SELECT (SELECT COL_d.cod_coluna
              FROM COLUNA   COL_d
              JOIN ENTIDADE ENT_d
                ON COL_d.cod_entidade = ENT_d.cod_entidade
              JOIN OWNER    ONR_d
                ON ENT_d.cod_owner    = ONR_d.cod_owner
              JOIN ORIGEM   ORI_d
                ON ONR_d.cod_origem   = ORI_d.cod_origem
             WHERE ORI_d.nm_origem    = 'SIS_SAUDE'
               AND ONR_d.nm_owner     = v_nm_own_sis
               AND ENT_d.nm_entidade  = v_nm_ent_sis
               AND COL_d.nm_coluna    = v_nm_col_sis)
         , (SELECT COL_o.cod_coluna
              FROM COLUNA   COL_o
              JOIN ENTIDADE ENT_o
                ON COL_o.cod_entidade = ENT_o.cod_entidade
              JOIN OWNER    ONR_o
                ON ENT_o.cod_owner    = ONR_o.cod_owner
              JOIN ORIGEM   ORI_o
                ON ONR_o.cod_origem   = ORI_o.cod_origem
             WHERE ORI_o.nm_origem    = 'HIGIA'
               AND ONR_o.nm_owner     = v_nm_own_hig
               AND ENT_o.nm_entidade  = v_nm_ent_hig
               AND COL_o.nm_coluna    = v_nm_col_hig)
         , NULL
    FROM DUAL;

  -- SIS_ODONTO -> HIGIA
    INSERT INTO DADO (cod_coluna_origem, cod_coluna_destino, script_transformacao)
    SELECT (SELECT COL_d.cod_coluna
              FROM COLUNA   COL_d
              JOIN ENTIDADE ENT_d
                ON COL_d.cod_entidade = ENT_d.cod_entidade
              JOIN OWNER    ONR_d
                ON ENT_d.cod_owner    = ONR_d.cod_owner
              JOIN ORIGEM   ORI_d
                ON ONR_d.cod_origem   = ORI_d.cod_origem
             WHERE ORI_d.nm_origem    = 'SIS_ODONTO'
               AND ONR_d.nm_owner     = v_nm_own_sis
               AND ENT_d.nm_entidade  = v_nm_ent_sis
               AND COL_d.nm_coluna    = v_nm_col_sis)
         , (SELECT COL_o.cod_coluna
              FROM COLUNA   COL_o
              JOIN ENTIDADE ENT_o
                ON COL_o.cod_entidade = ENT_o.cod_entidade
              JOIN OWNER    ONR_o
                ON ENT_o.cod_owner    = ONR_o.cod_owner
              JOIN ORIGEM   ORI_o
                ON ONR_o.cod_origem   = ORI_o.cod_origem
             WHERE ORI_o.nm_origem    = 'HIGIA'
               AND ONR_o.nm_owner     = v_nm_own_hig
               AND ENT_o.nm_entidade  = v_nm_ent_hig
               AND COL_o.nm_coluna    = v_nm_col_hig)
         , NULL
    FROM DUAL;
    COMMIT;

END sp_insere_dado;

/
