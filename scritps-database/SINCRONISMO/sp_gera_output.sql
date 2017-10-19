--------------------------------------------------------
--  File created - Thursday-October-19-2017   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Procedure SP_GERA_OUTPUT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "SINCRONISMO"."SP_GERA_OUTPUT" 
IS
    v_sql             CLOB;
    v_sql_insert      CLOB;
    v_sql_values      CLOB;
    v_json            CLOB;
    v_valor           CLOB;
    v_valor_desino_pk INTEGER;
CURSOR c_lista_evento IS
SELECT DISTINCT EVE.cod_evento
     , EVE.tp_operacao
     , ORI_o.cod_origem cod_origem_origem
     , ORI_d.cod_origem cod_origem_destino
     , ORI_o.nm_origem || '->' || ORI_d.nm_origem fluxo
--     , ONR_o.nm_owner || '.' || ENT_o.nm_entidade origem
     , ONR_d.nm_owner || '.' || ENT_d.nm_entidade destino
     , ONR_pk.nm_owner || '.' || ENT_pk.nm_entidade  || '.' || COL_pk.nm_coluna pk
--     , ONR_o.cod_owner                            cod_owner_origem
--     , ONR_o.nm_owner                             nm_owner_origem
--     , ENT_o.cod_entidade                         cod_entidade_origem
--     , ENT_o.nm_entidade                          nm_entidade_origem
     , ONR_d.cod_owner                            cod_owner_destino
     , ONR_d.nm_owner                             nm_owner_destino
     , ENT_d.cod_entidade                         cod_entidade_destino
     , ENT_d.nm_entidade                          nm_entidade_destino
     , ENT_d.nm_sequence                          nm_sequence_destino
     , ONR_pk.nm_owner                            nm_owner_pk
     , ENT_pk.nm_entidade                         nm_entidade_pk
     , COL_pk.nm_coluna                           nm_coluna_pk
     , COL_pk.cod_coluna                          cod_coluna_pk_origem
     , EVE.cod_chave                              cod_coluna_pk_destino
     , EVE.valor_chave                            valor_chave_origem
  FROM EVENTO              EVE
  JOIN CONTEUDO            CNT
    ON CNT.cod_evento            = EVE.cod_evento
  JOIN DADO                DAD
    ON CNT.cod_coluna            = DAD.cod_coluna_origem
  JOIN COLUNA              COL_d
    ON DAD.cod_coluna_destino    = COL_d.cod_coluna
  JOIN ENTIDADE            ENT_d
    ON COL_d.cod_entidade        = ENT_d.cod_entidade
  JOIN OWNER               ONR_d
    ON ENT_d.cod_owner           = ONR_d.cod_owner
  JOIN ORIGEM              ORI_d
    ON ONR_d.cod_origem          = ORI_d.cod_origem
  JOIN COLUNA              COL_o
    ON CNT.cod_coluna            = COL_o.cod_coluna
  JOIN ENTIDADE            ENT_o
    ON COL_o.cod_entidade        = ENT_o.cod_entidade
  JOIN OWNER               ONR_o
    ON ENT_o.cod_owner           = ONR_o.cod_owner
  JOIN ORIGEM              ORI_o
    ON ONR_o.cod_origem          = ORI_o.cod_origem
  LEFT JOIN DADO           DAD_pk
    ON EVE.cod_chave             = DAD_pk.cod_coluna_origem
  LEFT JOIN COLUNA         COL_pk
    ON DAD_pk.cod_coluna_destino = COL_pk.cod_coluna
  LEFT JOIN ENTIDADE       ENT_pk
    ON COL_pk.cod_entidade       = ENT_pk.cod_entidade
  LEFT JOIN OWNER          ONR_pk
    ON ENT_pk.cod_owner          = ONR_pk.cod_owner
 WHERE EVE.dt_consumo            IS NULL
   AND EVE.st_evento             = 0
   AND ONR_pk.cod_origem         = ORI_d.cod_origem;

BEGIN

