--------------------------------------------------------
--  File created - Thursday-October-19-2017   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Procedure SP_ATUALIZA_STATUS_OUTPUT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "SINCRONISMO"."SP_ATUALIZA_STATUS_OUTPUT" 
(
    v_cod_fila_output  IN  INTEGER,
    v_st_output        IN  INTEGER,
    v_valor_chave_dest IN  INTEGER,
    v_cod_retorno      OUT INTEGER,
    v_msg_retorno      OUT VARCHAR2
)
IS
    v_status           VARCHAR2(30);
    v_cod_evento       INTEGER;
    v_cod_chave_orig   INTEGER;
    v_cod_chave_dest   INTEGER;
    v_valor_chave_orig INTEGER;
    v_tp_operacao      CHAR(1);
BEGIN
-- 
-- Atualiza os outputs consumidos
-- 
    -- Inicializa variaveis 
    v_cod_retorno := 0;
    v_msg_retorno := 'Status script atualizado com sucesso';

    -- Atualiza o status de consumo (1: sucesso, -1: falha)
    UPDATE FILA_OUTPUT SET st_output = v_st_output WHERE cod_fila_output = v_cod_fila_output;

    -- Descobre o evento para logar o que houve
    BEGIN
        SELECT cod_evento, cod_chave_destino
          INTO v_cod_evento, v_cod_chave_dest
          FROM FILA_OUTPUT
         WHERE cod_fila_output = v_cod_fila_output;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            v_cod_evento     := NULL;
            v_cod_chave_dest := NULL;
    END;
            
    -- Para o evneto, descobre o tipo de operação e o id da origem
    BEGIN
        SELECT tp_operacao, valor_chave, cod_chave
          INTO v_tp_operacao, v_valor_chave_orig, v_cod_chave_orig
          FROM EVENTO
         WHERE cod_evento = v_cod_evento;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            v_tp_operacao      := NULL;
            v_valor_chave_orig := NULL;
            v_cod_chave_orig   := NULL;
    END;

    -- Testa o status para logar o texto
    IF (v_st_output = 1) THEN
        v_status := 'Executado com sucesso';
        IF (v_tp_operacao = 'I') THEN
            -- Grava a equivalencia de chaves
            INSERT INTO CHAVE(cod_chave, cod_chave_a, valor_a, cod_chave_b, valor_b)
            VALUES(SQ_CHAVE.NEXTVAL, v_cod_chave_orig, v_valor_chave_orig, v_cod_chave_dest, v_valor_chave_dest);
            COMMIT;
        END IF;
    ELSE
        v_status := 'Executado com erro';
    END IF;
  
    sp_insere_log (v_cod_evento, 'CONSUMO_OUTPUT', v_status);
    
    -- Atualiza o status do evento quando o outpput foi executado sem erro
    UPDATE EVENTO SET st_evento = 2 WHERE cod_evento = v_cod_evento AND v_st_output > 0;
    COMMIT;

    v_cod_retorno := 1;
    v_msg_retorno := 'Output atualizado com sucesso.';

EXCEPTION
    -- Trata o erro e retorna para quem chamou
    WHEN others THEN
        v_cod_retorno := -1;
        v_msg_retorno := TO_CHAR(SQLCODE) || ' - ' || SQLERRM;

        ROLLBACK;
END sp_atualiza_status_output;

/
