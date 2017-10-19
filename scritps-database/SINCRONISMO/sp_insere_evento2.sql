--------------------------------------------------------
--  File created - Thursday-October-19-2017   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Procedure SP_INSERE_EVENTO2
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "SINCRONISMO"."SP_INSERE_EVENTO2" 
(
    v_nm_origem   IN  VARCHAR2,
    v_nm_coluna   IN  VARCHAR2,
    v_valor_chave IN  VARCHAR2,
    v_tp_operacao IN  CHAR,
    v_cod_evento  OUT INTEGER,
    v_cod_retorno OUT INTEGER,
    v_msg_retorno OUT VARCHAR2
)
as
BEGIN
 v_msg_retorno := 'ueoueou oueokuaoiueothuaehaoduehdu';
 v_cod_evento := 22;
 v_cod_retorno := 979;

EXCEPTION
  When others then null;
  /*
    WHEN others THEN
        v_cod_evento  := 0;
        v_cod_retorno := -1;
        v_msg_retorno := TO_CHAR(SQLCODE) || ' - ' || SQLERRM;
        */
END sp_insere_evento2;

/
