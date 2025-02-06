# Recepção de Dados Cadastrais e Transacionais

A API de Recepção de Dados Cadastrais e Transacionais trata
da criação, consulta e revogação de consentimentos
e também da obtenção de dados consentidos pelos usuários.

## OpenAPI Specification

Uma descrição da API pode ser encontrada no [OAS](oas-dados.yml) disponibilizado.

## Utilização do consentimento

> **ATENÇÃO:** Os endpoints listados a seguir só podem ser utilizados
após o fluxo de autorização do consentimento pelo usuário, descrito [aqui](../readme.md).

### Consulta de status do consentimento - GET /opus-open-finance/consents/v1/consents/{consentId}

Permite a consulta do status e as informações de um consentimento.

### Revogação de consentimento - DELETE /opus-open-finance/consents/v1/consents/{consentId}

A revogação do consentimento para pagamento pode ser realizada pelo Usuário,
pela Iniciadora, ou pela Transmissora de Dados.

### Obtenção de dados

As APIs de obtenção de dados estão detalhadas no [OAS](oas-dados.yml)
disponibilizado, e incluem:

- **Resources**: listagem de recursos vinculados a um consentimento
e informações de status.
- **Customers**: dados cadastrais de pessoa física e jurídica.
- **Accounts**: dados de contas, saldos, transações e limites.
- **Credit Card Accounts**: dados de contas pós-pagas, faturas, transações e limites.
- **Loans**: dados de contratos de empréstimos.
- **Financings**: dados de contratos de financiamentos.
- **Unarranged Accounts Overdraft**: dados de contratos de adiantamento a depositantes.
- **Invoice Financings**: dados de contratos de direitos creditórios descontados.
- **Bank Fixed Incomes**: dados de operações de renda fixa bancária.
- **Credit Fixed Incomes**: dados de operações de renda fixa crédito.
- **Variable Incomes**: dados de operações de renda variável.
- **Treasure Titles**: dados de operações de títulos de tesouro direto.
- **Funds**: dados de operações de fundos de investimento.
- **Exchanges**: dados de operações de câmbio.

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

| Tipo Request   | Endpoint                                                                | Descrição                                                 | Sucesso  |
| -------------- | ----------------------------------------------------------------------- | --------------------------------------------------------- | -------- |
| POST           | /opus-open-finance/consents/v1/consents                                 | Criação do consentimento de compartilhamento              | 201      |
| GET            | /opus-open-finance/consents/v1/consents/{consentId}                     | Obtenção dos dados do consentimento                       | 200      |
| DELETE         | /opus-open-finance/consents/v1/consents/{consentId}                     | Revogação do consentimento                                | 204      |
| POST           | /opus-open-finance/consents/v1/consents/{consentId}/authorisation-retry | Nova tentativa de autorização do consentimento            | 200      |
| POST           | /opus-open-finance/consents/v1/consents/{consentId}/extends             | Renovação do consentimento                                | 201      |
| GET            | /opus-open-finance/consents/v1/consents/{consentId}/extends             | Obtenção dos dados de renovação do consentimento          | 200      |
| GET            | /opus-open-finance/dcm                                                  | Obtenção dos dados de dcm dos brand clients               | 200      |
| PUT            | /opus-open-finance/dcm                                                  | Atualização dos dados de dcm dos brand clients            | 200      |

### Exemplo de um payload de criação de consentimento

```JSON
{
    "data": {
        "callbackApplicationUri": "https://oob4tpp-callback-url.com/",
        "loggedUser": {
            "document": {
                "identification": "12312312387",
                "rel": "CPF"
            }
        },
        "businessEntity": {
            "document": {
                "identification": "11111678912329",
                "rel": "CNPJ"
            }
        },
        "permissions": [
            "ACCOUNTS_READ",
            "ACCOUNTS_BALANCES_READ",
            "ACCOUNTS_TRANSACTIONS_READ",
            "ACCOUNTS_OVERDRAFT_LIMITS_READ",
            "CREDIT_CARDS_ACCOUNTS_READ",
            "CREDIT_CARDS_ACCOUNTS_BILLS_READ",
            "CREDIT_CARDS_ACCOUNTS_BILLS_TRANSACTIONS_READ",
            "CREDIT_CARDS_ACCOUNTS_LIMITS_READ",
            "CREDIT_CARDS_ACCOUNTS_TRANSACTIONS_READ",
            "CUSTOMERS_BUSINESS_IDENTIFICATIONS_READ",
            "CUSTOMERS_BUSINESS_ADITTIONALINFO_READ",
            "FINANCINGS_READ",
            "FINANCINGS_SCHEDULED_INSTALMENTS_READ",
            "FINANCINGS_PAYMENTS_READ",
            "FINANCINGS_WARRANTIES_READ",
            "INVOICE_FINANCINGS_READ",
            "INVOICE_FINANCINGS_SCHEDULED_INSTALMENTS_READ",
            "INVOICE_FINANCINGS_PAYMENTS_READ",
            "INVOICE_FINANCINGS_WARRANTIES_READ",
            "LOANS_READ",
            "LOANS_SCHEDULED_INSTALMENTS_READ",
            "LOANS_PAYMENTS_READ",
            "LOANS_WARRANTIES_READ",
            "UNARRANGED_ACCOUNTS_OVERDRAFT_READ",
            "UNARRANGED_ACCOUNTS_OVERDRAFT_SCHEDULED_INSTALMENTS_READ",
            "UNARRANGED_ACCOUNTS_OVERDRAFT_PAYMENTS_READ",
            "UNARRANGED_ACCOUNTS_OVERDRAFT_WARRANTIES_READ",
            "EXCHANGES_READ",
            "RESOURCES_READ"
        ],
        "expirationDateTime": "2023-06-21T08:30:00Z"
    }
}
```

