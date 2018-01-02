/*
Atribui as roles os grants corretos e aos usuarios da aplicacao a roles
*/
DECLARE
    owner_name VARCHAR2(30);
    user_name  VARCHAR2(30);
    user_pwd   VARCHAR2(20);
    role_name  VARCHAR2(30);
    grant_text VARCHAR2(2000);
    i          INTEGER;
    qt_user    INTEGER;
    qt_role    INTEGER;

BEGIN

    -- Password padrão para novos usuários 
    user_pwd := 'druidq1w2e3';

    -- Lista todos usuários de microserviços
    FOR usr IN (SELECT USERNAME
                  FROM ALL_USERS
                 WHERE USERNAME IN ('EMPRESA', 'CONTRATO', 'FATURAMENTO', 'BENEFICIARIO', 'CONTROLE_ACESSO', 'DOCUMENTO', 
                                    'ENDERECO', 'MENSAGEM', 'SINCRONISMO', 'IMPORTACAO_VIDA'))
    LOOP
        -- Para cada username
        owner_name := usr.USERNAME;

        -- Define o nome do usuario da aplicação e role baseados no schema
        user_name := 'USER_' || owner_name;
        role_name := 'SERVICO_' || owner_name;
        
        -- Conta a quantidade de roles com o nome
        SELECT COUNT(0) INTO qt_role FROM DBA_ROLES WHERE ROLE = role_name;

        -- Testa se já existe a role, se não existir cria
        IF ( qt_role < 1 ) THEN
            EXECUTE IMMEDIATE 'CREATE ROLE ' || role_name;
            dbms_output.put_line ('ROLE ' || role_name || ' criada com sucesso.');
        
        END IF;

        -- Conta a quantidade de users com o nome
        SELECT COUNT(0) INTO qt_user FROM ALL_USERS WHERE USERNAME = user_name;

        -- Testa se já existe o usuário, se não existir cria
        IF ( qt_user < 1 ) THEN
            EXECUTE IMMEDIATE 'CREATE USER ' || user_name || ' IDENTIFIED BY ' || user_pwd;
            EXECUTE IMMEDIATE 'GRANT CREATE SESSION, CONNECT TO ' || user_name;
            dbms_output.put_line ('USER ' || user_name || ' criado com sucesso.');

        END IF;

        -- Inicializa o contador
        i := 0;

        -- Dá os grant para a role 
        FOR obj IN (SELECT object_name
                         , object_type 
                      FROM all_objects 
                     WHERE owner = owner_name 
                       AND object_type IN ('TABLE','PROCEDURE','FUNCTION','PACKAGE', 'SEQUENCE')
                     ORDER BY object_type) 
        LOOP

            IF obj.object_type IN ('TABLE') THEN
                grant_text := 'GRANT SELECT, UPDATE, INSERT, DELETE ON ' || owner_name || '.' || obj.object_name || ' TO ' || role_name;

            ELSIF obj.object_type IN ('PROCEDURE', 'FUNCTION', 'PACKAGE') THEN
                grant_text := 'GRANT EXECUTE ON ' || owner_name || '.' || obj.object_name || ' TO ' || role_name;

            ELSIF obj.object_type IN ('SEQUENCE') THEN
                grant_text := 'GRANT SELECT ON ' || owner_name || '.' || obj.object_name || ' TO ' || role_name;

            END IF;

            dbms_output.put_line (grant_text);
            EXECUTE IMMEDIATE grant_text;

            -- Incrementa o contador
            i := i + 1;

        END LOOP;
    
        dbms_output.put_line ('GRANT concedido para a ROLE ' || role_name || ' em ' || i || ' objetos.' );
        
        -- Dá o grant na role ao usuário
        EXECUTE IMMEDIATE 'GRANT ' || role_name || ' TO ' || user_name;

        dbms_output.put_line ('GRANT concedido à ROLE ' || role_name || ' para o usuário ' || user_name || '.' );

    END LOOP;
END;
