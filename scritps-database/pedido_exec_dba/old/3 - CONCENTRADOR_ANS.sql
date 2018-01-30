
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "CONCENTRADOR_ANS"."VW_BENEFICARIO_EMPRESA" ("COD_CPF", "COD_EMPRESA", "COD_BENEFICIARIO", "NRO_CONTRATO_FISICO", "COD_EXTERNO_BENEFICIARIO", "DT_NASCIMENTO", "DT_NASCIMENTO_STR", "NM_BENEFICIARIO", "COD_TITULAR" ) AS 
  SELECT PF.COD_CPF COD_CPF , CO.COD_EMPRESA COD_EMPRESA, BE.COD_BENEFICIARIO COD_BENEFICIARIO, CO.NRO_CONTRATO_FISICO NRO_CONTRATO_FISICO, BE.COD_EXTERNO_BENEFICIARIO COD_EXTERNO_BENEFICIARIO, PF.DT_NASCIMENTO DT_NASCIMENTO, to_char(PF.DT_NASCIMENTO,'dd/MM/yyyy') as DT_NASCIMENTO_STR,
  PF.NM_BENEFICIARIO NM_BENEFICIARIO, BE.COD_TITULAR 
FROM           BENEFICIARIO.PESSOA_FISICA PF
INNER JOIN     BENEFICIARIO.BENEFICIARIO BE
ON PF.COD_PESSOA_FISICA = BE.COD_PESSOA_FISICA
INNER JOIN     BENEFICIARIO.VINCULO VI
ON BE.COD_BENEFICIARIO = VI.COD_BENEFICIARIO
INNER JOIN     CONTRATO.CONTRATO_PLANO CP
ON VI.COD_CONTRATO_PLANO = CP.COD_CONTRATO_PLANO
INNER JOIN     CONTRATO.CONTRATO CO
ON CO.COD_CONTRATO = CP.COD_CONTRATO
WHERE CO.COD_EMPRESA IS NOT NULL;