Para mais informações sobre os campos veja a [documentação oficial](https://openfinancebrasil.atlassian.net/wiki/spaces/OF/pages/17369335/API+-+Consentimento)
do Open Finance Brasil.

### Exemplo de response (POST e GET)

```JSON
{
    "data": {
        "redirectUrl": "https://client.qa.oofc.opus-software.com.br/opus-open-finance/consents/redirect-uri/urn:amazingbank:30370c82-db45-4a0d-86a5-4a35cd0b4ab8",
        "consentId": "urn:amazingbank:30370c82-db45-4a0d-86a5-4a35cd0b4ab8",
        "consent": {
            "data": {
                "consentId": "urn:amazingbank:30370c82-db45-4a0d-86a5-4a35cd0b4ab8",
                "creationDateTime": "2023-02-23T19:18:25Z",
                "status": "AWAITING_AUTHORISATION",
                "statusUpdateDateTime": "2023-02-23T19:18:25Z",
                "permissions": [
                    "ACCOUNTS_BALANCES_READ",
                    "ACCOUNTS_OVERDRAFT_LIMITS_READ",
                    "ACCOUNTS_READ",
                    "ACCOUNTS_TRANSACTIONS_READ",
                    "CREDIT_CARDS_ACCOUNTS_BILLS_READ",
                    "CREDIT_CARDS_ACCOUNTS_BILLS_TRANSACTIONS_READ",
                    "CREDIT_CARDS_ACCOUNTS_LIMITS_READ",
                    "CREDIT_CARDS_ACCOUNTS_READ",
                    "CREDIT_CARDS_ACCOUNTS_TRANSACTIONS_READ",
                    "CUSTOMERS_BUSINESS_ADITTIONALINFO_READ",
                    "CUSTOMERS_BUSINESS_IDENTIFICATIONS_READ",
                    "FINANCINGS_PAYMENTS_READ",
                    "FINANCINGS_READ",
                    "FINANCINGS_SCHEDULED_INSTALMENTS_READ",
                    "FINANCINGS_WARRANTIES_READ",
                    "INVOICE_FINANCINGS_PAYMENTS_READ",
                    "INVOICE_FINANCINGS_READ",
                    "INVOICE_FINANCINGS_SCHEDULED_INSTALMENTS_READ",
                    "INVOICE_FINANCINGS_WARRANTIES_READ",
                    "LOANS_PAYMENTS_READ",
                    "LOANS_READ",
                    "LOANS_SCHEDULED_INSTALMENTS_READ",
                    "LOANS_WARRANTIES_READ",
                    "RESOURCES_READ",
                    "UNARRANGED_ACCOUNTS_OVERDRAFT_PAYMENTS_READ",
                    "UNARRANGED_ACCOUNTS_OVERDRAFT_READ",
                    "UNARRANGED_ACCOUNTS_OVERDRAFT_SCHEDULED_INSTALMENTS_READ",
                    "UNARRANGED_ACCOUNTS_OVERDRAFT_WARRANTIES_READ",
                    "EXCHANGES_READ"
                ],
                "expirationDateTime": "2023-06-21T08:30:00Z"
            },
            "links": {
                "self": "https://mtls-obb.qa.oob.opus-software.com.br/open-banking/consents/v2/consents/urn:amazingbank:30370c82-db45-4a0d-86a5-4a35cd0b4ab8"
            },
            "meta": {
                "totalRecords": 1,
                "totalPages": 1,
                "requestDateTime": "2023-02-23T19:18:25Z"
            }
        }
    }
}
```
