alter table CONTRATO add FL_INATIVA_FILHO_FIM_MES char(1);

create sequence sq_abrangencia_contrato
minvalue 1
maxvalue 9999999999
start with 1
increment by 1
nocache
cycle;