# Recepção de Dados Cadastrais e Apólices

A API de Recepção de Dados Cadastrais e Apólices trata
da criação, consulta e revogação de consentimentos
e também da obtenção de dados consentidos pelos usuários.

## OpenAPI Specification

Uma descrição da API pode ser encontrada no [OAS](oas-dados.yml) disponibilizado.

## Utilização do consentimento

> **ATENÇÃO:** Os endpoints listados a seguir só podem ser utilizados
após o fluxo de autorização do consentimento pelo usuário, descrito [aqui](../readme.md).

### Consulta de status do consentimento - GET /opus-open-insurance/open-insurance/consents/v1/consents/{consentId}

Permite a consulta do status e as informações de um consentimento.

### Revogação de consentimento - DELETE /opus-open-insurance/open-insurance/consents/v1/consents/{consentId}

A revogação do consentimento para pagamento pode ser realizada pelo Usuário,
pela Iniciadora, ou pela Transmissora de Dados.

### Obtenção de dados

As APIs de obtenção de dados estão detalhadas no [OAS](oas-dados.yml)
disponibilizado.

## Orientações importantes

- Todas as datas seguem o padrão da [RFC3339](https://datatracker.ietf.org/doc/html/rfc3339)
e formato "zulu".
- Não há separação funcional entre pessoa natural e pessoa jurídica.
- É de responsabilidade da instituição receptora de dados (TPP)
enviar no pedido de criação do consentimento
todas as permissões referentes aos agrupamentos de dados
que deseja solicitar.
    - As permissões e agrupamentos estão disponíveis [nesta tabela](./permissions.md).
- A instituição transmissora faz a validação do preenchimento correto desses agrupamentos
no momento da geração do consentimento.
- Caso a instituição receptora envie permissões divergentes ao agrupamento especificado
na tabela, a transmissora rejeita o pedido da receptora
(ex.: código HTTP 400 Bad Request).
- A transmissora remove as permissões de produtos não suportados
da lista de permissões requisitadas.
Esse subconjunto é retornado com código HTTP 201 Created.
Caso não restem permissões funcionais,
a instituição transmissora retorna o código HTTP Code 422 Unprocessable Entity.

## APIs

| Tipo Request   | Endpoint                                                                  | Descrição                                                 | Sucesso  |
| -------------- | ------------------------------------------------------------------------- | --------------------------------------------------------- | -------- |
| POST           | /opus-open-insurance/open-insurance/consents/v1/consents                                 | Criação do consentimento de compartilhamento              | 201      |
| GET            | /opus-open-insurance/open-insurance/consents/v1/consents/{consentId}                     | Obtenção dos dados do consentimento                       | 200      |
| DELETE         | /opus-open-insurance/open-insurance/consents/v1/consents/{consentId}                     | Revogação do consentimento                                | 204      |
| POST           | /opus-open-insurance/open-insurance/consents/v1/consents/{consentId}/authorisation-retry | Nova tentativa de autorização do consentimento            | 200      |
| GET            | /opus-open-insurance/dcm                                                  | Obtenção dos dados de dcm dos brand clients               | 200      |
| PUT            | /opus-open-insurance/dcm                                                  | Atualização dos dados de dcm dos brand clients            | 200      |

### Exemplo de um payload de criação de consentimento

```JSON
{
    "data": {
        "callbackApplicationUri": "https://ooi4tpp-callback-url.com/",
        "loggedUser": {
            "document": {
                "identification": "12312312387",
                "rel": "CPF"
            }
        },
        "permissions": [
            "RESOURCES_READ",
            "CUSTOMERS_PERSONAL_IDENTIFICATIONS_READ",
            "CUSTOMERS_PERSONAL_QUALIFICATION_READ",
            "CUSTOMERS_PERSONAL_ADDITIONALINFO_READ",
            "DAMAGES_AND_PEOPLE_ACCEPTANCE_AND_BRANCHES_ABROAD_READ",
            "DAMAGES_AND_PEOPLE_ACCEPTANCE_AND_BRANCHES_ABROAD_POLICYINFO_READ",
            "DAMAGES_AND_PEOPLE_ACCEPTANCE_AND_BRANCHES_ABROAD_PREMIUM_READ",
            "DAMAGES_AND_PEOPLE_ACCEPTANCE_AND_BRANCHES_ABROAD_CLAIM_READ",
            "DAMAGES_AND_PEOPLE_AUTO_READ",
            "DAMAGES_AND_PEOPLE_AUTO_POLICYINFO_READ",
            "DAMAGES_AND_PEOPLE_AUTO_PREMIUM_READ",
            "DAMAGES_AND_PEOPLE_AUTO_CLAIM_READ",
            "DAMAGES_AND_PEOPLE_FINANCIAL_RISKS_READ",
            "DAMAGES_AND_PEOPLE_FINANCIAL_RISKS_POLICYINFO_READ",
            "DAMAGES_AND_PEOPLE_FINANCIAL_RISKS_PREMIUM_READ",
            "DAMAGES_AND_PEOPLE_FINANCIAL_RISKS_CLAIM_READ",
            "DAMAGES_AND_PEOPLE_HOUSING_READ",
            "DAMAGES_AND_PEOPLE_HOUSING_POLICYINFO_READ",
            "DAMAGES_AND_PEOPLE_HOUSING_PREMIUM_READ",
            "DAMAGES_AND_PEOPLE_HOUSING_CLAIM_READ",
            "DAMAGES_AND_PEOPLE_PATRIMONIAL_READ",
            "DAMAGES_AND_PEOPLE_PATRIMONIAL_POLICYINFO_READ",
            "DAMAGES_AND_PEOPLE_PATRIMONIAL_PREMIUM_READ",
            "DAMAGES_AND_PEOPLE_PATRIMONIAL_CLAIM_READ",
            "DAMAGES_AND_PEOPLE_TRANSPORT_READ",
            "DAMAGES_AND_PEOPLE_TRANSPORT_POLICYINFO_READ",
            "DAMAGES_AND_PEOPLE_TRANSPORT_PREMIUM_READ",
            "DAMAGES_AND_PEOPLE_TRANSPORT_CLAIM_READ",
            "DAMAGES_AND_PEOPLE_RESPONSIBILITY_READ",
            "DAMAGES_AND_PEOPLE_RESPONSIBILITY_POLICYINFO_READ",
            "DAMAGES_AND_PEOPLE_RESPONSIBILITY_PREMIUM_READ",
            "DAMAGES_AND_PEOPLE_RESPONSIBILITY_CLAIM_READ",
            "DAMAGES_AND_PEOPLE_RURAL_READ",
            "DAMAGES_AND_PEOPLE_RURAL_POLICYINFO_READ",
            "DAMAGES_AND_PEOPLE_RURAL_PREMIUM_READ",
            "DAMAGES_AND_PEOPLE_RURAL_CLAIM_READ"
        ],
        "expirationDateTime": "2023-06-21T08:30:00Z"
    }
}
```

Para mais informações sobre os campos veja a [documentação oficial](https://br-openinsurance.github.io/areadesenvolvedor/)
do Open Finance Brasil.

### Exemplo de response (POST e GET)

```JSON
{
    "data": {
        "redirectUrl": "https://client.qa.ooic.opus-software.com.br/opus-open-insurance/consents/redirect-uri/urn:amazingbank:b7fa2ff7-8bde-420d-92a3-caf87968991b",
        "consentId": "urn:amazingbank:b7fa2ff7-8bde-420d-92a3-caf87968991b",
        "consent": {
            "data": {
                "consentId": "urn:amazingbank:b7fa2ff7-8bde-420d-92a3-caf87968991b",
                "creationDateTime": "2023-03-21T15:04:50Z",
                "status": "AWAITING_AUTHORISATION",
                "statusUpdateDateTime": "2023-03-21T15:04:50Z",
                "permissions": [
                    "CUSTOMERS_PERSONAL_ADDITIONALINFO_READ",
                    "CUSTOMERS_PERSONAL_IDENTIFICATIONS_READ",
                    "CUSTOMERS_PERSONAL_QUALIFICATION_READ",
                    "DAMAGES_AND_PEOPLE_ACCEPTANCE_AND_BRANCHES_ABROAD_CLAIM_READ",
                    "DAMAGES_AND_PEOPLE_ACCEPTANCE_AND_BRANCHES_ABROAD_POLICYINFO_READ",
                    "DAMAGES_AND_PEOPLE_ACCEPTANCE_AND_BRANCHES_ABROAD_PREMIUM_READ",
                    "DAMAGES_AND_PEOPLE_ACCEPTANCE_AND_BRANCHES_ABROAD_READ",
                    "DAMAGES_AND_PEOPLE_AUTO_CLAIM_READ",
                    "DAMAGES_AND_PEOPLE_AUTO_POLICYINFO_READ",
                    "DAMAGES_AND_PEOPLE_AUTO_PREMIUM_READ",
                    "DAMAGES_AND_PEOPLE_AUTO_READ",
                    "DAMAGES_AND_PEOPLE_FINANCIAL_RISKS_CLAIM_READ",
                    "DAMAGES_AND_PEOPLE_FINANCIAL_RISKS_POLICYINFO_READ",
                    "DAMAGES_AND_PEOPLE_FINANCIAL_RISKS_PREMIUM_READ",
                    "DAMAGES_AND_PEOPLE_FINANCIAL_RISKS_READ",
                    "DAMAGES_AND_PEOPLE_HOUSING_CLAIM_READ",
                    "DAMAGES_AND_PEOPLE_HOUSING_POLICYINFO_READ",
                    "DAMAGES_AND_PEOPLE_HOUSING_PREMIUM_READ",
                    "DAMAGES_AND_PEOPLE_HOUSING_READ",
                    "DAMAGES_AND_PEOPLE_PATRIMONIAL_CLAIM_READ",
                    "DAMAGES_AND_PEOPLE_PATRIMONIAL_POLICYINFO_READ",
                    "DAMAGES_AND_PEOPLE_PATRIMONIAL_PREMIUM_READ",
                    "DAMAGES_AND_PEOPLE_PATRIMONIAL_READ",
                    "DAMAGES_AND_PEOPLE_RESPONSIBILITY_CLAIM_READ",
                    "DAMAGES_AND_PEOPLE_RESPONSIBILITY_POLICYINFO_READ",
                    "DAMAGES_AND_PEOPLE_RESPONSIBILITY_PREMIUM_READ",
                    "DAMAGES_AND_PEOPLE_RESPONSIBILITY_READ",
                    "DAMAGES_AND_PEOPLE_RURAL_CLAIM_READ",
                    "DAMAGES_AND_PEOPLE_RURAL_POLICYINFO_READ",
                    "DAMAGES_AND_PEOPLE_RURAL_PREMIUM_READ",
                    "DAMAGES_AND_PEOPLE_RURAL_READ",
                    "DAMAGES_AND_PEOPLE_TRANSPORT_CLAIM_READ",
                    "DAMAGES_AND_PEOPLE_TRANSPORT_POLICYINFO_READ",
                    "DAMAGES_AND_PEOPLE_TRANSPORT_PREMIUM_READ",
                    "DAMAGES_AND_PEOPLE_TRANSPORT_READ",
                    "RESOURCES_READ"
                ],
                "expirationDateTime": "2023-06-21T15:30:00Z"
            },
            "links": {
                "self": "https://mtls-opin-qa.ooi.opus-software.com.br/open-insurance/consents/v1/consents/urn:amazingbank:b7fa2ff7-8bde-420d-92a3-caf87968991b"
            },
            "meta": {
                "totalRecords": 1,
                "totalPages": 1,
                "requestDateTime": "2023-03-21T15:04:50Z"
            }
        }
    }
}
```
