--------------------------------------------------------
--  File created - Thursday-October-19-2017   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Procedure SP_INSERE_COLUNA
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "SINCRONISMO"."SP_INSERE_COLUNA" 
(
    v_nm_origem         VARCHAR2,
    v_nm_coluna         VARCHAR2,
    v_nm_coluna_ref     VARCHAR2,
    v_fl_chave_primaria CHAR,
    v_tp_dado           VARCHAR2
)
IS
    v_p1         INTEGER;
    v_p2         INTEGER;
    v_ref_p1     INTEGER;
    v_ref_p2     INTEGER;
    v_nm_own     VARCHAR2(30);
    v_nm_ent     VARCHAR2(30);
    v_nm_col     VARCHAR2(30);
    v_nm_own_ref VARCHAR2(30);
    v_nm_ent_ref VARCHAR2(30);
    v_nm_col_ref VARCHAR2(30);
BEGIN
    v_p1         := INSTR(v_nm_coluna, '.');
    v_p2         := INSTR(v_nm_coluna, '.', v_p1+1);
    v_ref_p1     := INSTR(NVL(v_nm_coluna_ref,''), '.');
    v_ref_p2     := INSTR(NVL(v_nm_coluna_ref,''), '.', v_ref_p1+1);

    v_nm_own     := UPPER(SUBSTR(v_nm_coluna, 1, v_p1-1));
    v_nm_ent     := UPPER(SUBSTR(v_nm_coluna, v_p1+1, v_p2-v_p1-1));
    v_nm_col     := UPPER(SUBSTR(v_nm_coluna, v_p2+1, LENGTH(v_nm_coluna)-v_p2));

    v_nm_own_ref := UPPER(SUBSTR(NVL(v_nm_coluna_ref,''), 1, v_ref_p1-1));
    v_nm_ent_ref := UPPER(SUBSTR(NVL(v_nm_coluna_ref,''), v_ref_p1+1, v_ref_p2-v_ref_p1-1));
    v_nm_col_ref := UPPER(SUBSTR(NVL(v_nm_coluna_ref,''), v_ref_p2+1, LENGTH(v_nm_coluna_ref)-v_ref_p2));

    INSERT
      INTO COLUNA (cod_entidade,
                   nm_coluna,
                   dsc_coluna,
                   cod_coluna_referencia,
                   fl_chave_primaria,
                   tp_dado)
    SELECT ENT.cod_entidade
         , v_nm_col
         , INITCAP(v_nm_col)
         , (SELECT CRF.cod_coluna
              FROM COLUNA   CRF
              JOIN ENTIDADE ERF
                ON CRF.cod_entidade = ERF.cod_entidade
              JOIN OWNER    ORF
                ON ERF.cod_owner    = ORF.cod_owner
              JOIN ORIGEM   GRF
                ON ORF.cod_origem   = GRF.cod_origem
             WHERE GRF.nm_origem    = v_nm_origem
               AND ORF.nm_owner     = v_nm_own_ref
               AND ERF.nm_entidade  = v_nm_ent_ref
               AND CRF.nm_coluna    = v_nm_col_ref)
         , v_fl_chave_primaria
         , v_tp_dado
    FROM ENTIDADE ENT
    JOIN OWNER    ONR
      ON ENT.cod_owner = ONR.cod_owner
    JOIN ORIGEM   ORI
      ON ONR.cod_origem = ORI.cod_origem
   WHERE UPPER(ORI.nm_origem) = UPPER(v_nm_origem)
     AND ONR.nm_owner         = v_nm_own
     AND ENT.nm_entidade      = v_nm_ent;

    COMMIT;

END sp_insere_coluna;

/
