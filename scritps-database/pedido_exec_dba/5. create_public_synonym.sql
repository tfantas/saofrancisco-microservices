/*
Cria sinonimos publicos
*/

BEGIN
    -- Lista todos os objetos dos usuarios de microservicos
    FOR obj IN (SELECT owner, object_name
                  FROM all_objects
                 WHERE owner IN ('EMPRESA', 'CONTRATO', 'FATURAMENTO', 'BENEFICIARIO', 'CONTROLE_ACESSO', 'DOCUMENTO', 
                                 'ENDERECO', 'MENSAGEM', 'CARTAO')
                   AND object_type IN ('TABLE','VIEW','PROCEDURE','FUNCTION','PACKAGE', 'SEQUENCE')
                 ORDER BY owner, object_type, object_name)
    LOOP
        EXECUTE IMMEDIATE 'CREATE OR REPLACE PUBLIC SYNONYM ' || obj.object_name || ' FOR ' || obj.owner || '.' || obj.object_name;
    END LOOP;
END;