FOR r_evento IN c_lista_evento LOOP
    -- Gera output SQL
    IF (r_evento.tp_operacao = 'I') THEN

        -- Prepara inicio geracao SQL
        v_sql_insert := 'INSERT INTO ' || r_evento.destino || '( ';
        v_sql_values := 'SELECT ';

        -- Prepara inicio geracao JSON
        v_json := '{"event":"INSERT","tableName":"' || r_evento.nm_entidade_destino || 
                  '","oldRow":null,"newRow":{"columns":{';

        -- Se tiver sequence definida, usa a pk definide e o nextval da sequence como valor
        IF NOT(r_evento.nm_sequence_destino IS NULL) THEN        
            v_sql_insert := v_sql_insert || r_evento.nm_coluna_pk || ', ';
            v_sql_values := v_sql_values || r_evento.nm_sequence_destino || '.NEXTVAL' || ', ';
            v_json := v_json || '"' || r_evento.nm_coluna_pk || '":null,';
        END IF;

        -- loop pelas colunas
        FOR r_coluna IN (SELECT COL.nm_coluna
                              , COL.cod_coluna_referencia
                              , COL.tp_dado
                              , CNT.valor_coluna
                              , DAD.script_transformacao
                              , DAD.cod_coluna_origem
                              , DAD.cod_coluna_destino 
                           FROM conteudo CNT
                           JOIN dado     DAD
                             ON CNT.cod_coluna         = DAD.cod_coluna_origem
                           JOIN coluna   COL
                             ON DAD.cod_coluna_destino = COL.cod_coluna
                           JOIN entidade ENT
                             ON COL.cod_entidade       = ENT.cod_entidade
                           JOIN owner    ONR
                             ON ENT.cod_owner          = ONR.cod_owner
                          WHERE CNT.cod_evento         = r_evento.cod_evento
                            AND ONR.cod_origem         = r_evento.cod_origem_destino)
        LOOP
            -- Adiciona mais uma coluna no INSERT
            v_sql_insert := v_sql_insert || r_coluna.nm_coluna || ', ';

            -- Adiciona mais uma chave no JSON
            v_json := v_json || '"' || r_coluna.nm_coluna || '":';

            -- Verifica se ha FK apontando para outra tabela
            IF NOT (r_coluna.cod_coluna_referencia IS NULL) THEN
            -- Procura o de-para de chave
            BEGIN
                SELECT valor
                  INTO v_valor
                  FROM (SELECT CHA.valor_b valor
                          FROM chave CHA
                         WHERE CHA.cod_chave_a = r_coluna.cod_coluna_referencia
                           AND CHA.valor_a     = r_coluna.valor_coluna
                         UNION ALL
                        SELECT CHA.valor_b valor
                          FROM chave CHA
                         WHERE CHA.cod_chave_b = r_coluna.cod_coluna_referencia
                           AND CHA.valor_a     = r_coluna.valor_coluna
                         UNION ALL
                         SELECT CHA.valor_a valor
                          FROM chave CHA
                         WHERE CHA.cod_chave_a = r_coluna.cod_coluna_referencia
                           AND CHA.valor_b     = r_coluna.valor_coluna
                         UNION ALL
                        SELECT CHA.valor_a valor
                          FROM chave CHA
                         WHERE CHA.cod_chave_b = r_coluna.cod_coluna_referencia
                           AND CHA.valor_b     = r_coluna.valor_coluna);
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    v_valor := NULL;
            END;
            ELSE
            -- Verifica se ha de-para de dominio
            BEGIN
                SELECT DOM.valor_destino
                  INTO v_valor
                  FROM dominio DOM
                 WHERE DOM.cod_coluna_origem  = r_coluna.cod_coluna_origem
                   AND DOM.cod_coluna_destino = r_coluna.cod_coluna_destino
                   AND DOM.valor_origem       = r_coluna.valor_coluna;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    v_valor := NULL;
            END;
            END IF;

            -- Se nao houver, considera o valor
            v_valor := NVL(v_valor, r_coluna.valor_coluna);

            -- Verifica se ha script de transformacao
            IF NOT (r_coluna.script_transformacao IS NULL) THEN
            BEGIN
                -- Substitui a chave pelo valor no script de transformacao
                v_sql_values := v_sql_values || REPLACE(r_coluna.script_transformacao, '###', '''' || v_valor || '''') || ', ';
                -- Nao inclui script de transformacao para JSON
                v_json := v_json || '"' || v_valor || '",';
            END;
            ELSE
            BEGIN
                -- Adiciona mais uma coluna no SELECT, de acordo com o tipo de dado e seus tratamentos
                CASE r_coluna.tp_dado
                    WHEN 'STRING' THEN
                        v_sql_values := v_sql_values || '''' || v_valor || ''', ';
                        v_json := v_json || '"' || v_valor || '",';
                    WHEN 'DATE' THEN
                        v_sql_values := v_sql_values || ' TO_DATE(''' || v_valor || '''), ';
                        v_json := v_json || '"' || v_valor || '",';
                    ELSE
                        v_sql_values := v_sql_values || v_valor || ', ';
                        v_json := v_json || v_valor || ',';
                END CASE;
            END;
            END IF;
        END LOOP;

        -- Ajusta o comando SQL
        -- Retira os dois ultimos caracteres (virgula e espaco) 
        v_sql_insert := SUBSTR(v_sql_insert, 1, LENGTH(v_sql_insert)-2);
        v_sql_values := SUBSTR(v_sql_values, 1, LENGTH(v_sql_values)-2);

        v_sql_insert := v_sql_insert || ' )';
        v_sql_values := v_sql_values || ' FROM DUAL;';
        v_sql := v_sql_insert || CHR(13) || v_sql_values; 

        -- Ajusta o JSON
        v_json := SUBSTR(v_json, 1, LENGTH(v_json)-1);
        v_json := v_json || '}';

    ELSE
        -- Prepara inicio geracao SQL
        v_sql := 'UPDATE ' || r_evento.destino || ' SET ';

        -- Prepara inicio geracao JSON
        v_json := '{"event":"UPDATE","tableName":"' || r_evento.nm_entidade_destino || 
                  '","oldRow":null,"newRow":{"columns":{';

        -- loop pelas colunas
        FOR r_coluna IN (SELECT COL.nm_coluna
                              , COL.cod_coluna_referencia
                              , COL.tp_dado
                              , CNT.valor_coluna
                              , DAD.script_transformacao
                              , DAD.cod_coluna_origem
                              , DAD.cod_coluna_destino 
                           FROM conteudo CNT
                           JOIN dado     DAD
                             ON CNT.cod_coluna         = DAD.cod_coluna_origem
                           JOIN coluna   COL
                             ON DAD.cod_coluna_destino = COL.cod_coluna
                           JOIN entidade ENT
                             ON COL.cod_entidade       = ENT.cod_entidade
                           JOIN owner    ONR
                             ON ENT.cod_owner          = ONR.cod_owner
                          WHERE CNT.cod_evento         = r_evento.cod_evento
                            AND ONR.cod_origem         = r_evento.cod_origem_destino)
        LOOP
            -- Adiciona mais uma coluna no INSERT
            v_sql := v_sql || r_coluna.nm_coluna || ' = ';

            -- Adiciona mais uma chave no JSON
            v_json := v_json || '"' || r_coluna.nm_coluna || '":';

            -- Verifica se ha FK apontando para outra tabela
            IF NOT (r_coluna.cod_coluna_referencia IS NULL) THEN
            -- Procura o de-para de chave
            BEGIN
                SELECT valor
                  INTO v_valor
                  FROM (SELECT CHA.valor_b valor
                          FROM chave CHA
                         WHERE CHA.cod_chave_a = r_coluna.cod_coluna_referencia
                           AND CHA.valor_a     = r_coluna.valor_coluna
                         UNION ALL
                        SELECT CHA.valor_b valor
                          FROM chave CHA
                         WHERE CHA.cod_chave_b = r_coluna.cod_coluna_referencia
                           AND CHA.valor_a     = r_coluna.valor_coluna
                         UNION ALL
                         SELECT CHA.valor_a valor
                          FROM chave CHA
                         WHERE CHA.cod_chave_a = r_coluna.cod_coluna_referencia
                           AND CHA.valor_b     = r_coluna.valor_coluna
                         UNION ALL
                        SELECT CHA.valor_a valor
                          FROM chave CHA
                         WHERE CHA.cod_chave_b = r_coluna.cod_coluna_referencia
                           AND CHA.valor_b     = r_coluna.valor_coluna);
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    v_valor := NULL;
            END;
            ELSE
            -- Verifica se ha de-para de dominio
            BEGIN
                SELECT DOM.valor_destino
                  INTO v_valor
                  FROM dominio DOM
                 WHERE DOM.cod_coluna_origem  = r_coluna.cod_coluna_origem
                   AND DOM.cod_coluna_destino = r_coluna.cod_coluna_destino
                   AND DOM.valor_origem       = r_coluna.valor_coluna;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    v_valor := NULL;
            END;
            END IF;

            -- Se nao houver, considera o valor
            v_valor := NVL(v_valor, r_coluna.valor_coluna);

            -- Verifica se ha script de transformacao
            IF NOT (r_coluna.script_transformacao IS NULL) THEN
            BEGIN
                -- Substitui a chave pelo valor no script de transformacao
                v_sql_values := v_sql_values || REPLACE(r_coluna.script_transformacao, '###', '''' || v_valor || '''') || ', ';
                -- Nao inclui script de transformacao para JSON
                v_json := v_json || '"' || v_valor || '",';
            END;
            ELSE
            BEGIN
                -- Adiciona mais uma coluna no SELECT, de acordo com o tipo de dado e seus tratamentos
                CASE r_coluna.tp_dado
                    WHEN 'STRING' THEN
                        v_sql_values := v_sql_values || '''' || v_valor || ''', ';
                        v_json := v_json || '"' || v_valor || '",';
                    WHEN 'DATE' THEN
                        v_sql_values := v_sql_values || ' TO_DATE(''' || v_valor || '''), ';
                        v_json := v_json || '"' || v_valor || '",';
                    ELSE
                        v_sql_values := v_sql_values || v_valor || ', ';
                        v_json := v_json || v_valor || ',';
                END CASE;
            END;
            END IF;
        END LOOP;
    
        -- Retira os tres ultimos caracteres (espaco, igual e espaco)
        v_sql := SUBSTR(v_sql, 1, LENGTH(v_sql)-2);

        -- Procura o de-para de chave
        BEGIN
            SELECT valor
              INTO v_valor_desino_pk
              FROM (SELECT CHA.valor_b valor
                      FROM chave CHA
                     WHERE CHA.cod_chave_a = r_evento.cod_coluna_pk_destino
                       AND CHA.cod_chave_b = r_evento.cod_coluna_pk_origem
                       AND CHA.valor_a     = r_evento.valor_chave_origem
                     UNION ALL
                    SELECT CHA.valor_a valor
                      FROM chave CHA
                     WHERE CHA.cod_chave_a = r_evento.cod_coluna_pk_origem
                       AND CHA.cod_chave_b = r_evento.cod_coluna_pk_destino
                      AND CHA.valor_b      = r_evento.valor_chave_origem);
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                v_valor_desino_pk := NULL;
        END;

        -- Adiciona a clausula where
        v_sql := v_sql || ' WHERE ' || r_evento.nm_coluna_pk || ' = ' || v_valor_desino_pk || ';';

        -- Ajusta o JSON
        v_json := v_json || '"' || r_evento.nm_coluna_pk || '":' || v_valor_desino_pk || '}';

    END IF;

    sp_insere_log (r_evento.cod_evento, 'GERACAO_OUTPUT', 'SQL: ' || CHR(13) || v_sql);
    sp_insere_log (r_evento.cod_evento, 'GERACAO_OUTPUT', 'JSON: ' || CHR(13) || v_json);

    INSERT INTO FILA_OUTPUT (cod_evento, dsc_fluxo, script_sql, script_json, st_output, cod_chave_destino)
    VALUES (r_evento.cod_evento, r_evento.fluxo, v_sql, v_json, 0, r_evento.cod_coluna_pk_destino);
    COMMIT;

    UPDATE EVENTO SET st_evento = 1 WHERE cod_evento = r_evento.cod_evento;
    COMMIT;

END LOOP;

EXCEPTION
    -- Trata o erro e retorna para quem chamou
    WHEN others THEN
        ROLLBACK;
END sp_gera_output;

/
