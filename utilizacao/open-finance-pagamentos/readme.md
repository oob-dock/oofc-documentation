# Iniciação de Transação de Pagamento

A API de Iniciação de Transação de Pagamento trata
da criação, consulta e revogação de consentimentos
e também da criação de pagamentos via Pix.

## OpenAPI Specification

Uma descrição da API pode ser encontrada no [OAS](oas-pagamentos.yml) disponibilizado.

## Utilização do consentimento

> **ATENÇÃO:** Os endpoints listados a seguir só podem ser utilizados
após o fluxo de autorização do consentimento pelo usuário, descrito [aqui](../readme.md).

### Iniciação de pagamento

#### POST /proxy/open-banking/payments/v4/pix/payments

Após a aprovação do consentimento,
é necessário requisitar o início do pagamento junto à Detentora de Conta.

Nos casos de sucesso, a resposta terá código HTTP 201 Created
e conterá as informações do pagamento iniciado.
O consentimento associado terá seu status alterado para **CONSUMED**.

> É necessário consultar o status do pagamento iniciado
(ex.: através de *polling* no endpoint descrito abaixo)
para verificar quando/se ele foi de fato realizado.

Já para os casos de falha na criação do pagamento, a Detentora retornará
HTTP 422 Unprocessable Entity com o código referente ao erro ocorrido,
e o status de seu consentimento se tornará **REJECTED**.
Para mais informações sobre os códigos de erro durante a criação do pagamento PIX,
consultar a [documentação oficial](https://openfinancebrasil.atlassian.net/wiki/spaces/OF/pages/347078657/v4.0.0+-+SV+Pagamentos)
(seção *"Informações Técnicas - Pagamentos"*, schema `422ResponseErrorCreatePixPayment`).

Exemplo de request com amount (100.00) diferente do definido no consentimento (10.00):

Request Body:

```json
{
  "data": [
    {
      "endToEndId": "E9040088820210128000800123873170",
      "localInstrument": "DICT",
      "payment": {
        "amount": "100.00",
        "currency": "BRL"
      },
      "creditorAccount": {
        "ispb": "12345678",
        "issuer": "1774",
        "number": "1234567890",
        "accountType": "CACC"
      },
      "remittanceInformation": "Pagamento da nota XPTO035-002.",
      "qrCode": "00020104141234567890123426660014BR.GOV.BCB.PIX014466756C616E6F32303139406578616D706C652E636F6D27300012\nBR.COM.OUTRO011001234567895204000053039865406123.455802BR5915NOMEDORECEBEDOR6008BRASILIA61087007490062\n530515RP12345678-201950300017BR.GOV.BCB.BRCODE01051.0.080450014BR.GOV.BCB.PIX0123PADRAO.URL.PIX/0123AB\nCD81390012BR.COM.OUTRO01190123.ABCD.3456.WXYZ6304EB76\n",
      "proxy": "12345678901",
      "cnpjInitiator": "50685362000135",
      "transactionIdentification": "E00038166201907261559y6j6",
      "ibgeTownCode": "5300108",
      "authorisationFlow": "HYBRID_FLOW",
      "consentId": "urn:bancoex:C1DD33123"
    }
  ]
}
```

Response Error no formato JSON - resposta é retornada no formato JWT:

```json
{
  "errors": [
    {
      "code": "PAGAMENTO_DIVERGENTE_DO_CONSENTIMENTO",
      "title": "divergência entre pagamento e consentimento",
      "detail": "Dados do pagamento divergentes dos dados do consentimento"
    }
  ],
  "meta": {
    "requestDateTime": "2021-05-21T08:30:00Z"
  },
  "aud": "27aea8f6-2119-55f8-9553-5ad4b08eeb17",
  "iss": "27aea8f6-2119-55f8-9553-5ad4b08eeb17",
  "jti": "db068223-50bd-4342-b462-01434a9df172",
  "iat": 1656965998
}
```

#### Consulta de status do pagamento - GET /proxy/open-banking/payments/v4/pix/payments/{paymentId}

Permite a consulta do status e as informações de um pagamento.

Uma explicação detalhada da máquina de estados do status do pagamento pode ser
encontrada na [documentação oficial](https://openfinancebrasil.atlassian.net/wiki/spaces/OF/pages/347078805/M+quina+de+Estados+-+v4.0.0+-+SV+Pagamentos)
do Open Finance Brasil.

#### Revogação do pagamento - PATCH /proxy/open-banking/payments/v4/pix/payments/{paymentId}

Permite a revogação de um pagamento.

É permitido realizar a revogação de um pagamento após a iniciação do pagamento e
se o pagamento for do tipo PIX agendado (SCHEDULED).

Nos casos de sucesso, a resposta terá código HTTP 200
e conterá as informações da revogação juntamente com as informações do pagamento
iniciado.

Já para os casos de falha na criação do pagamento, a Detentora retornará
HTTP 422 Unprocessable Entity com o código referente ao erro ocorrido.
Para mais informações sobre os códigos de erro durante a revogação do pagamento PIX,
consultar a [documentação oficial](https://openfinancebrasil.atlassian.net/wiki/spaces/OF/pages/347078657/v4.0.0+-+SV+Pagamentos)
(seção *"Informações Técnicas - Pagamentos"*, schema `422ResponseErrorCreatePixPayment`).

Exemplo de request:

Request Body:

```json
{
  "data": {
      "status": "CANC",
      "cancellation": {
        "cancelledBy": {
          "document": {
            "identification": "12312312387",
            "rel": "CPF"
          }
        }
      }
    }
}
```

Response Error no formato JSON - resposta é retornada no formato JWT:

```json
{
  "errors": [
    {
      "code": "PAGAMENTO_NAO_PERMITE_CANCELAMENTO",
      "title": "Pagamento não permite cancelamento",
      "detail": "Pagamento não permite cancelamento"
    }
  ],
  "aud": "27aea8f6-2119-55f8-9553-5ad4b08eeb17",
  "iss": "27aea8f6-2119-55f8-9553-5ad4b08eeb17",
  "jti": "3f47c50e-3a19-4d16-905c-8eb61102b0da",
  "iat": 1689103922,
  "meta": {
    "requestDateTime": "2023-07-11T19:32:02Z"
  }
}
```

#### Revogação de pagamentos - PATCH /proxy/open-banking/payments/v4/pix/payments/consents/{consentId}

Permite a revogação de todos os pagamentos referentes ao mesmo consentimento.

É permitido realizar a revogação de um pagamento após a iniciação do pagamento e
se o pagamento estiver nas seguintes situações: Agendada com sucesso (SCHD) ou
retida para análise (PDNG).

Nos casos de sucesso, a resposta terá código HTTP 200
e conterá as informações da revogação juntamente com as informações do pagamento
iniciado.

Já para os casos de falha na criação do pagamento, a Detentora retornará
HTTP 422 Unprocessable Entity com o código referente ao erro ocorrido.
Para mais informações sobre os códigos de erro durante a revogação do pagamento PIX,
consultar a [documentação oficial](https://openfinancebrasil.atlassian.net/wiki/spaces/OF/pages/347078657/v4.0.0+-+SV+Pagamentos)
(seção *"Informações Técnicas - Pagamentos"*, schema `422ResponseErrorCreatePixPayment`).

Exemplo de request:

Request Body:

```json
{
  "data": {
      "status": "CANC",
      "cancellation": {
        "cancelledBy": {
          "document": {
            "identification": "12312312387",
            "rel": "CPF"
          }
        }
      }
    }
}
```

Response Error no formato JSON - resposta é retornada no formato JWT:

```json
{
  "errors": [
    {
      "code": "PAGAMENTO_NAO_PERMITE_CANCELAMENTO",
      "title": "Pagamento não permite cancelamento",
      "detail": "Pagamento não permite cancelamento"
    }
  ],
  "aud": "27aea8f6-2119-55f8-9553-5ad4b08eeb17",
  "iss": "27aea8f6-2119-55f8-9553-5ad4b08eeb17",
  "jti": "3f47c50e-3a19-4d16-905c-8eb61102b0da",
  "iat": 1689103922,
  "meta": {
    "requestDateTime": "2023-07-11T19:32:02Z"
  }
}
```

#### Consulta de status do consentimento - GET /opus-open-finance/payments/v1/consents/{consentId}

Permite a consulta do status e as informações de um consentimento.

Uma explicação detalhada da máquina de estados do status do consentimento pode ser
encontrada na [documentação oficial](https://openfinancebrasil.atlassian.net/wiki/spaces/OF/pages/347078805/M+quina+de+Estados+-+v4.0.0+-+SV+Pagamentos)
do Open Finance Brasil.

### Iniciação de pagamento automático

#### POST /proxy/open-banking/automatic-payments/v1/pix/recurring-payments

Após a aprovação do consentimento,
é necessário requisitar o início da transação do pagamento junto à Detentora de Conta.

Nos casos de sucesso, a resposta terá código HTTP 201 Created
e conterá as informações do pagamento iniciado.
O consentimento associado terá seu status **CONSUMED** após atingir
algum dos limites globais de transações.

> É necessário consultar o status do pagamento iniciado
(ex.: através de *polling* no endpoint descrito abaixo)
para verificar quando/se ele foi de fato realizado.

Já para os casos de falha na criação do pagamento, a Detentora retornará
HTTP 422 Unprocessable Entity com o código referente ao erro ocorrido,
e o status de seu consentimento se tornará **REJECTED**.
Para mais informações sobre os códigos de erro durante a criação do pagamento PIX,
consultar a [documentação oficial](https://openfinancebrasil.atlassian.net/wiki/spaces/OF/pages/345178113/v1.0.0+SV+Pagamentos+Autom+ticos)
(seção *"Informações Técnicas - Pagamentos Automáticos"*, schema `422ResponseErrorCreatePixRecurringPayment`).

Exemplo de request com amount (100.00) diferente do definido no consentimento (10.00):

Request Body:

```json
{
    "data": {
      "localInstrument": "MANU",
      "payment": {
        "amount": "100.00",
        "currency": "BRL"
      },
      "creditorAccount": {
        "ispb": "12345678",
        "issuer": "1774",
        "number": "1234567890",
        "accountType": "CACC"
      },
      "remittanceInformation": "Pagamento da nota XPTO035-002.",
      "cnpjInitiator": "00000000000191"
    }
  }
```

Response Error no formato JSON - resposta é retornada no formato JWT:

```json
{
  "errors": [
    {
      "code": "PAGAMENTO_DIVERGENTE_DO_CONSENTIMENTO",
      "title": "divergência entre pagamento e consentimento",
      "detail": "Dados do pagamento divergentes dos dados do consentimento"
    }
  ],
  "meta": {
    "requestDateTime": "2021-05-21T08:30:00Z"
  },
  "aud": "27aea8f6-2119-55f8-9553-5ad4b08eeb17",
  "iss": "27aea8f6-2119-55f8-9553-5ad4b08eeb17",
  "jti": "db068223-50bd-4342-b462-01434a9df172",
  "iat": 1656965998
}
```

#### Consulta de pagamentos associados a um consentimento - GET /proxy/open-banking/automatic-payments/v1/pix/recurring-payments

Permite a consulta do status e as informações de pagamento associados a um consentimento.

Uma explicação detalhada da máquina de estados do status do pagamento pode ser
encontrada na [documentação oficial](https://openfinancebrasil.atlassian.net/wiki/spaces/OF/pages/345178187/M+quina+de+Estados+-+v1.0.0+-+SV+Pagamentos+Autom+ticos)
do Open Finance Brasil.

#### Consulta de status do pagamento automático - GET /proxy/open-banking/automatic-payments/v1/pix/recurring-payments/{recurringPaymentId}

Permite a consulta do status e as informações de um pagamento automático.

Uma explicação detalhada da máquina de estados do status do pagamento pode ser
encontrada na [documentação oficial](https://openfinancebrasil.atlassian.net/wiki/spaces/OF/pages/345178187/M+quina+de+Estados+-+v1.0.0+-+SV+Pagamentos+Autom+ticos)
do Open Finance Brasil.

#### Revogação do pagamento - PATCH /proxy/open-banking/automatic-payments/v1/pix/recurring-payments/{recurringPaymentId}

Permite a revogação de um pagamento.

É permitido realizar a revogação de um pagamento após a iniciação do pagamento e
se o pagamento estiver nas seguintes situações: Agendada com sucesso (SCHD) ou retida
para análise (PDNG).

Nos casos de sucesso, a resposta terá código HTTP 200
e conterá as informações da revogação juntamente com as informações do pagamento
iniciado.

Já para os casos de falha na revogação do pagamento, a Detentora retornará
HTTP 422 Unprocessable Entity com o código referente ao erro ocorrido.
Para mais informações sobre os códigos de erro durante a revogação do pagamento PIX,
consultar a [documentação oficial](https://openfinancebrasil.atlassian.net/wiki/spaces/OF/pages/345178113/v1.0.0+SV+Pagamentos+Autom+ticos)
(seção *"Informações Técnicas - Pagamentos Automáticos"*, schema `422ResponseErrorCreateRecurringPaymentsPaymentId`).

Exemplo de request:

Request Body:

```json
{
  "data": {
    "status": "REJECTED",
    "cancellation": {
      "cancelledBy": {
        "document": {
          "identification": "11111111111",
          "rel": "CPF"
        }
      }
    }
  }
}
```

Response Error no formato JSON - resposta é retornada no formato JWT:

```json
{
  "errors": [
    {
      "code": "PAGAMENTO_NAO_PERMITE_CANCELAMENTO",
      "title": "Pagamento não permite cancelamento",
      "detail": "Pagamento não permite cancelamento"
    }
  ],
  "meta": {
    "requestDateTime": "2021-05-21T08:30:00Z"
  },
  "aud": "27aea8f6-2119-55f8-9553-5ad4b08eeb17",
  "iss": "27aea8f6-2119-55f8-9553-5ad4b08eeb17",
  "jti": "3f47c50e-3a19-4d16-905c-8eb61102b0da",
  "iat": 1689103922
}
```

#### Consulta de status do consentimento - GET /opus-open-finance/automatic-payments/v1/recurring-consents/{recurringConsentId}

Permite a consulta do status e as informações de um consentimento de pagamento automático.

Uma explicação detalhada da máquina de estados do status do consentimento pode ser
encontrada na [documentação oficial](https://openfinancebrasil.atlassian.net/wiki/spaces/OF/pages/345178187/M+quina+de+Estados+-+v1.0.0+-+SV+Pagamentos+Autom+ticos)
do Open Finance Brasil.

#### Revogação de consentimento - PATCH /opus-open-finance/automatic-payments/v1/recurring-consents/{recurringConsentId}

Permite a revogação de um consentimento.

É permitido realizar a revogação de um consentimento após a criação do
consentimento e se o consentimento estiver com status **AUTHORIZED**.

Nos casos de sucesso, a resposta terá código HTTP 200
e conterá as informações da revogação juntamente com as informações do consentimento.

Já para os casos de falha na revogação do pagamento, a Detentora retornará
HTTP 422 Unprocessable Entity com o código referente ao erro ocorrido.
Para mais informações sobre os códigos de erro durante a revogação do pagamento PIX,
consultar a [documentação oficial](https://openfinancebrasil.atlassian.net/wiki/spaces/OF/pages/345178113/v1.0.0+SV+Pagamentos+Autom+ticos)
(seção *"Informações Técnicas - Pagamentos Automáticos"*, schema `422ResponseErrorRecurringConsents`).

Exemplo de request:

Request Body:

```json
{
  "data": {
    "status": "REVOKED",
    "revocation": {
      "revokedBy": "INICIADORA",
      "revokedFrom": "DETENTORA",
      "reason": {
        "code": "REVOGADO_RECEBEDOR",
        "detail": "string"
      }
    }
  }
}
```

Response Error no formato JSON - resposta é retornada no formato JWT:

```json
{
  "errors": [
    {
      "code": "PAGAMENTO_NAO_PERMITE_CANCELAMENTO",
      "title": "Pagamento não permite cancelamento",
      "detail": "Pagamento não permite cancelamento"
    }
  ],
  "meta": {
    "requestDateTime": "2021-05-21T08:30:00Z"
  },
  "aud": "27aea8f6-2119-55f8-9553-5ad4b08eeb17",
  "iss": "27aea8f6-2119-55f8-9553-5ad4b08eeb17",
  "jti": "3f47c50e-3a19-4d16-905c-8eb61102b0da",
  "iat": 1689103922
}
```

## APIs

| Tipo Request   | Endpoint                                                                                             | Descrição                                                          | Sucesso  |
| -------------- | ---------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------ | -------- |
| POST           | /opus-open-finance/payments/v1/consents                                                              | Criação de um consentimento de pagamento                           | 201      |
| GET            | /opus-open-finance/payments/v1/consents/{consentId}                                                  | Obtenção dos dados do consentimento de pagamento                   | 200      |
| POST           | /opus-open-finance/payments/v1/consents/{consentId}/authorisation-retry                              | Nova tentativa de autorização do consentimento                     | 200      |
| POST           | /proxy/open-banking/payments/v2/pix/payments                                                         | Criação de um pagamento                                            | 201      |
| GET            | /proxy/open-banking/payments/v2/pix/payments/{paymentId}                                             | Obtenção dos dados do pagamento                                    | 200      |
| PATCH          | /proxy/open-banking/payments/v2/pix/payments/{paymentId}                                             | Revogação de um pagamento                                          | 200      |
| POST           | /proxy/open-banking/payments/v3/pix/payments                                                         | Criação de um pagamento                                            | 201      |
| GET            | /proxy/open-banking/payments/v3/pix/payments/{paymentId}                                             | Obtenção dos dados do pagamento                                    | 200      |
| PATCH          | /proxy/open-banking/payments/v3/pix/payments/{paymentId}                                             | Revogação de um pagamento                                          | 200      |
| POST           | /proxy/open-banking/payments/v4/pix/payments                                                         | Criação de um pagamento                                            | 201      |
| GET            | /proxy/open-banking/payments/v4/pix/payments/{paymentId}                                             | Obtenção dos dados do pagamento                                    | 200      |
| PATCH          | /proxy/open-banking/payments/v4/pix/payments/{paymentId}                                             | Revogação de um pagamento                                          | 200      |
| PATCH          | /proxy/open-banking/payments/v4/pix/payments/consents/{consentId}                                    | Revogação de todos os pagamentos referentes ao mesmo consentimento | 200      |
| GET            | /opus-open-finance/dcm                                                                               | Obtenção dos dados de dcm dos brand clients                        | 200      |
| PUT            | /opus-open-finance/dcm                                                                               | Atualização dos dados de dcm dos brand clients                     | 200      |
| POST           | /opus-open-finance/automatic-payments/v1/recurring-consents                                          | Criação de um consentimento de pagamento automático                | 201      |
| GET            | /opus-open-finance/automatic-payments/v1/recurring-consents/{recurringConsentId}                     | Obtenção dos dados do consentimento de pagamento automático        | 200      |
| PATCH          | /opus-open-finance/automatic-payments/v1/recurring-consents/{recurringConsentId}                     | Revogação de um consentimento de pagamento automático              | 200      |
| POST           | /opus-open-finance/automatic-payments/v1/recurring-consents/{recurringConsentId}/authorisation-retry | Nova tentativa de autorização do consentimento                     | 200      |
| POST           | /proxy/open-banking/automatic-payments/v1/pix/recurring-payments                                     | Criação de um pagamento automático                                 | 201      |
| GET            | /proxy/open-banking/automatic-payments/v1/pix/recurring-payments                                     | Obtenção dos dados dos pagamentos associados a um consentimento    | 200      |
| GET            | /proxy/open-banking/automatic-payments/v1/pix/recurring-payments/{recurringPaymentId}                | Obtenção dos dados de um pagamento automático                      | 200      |
| PATCH          | /proxy/open-banking/automatic-payments/v1/pix/recurring-payments/{recurringPaymentId}                | Revogação de um pagamento automático                               | 200      |

## Orientações importantes

- Todas as datas seguem o padrão da [RFC3339](https://datatracker.ietf.org/doc/html/rfc3339)
e formato "zulu".
