BEGIN

    -- Lista todos usuários de microserviços
    FOR s IN (select * from ALL_SYNONYMS where table_owner in ('CONCENTRADOR_ANS', 'IMPORTACAO_VIDA'))
    LOOP
        EXECUTE IMMEDIATE 'DROP PUBLIC SYNONYM ' || s.synonym_name;
    END LOOP;
END;
