## Grupos de permissões na criação do consentimento

No momento da criação do consentimento todas as permissões dos agrupamentos
de dados aos quais se deseja consentimento devem ser enviadas. Esse conjunto
de permissões necessárias, chamado de grupos de permissões, são designados
conforme tabela abaixo ([link](https://br-openinsurance.github.io/areadesenvolvedor/files/swagger/consents.yaml)
para documentação oficial):

| Categoria de Dados        | Agrupamento                           |  Permissões                                                       |
|---------------------------|---------------------------------------|-------------------------------------------------------------------|
| Cadastro                  | Dados Cadastrais PF                   | CUSTOMERS_PERSONAL_IDENTIFICATIONS_READ<br>RESOURCES_READ         |
| Cadastro                  | Qualificação PF                       | CUSTOMERS_PERSONAL_QUALIFICATION_READ<br>RESOURCES_READ           |
| Cadastro                  | Informações complementares PF         | CUSTOMERS_PERSONAL_ADDITIONALINFO_READ<br>RESOURCES_READ          |
| Cadastro                  | Dados Cadastrais PJ                   | CUSTOMERS_BUSINESS_IDENTIFICATIONS_READ<br>RESOURCES_READ         |
| Cadastro                  | Qualificação PJ                       | CUSTOMERS_BUSINESS_QUALIFICATION_READ<br>RESOURCES_READ           |
| Cadastro                  | Informações complementares PJ         | CUSTOMERS_BUSINESS_ADDITIONALINFO_READ<br>RESOURCES_READ          |
| Danos e Pessoas           | Patrimonial                           | DAMAGES_AND_PEOPLE_PATRIMONIAL_READ<br>DAMAGES_AND_PEOPLE_PATRIMONIAL_POLICYINFO_READ<br>DAMAGES_AND_PEOPLE_PATRIMONIAL_PREMIUM_READ<br>DAMAGES_AND_PEOPLE_PATRIMONIAL_CLAIM_READ<br>RESOURCES_READ|
| Danos e Pessoas           | Responsabilidade                      | DAMAGES_AND_PEOPLE_RESPONSIBILITY_READ<br>DAMAGES_AND_PEOPLE_RESPONSIBILITY_POLICYINFO_READ<br>DAMAGES_AND_PEOPLE_RESPONSIBILITY_PREMIUM_READ<br>DAMAGES_AND_PEOPLE_RESPONSIBILITY_CLAIM_READ<br>RESOURCES_READ|
| Danos e Pessoas           | Transportes                           | DAMAGES_AND_PEOPLE_TRANSPORT_READ<br>DAMAGES_AND_PEOPLE_TRANSPORT_POLICYINFO_READ<br>DAMAGES_AND_PEOPLE_TRANSPORT_PREMIUM_READ<br>DAMAGES_AND_PEOPLE_TRANSPORT_CLAIM_READ<br>RESOURCES_READ|
| Danos e Pessoas           | Riscos Financeiros                    | DAMAGES_AND_PEOPLE_FINANCIAL_RISKS_READ<br>DAMAGES_AND_PEOPLE_FINANCIAL_RISKS_POLICYINFO_READ<br>DAMAGES_AND_PEOPLE_FINANCIAL_RISKS_PREMIUM_READ<br>DAMAGES_AND_PEOPLE_FINANCIAL_RISKS_CLAIM_READ<br>RESOURCES_READ|
| Danos e Pessoas           | Rural                                 | DAMAGES_AND_PEOPLE_RURAL_READ<br>DAMAGES_AND_PEOPLE_RURAL_POLICYINFO_READ<br>DAMAGES_AND_PEOPLE_RURAL_PREMIUM_READ<br>DAMAGES_AND_PEOPLE_RURAL_CLAIM_READ<br>RESOURCES_READ|
| Danos e Pessoas           | Automóveis                            | DAMAGES_AND_PEOPLE_AUTO_READ<br>DAMAGES_AND_PEOPLE_AUTO_POLICYINFO_READ<br>DAMAGES_AND_PEOPLE_AUTO_PREMIUM_READ<br>DAMAGES_AND_PEOPLE_AUTO_CLAIM_READ<br>RESOURCES_READ|
| Danos e Pessoas           | Habitacional                          | DAMAGES_AND_PEOPLE_HOUSING_READ<br>DAMAGES_AND_PEOPLE_HOUSING_POLICYINFO_READ<br>DAMAGES_AND_PEOPLE_HOUSING_PREMIUM_READ<br>DAMAGES_AND_PEOPLE_HOUSING_CLAIM_READ<br>RESOURCES_READ|
| Danos e Pessoas           | Aceitação e Sucursal no exterior      | DAMAGES_AND_PEOPLE_ACCEPTANCE_AND_BRANCHES_ABROAD_READ<br>DAMAGES_AND_PEOPLE_ACCEPTANCE_AND_BRANCHES_ABROAD_POLICYINFO_READ<br>DAMAGES_AND_PEOPLE_ACCEPTANCE_AND_BRANCHES_ABROAD_PREMIUM_READ<br>DAMAGES_AND_PEOPLE_ACCEPTANCE_AND_BRANCHES_ABROAD_CLAIM_READ<br>RESOURCES_READ|
| Danos e Pessoas           | Pessoas                               | DAMAGES_AND_PEOPLE_PERSON_READ<br>DAMAGES_AND_PEOPLE_PERSON_POLICYINFO_READ<br>DAMAGES_AND_PEOPLE_PERSON_CLAIM_READ<br>DAMAGES_AND_PEOPLE_PERSON_MOVEMENTS_READ<br>RESOURCES_READ|
| Previdência Risco         | Produtos de Previdência Risco         | PENSION_PLAN_READ<br>PENSION_PLAN_CONTRACTINFO_READ<br>PENSION_PLAN_MOVEMENTS_READ<br>PENSION_PLAN_PORTABILITIES_READ<br>PENSION_PLAN_WITHDRAWALS_READ<br>PENSION_PLAN_CLAIM<br>RESOURCES_READ|
| Previdência Sobrevivência | Produtos de Previdência Sobrevivência | LIFE_PENSION_READ<br>LIFE_PENSION_CONTRACTINFO_READ<br>LIFE_PENSION_MOVEMENTS_READ<br>LIFE_PENSION_PORTABILITIES_READ<br>LIFE_PENSION_WITHDRAWALS_READ<br>LIFE_PENSION_CLAIM<br>RESOURCES_READ|
