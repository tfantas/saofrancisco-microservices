--------------------------------------------------------
--  File created - Thursday-October-19-2017   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Procedure SP_INSERE_ENTIDADE
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "SINCRONISMO"."SP_INSERE_ENTIDADE" 
(
    v_nm_origem   VARCHAR2,
    v_nm_entidade VARCHAR2
)
AS
BEGIN

    INSERT
    INTO ENTIDADE (cod_owner,
                   nm_entidade,
                   dsc_entidade)
    SELECT ONR.cod_owner
         , UPPER(SUBSTR(v_nm_entidade, INSTR(v_nm_entidade, '.')+1, LENGTH(v_nm_entidade)))
         , INITCAP(SUBSTR(v_nm_entidade, INSTR(v_nm_entidade, '.')+1, LENGTH(v_nm_entidade)))
      FROM OWNER  ONR
      JOIN ORIGEM ORI
        ON ONR.cod_origem = ORI.cod_origem
     WHERE UPPER(ORI.nm_origem) = UPPER(v_nm_origem)
       AND UPPER(ONR.nm_owner)  = UPPER(SUBSTR(v_nm_entidade, 1, INSTR(v_nm_entidade, '.')-1));

    COMMIT;

END sp_insere_entidade;

/
