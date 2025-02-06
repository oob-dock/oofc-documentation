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

### Iniciação de pagamento sem redirecionamento

#### Vínculo de dispositivo

##### Criar vínculo de conta. - POST /opus-open-finance/enrollments/v1/enrollments

Permite criar um novo vínculo de conta. 
Retorna um enrollment em status AWAITING_RISK_SIGNALS.

Uma explicação detalhada da máquina de estados do status do vínculo pode ser
encontrada na [documentação oficial](https://openfinancebrasil.atlassian.net/wiki/spaces/OF/pages/640286815/M+quina+de+estados+-+v2.0.0-+SV+V+nculo+de+dispositivo)
do Open Finance Brasil.

Exemplo de request:

Request Body:

```json
{
  "data": {
    "callbackApplicationUri":"https://client-callback-url.com/",
    "loggedUser": {
      "document": {
        "identification": "11111111111",
        "rel": "CPF"
      }
    },
    "permissions": [
      "PAYMENTS_INITIATE"
    ],
    "businessEntity": {
      "document": {
        "identification": "11111111111111",
        "rel": "CNPJ"
      }
    },
    "debtorAccount": {
      "ispb": "12345678",
      "issuer": "1774",
      "number": "1234567890",
      "accountType": "CACC"
    },
    "enrollmentName": "Nome Dispositivo"
  }
}
```

Response Body:

```json
{
   "data": {
        "enrollmentId": "urn:amazingbank:0b9d8d77-a9bd-416c-a5cd-29f079c7d41b",
        "enrollment": "eyJraWQiOiJoRUhYZ21BRS1IVlBVZUNEUFNjblpQVzZkWGp3dWIwLTJuQng2SHZMOUNrIiwidHlwIjoiSldUIiwiYWxnIjoiUFMyNTYifQ.eyJhdWQiOiIyN2FlYThmNi0yMTE5LTU1ZjgtOTU1My01YWQ0YjA4ZWViMTciLCJkYXRhIjp7ImVucm9sbG1lbnRJZCI6InVybjphbWF6aW5nYmFuazowYjlkOGQ3Ny1hOWJkLTQxNmMtYTVjZC0yOWYwNzljN2Q0MWIiLCJjcmVhdGlvbkRhdGVUaW1lIjoiMjAyNC0xMi0xMlQxMTo0MDozMVoiLCJzdGF0dXNVcGRhdGVEYXRlVGltZSI6IjIwMjQtMTItMTJUMTE6NDA6MzFaIiwic3RhdHVzIjoiQVdBSVRJTkdfUklTS19TSUdOQUxTIiwicGVybWlzc2lvbnMiOlsiUEFZTUVOVFNfSU5JVElBVEUiXSwibG9nZ2VkVXNlciI6eyJkb2N1bWVudCI6eyJpZGVudGlmaWNhdGlvbiI6IjEyMzEyMzEyMzg3IiwicmVsIjoiQ1BGIn19LCJkZWJ0b3JBY2NvdW50Ijp7ImlzcGIiOiIxMjM0NTY3OCIsImlzc3VlciI6IjE3NzQiLCJudW1iZXIiOiIxMjM0NTY3ODkwIiwiYWNjb3VudFR5cGUiOiJDQUNDIn0sImVucm9sbG1lbnROYW1lIjoiTm9tZSBEaXNwb3NpdGl2byJ9LCJtZXRhIjp7InJlcXVlc3REYXRlVGltZSI6IjIwMjQtMTItMTJUMTE6NDA6MzFaIn0sImlzcyI6IjI3YWVhOGY2LTIxMTktNTVmOC05NTUzLTVhZDRiMDhlZWIxNyIsImxpbmtzIjp7InNlbGYiOiJodHRwczovL210bHMtb2JiLnFhLm9vYi5vcHVzLXNvZnR3YXJlLmNvbS5ici9vcGVuLWJhbmtpbmcvZW5yb2xsbWVudHMvdjIvZW5yb2xsbWVudHMvdXJuOmFtYXppbmdiYW5rOjBiOWQ4ZDc3LWE5YmQtNDE2Yy1hNWNkLTI5ZjA3OWM3ZDQxYiJ9LCJpYXQiOjE3MzQwMDM2MzEsImp0aSI6IjI2N2EwOGFjLTViNGQtNDViYS1hOWNmLTllM2M4MDUxYWZhMiJ9.QxXNbSlzBIlLPY8qTNEy5dI_0BTCbauadj2vkKm8ytW7GDeNQKwbMMnUXe9MrtmCpxBRa762IvsSCsTMjJfWzwTGnY99pkoW5gY3uOSyBFpsMiSy3zhFQYFcBbaYZmVqUKzKSBZB2-Kw4TNJQ5_-nA2ZOBYMEs1VNkoqsqtHmnKkYHx10HbDT_LCGfFPCveoZn1smEEU-uPtMv8FZf88WRqa4qCW8cDsaW7HbmNn2XjL6oU5ozHIna3tldhcoFG-w3kEJkidbWs6Uyh579TnfOgof33YoORDWvAETJWHqZBNiLAwqT96yM_vcEER6Fz44U90QEEv7dW-w1Pi3FZAYw"
    }
}
```

##### Consulta de vínculo de conta - GET /opus-open-finance/enrollments/v1/enrollments/{enrollmentId}

Permite consultar um vínculo de conta para iniciação de pagamento sem redirecionamento.

##### Rejeição o revogação de vínculo de conta - PATCH /opus-open-finance/enrollments/v1/enrollments/{enrollmentId}

Permite revogar ou rejeitar um vínculo de conta. Após a execução com sucesso
deste método irreversível, o vínculo de conta não poderá mais ser utilizado para
autenticação nem autorização de iniciação de pagamentos. Os conceitos de revogação
e rejeição estão associados à máquina de estados do vínculo de conta:

• Revogação: Cancelamento de um vínculo de conta no status "AUTHORISED";

• Rejeição: Cancelamento do vínculo de conta nos status "AWATING_RISK_SIGNALS",
"AWATING_ENROLLMENT" e "AWAITING_ACCOUNT_HOLDER_VALIDATION"

Cabe ao cliente desta API distinguir entre os dois cenários para determinar o
motivo adequado.

Exemplo de request:

Request Body:

```json
{
  "data": {
    "cancellation": {
      "cancelledBy": {
        "document": {
          "identification": "12312312387",
          "rel": "CPF"
        }
      },
      "reason": {
        "rejectionReason": "REJEITADO_TEMPO_EXPIRADO_RISK_SIGNALS"
      },
      "additionalInformation": "Contrato entre iniciadora e detentora interrompido"
    }
  }
}
```

##### Envio de sinais de risco para iniciação do vínculo de dispositivo - POST /opus-open-finance/enrollments/v1/enrollments/{enrollmentId}/risk-signals

Permite o envio de sinais de risco para iniciação do vínculo de dispositivo, o
status do enrollment deve estar em "AWAITING_RISK_SIGNALS".
Após recebimento com sucesso dos sinais, o status do enrollment deve transitar
para "AWAITING_ACCOUNT_HOLDER_VALIDATION".

Uma vez recebido a url de redirecionamento, o cliente será levado para a
detentora para concluir o processo de iniciação do vínculo de dispositivo.
Ao concluir o processo da detentora com sucesso em menos de 15 minutos, o status
do enrollment deve transitar para "AWAITING_ENROLLMENT".
Caso contrário o status deve transitar para "REJECTED".

Uma explicação detalhada da máquina de estados do status do vínculo pode ser
encontrada na [documentação oficial](https://openfinancebrasil.atlassian.net/wiki/spaces/OF/pages/640286815/M+quina+de+estados+-+v2.0.0-+SV+V+nculo+de+dispositivo)
do Open Finance Brasil.

Exemplo de request:

Request Body:

```json
{
  "data": {
    "deviceId": "00aa11bb22cc33dd",
    "isRootedDevice": false,
    "screenBrightness": 255,
    "elapsedTimeSinceBoot": 6356027,
    "osVersion": "14",
    "userTimeZoneOffset": "-03",
    "language": "pt",
    "screenDimensions": {
      "height": 2340,
      "width": 1080
    },
    "accountTenure": "2023-08-20",
    "geolocation": {
      "latitude": -15.738602,
      "longitude": -47.926498,
      "type": "FINE"
    },
    "isCallingProgress": false,
    "isDevModeEnabled": false,
    "isMockGPS": false,
    "isEmulated": false,
    "isMonkeyRunner": false,
    "isCharging": false,
    "antennaInformation": "CellIdentityLte:{ mCi=2******60 mPci=274 mTac=5***1 mEarfcn=9510 mBands=[28] mBandwidth=2147483647 mMcc=724 mMnc=10 mAlphaLong=VIVO mAlphaShort=VIVO mAdditionalPlmns={} mCsgInfo=null}, CellIdentityLte:{ mCi=1*****01 mPci=361 mTac=3***6 mEarfcn=9410 mBands=[28] mBandwidth=2147483647 mMcc=724 mMnc=03 mAlphaLong=TIMBRASIL mAlphaShort=TIMBRASIL mAdditionalPlmns={} mCsgInfo=null}",
    "isUsbConnected": false,
    "integrity": {
      "appRecognitionVerdict": "PLAY_RECOGNIZED",
      "deviceRecognitionVerdict": "[\\\"MEETS_DEVICE_INTEGRITY\\\"]"
    }
  }
}
```

Response Body:

```json
{
   "data": {
    "redirectUrl": "https://obb.qa.oob.opus-software.com.br/auth/auth?client_id=8tOS2yj_vfAHagBC-5mSF&scope=openid%20payments%20nrp-consents%20enrollment%3Aurn%3Aamazingbank%3A4d0a6b31-d898-4145-a772-1cdc6b78342a&response_type=code%20id_token&redirect_uri=https%3A%2F%2Foob.127.0.0.1.nip.io%3A3005%2Fopus-open-finance%2Fenrollments%2Fredirect-uri%2Fapp-opus-1&request_uri=urn%3Aietf%3Aparams%3Aoauth%3Arequest_uri%3AY3SJ9Y2FqEiZMOnvrNP26"
   }
}
```

##### Obter parâmetros para criação de credenciais FIDO2 - POST /proxy/open-banking/enrollments/v1/enrollments/{enrollmentId}/fido-registration-options

Método para obter os parâmetros para criação de uma nova credencial FIDO2. Um novo
challenge deve ser criado a cada chamada. Os parâmetros da resposta devem ser
compatíveis com a definição [W3C](https://www.w3.org/TR/webauthn-2/#dictionary-makecredentialoptions)

Exemplo de request:

Request Body:

```json
{
  "data": {
    "rp": "tpp-client1.127.0.0.1.nip.io",
    "platform": "ANDROID"
  }
}
```

Response Body - formato JWT:

eyJraWQiOiJoRUhYZ21BRS1IVlBVZUNEUFNjblpQVzZkWGp3dWIwLTJuQng2SHZMOUNrIiwidHlwIjoiSldUIiwiYWxnIjoiUFMyNTYifQ.eyJhdWQiOiIyN2FlYThmNi0yMTE5LTU1ZjgtOTU1My01YWQ0YjA4ZWViMTciLCJkYXRhIjp7ImVucm9sbG1lbnRJZCI6InVybjphbWF6aW5nYmFuazpmODM1NTNhYS02ODFjLTQ5MzUtOTJjOC05NGI1MzUxMzc0NDYiLCJycCI6eyJpZCI6InRwcC1jbGllbnQxLjEyNy4wLjAuMS5uaXAuaW8iLCJuYW1lIjoiT09CIENsaWVudCBVbSJ9LCJ1c2VyIjp7ImlkIjoiWm1aaU5tRmpaakV0TldZd1pTMDBPR0ZqTFdJNE1EZ3RaVFF5WW1JeE5qRXdPR0k0IiwibmFtZSI6InVybjphbWF6aW5nYmFuazpmODM1NTNhYS02ODFjLTQ5MzUtOTJjOC05NGI1MzUxMzc0NDYiLCJkaXNwbGF5TmFtZSI6IlJlcXVpcmVyIEd1eSJ9LCJjaGFsbGVuZ2UiOiIxeW54dnl4elF6S0RkY082OEhjTElnIiwicHViS2V5Q3JlZFBhcmFtcyI6W3siYWxnIjotNjU1MzUsInR5cGUiOiJwdWJsaWMta2V5In0seyJhbGciOi0yNTcsInR5cGUiOiJwdWJsaWMta2V5In0seyJhbGciOi0yNTgsInR5cGUiOiJwdWJsaWMta2V5In0seyJhbGciOi0yNTksInR5cGUiOiJwdWJsaWMta2V5In0seyJhbGciOi03LCJ0eXBlIjoicHVibGljLWtleSJ9LHsiYWxnIjotMzUsInR5cGUiOiJwdWJsaWMta2V5In0seyJhbGciOi0zNiwidHlwZSI6InB1YmxpYy1rZXkifSx7ImFsZyI6LTgsInR5cGUiOiJwdWJsaWMta2V5In1dLCJleGNsdWRlQ3JlZGVudGlhbHMiOltdLCJhdXRoZW50aWNhdG9yU2VsZWN0aW9uIjp7InVzZXJWZXJpZmljYXRpb24iOiJwcmVmZXJyZWQiLCJyZXF1aXJlUmVzaWRlbnRLZXkiOmZhbHNlLCJyZXNpZGVudEtleSI6ImRpc2NvdXJhZ2VkIn0sImF0dGVzdGF0aW9uIjoibm9uZSJ9LCJtZXRhIjp7InJlcXVlc3REYXRlVGltZSI6IjIwMjQtMTItMTdUMTQ6Mzk6MTVaIn0sImlzcyI6IjI3YWVhOGY2LTIxMTktNTVmOC05NTUzLTVhZDRiMDhlZWIxNyIsImlhdCI6MTczNDQ0NjM1NSwianRpIjoiZWI3NzdlZjYtNzVmNC00NDAyLWIyNTctNjNiM2MxNGQ2YWZlIn0.QcvTIxeKmHQ2NypdFLiXitzdlqroxizIVCsPyAHWuqbMiA1WPaX07nYYEIHJR4n8b4IrDh3rkGfnGs4ie-8Ra5UFtsCUgMBWNN6brmxkLioeauNZjdX71vtDwjHwvWefXA88c-rwk0urNtcSsHJWgblx0QEbnFt9R-PqRWcrlFFBZynCXcWR53K2Hclyju_Qack82sh4YDp_vTF6NwKzjNnNfYaDhgMKNjcUQu4a5pISF52uI8oE9cwuqeW8E0MmikiHzD7W3NiY_ffRxdzBAqKa58dbqG8l98-aQcbTjh0QpJiYokQM5pPhhibnUvhNSfjtV8-s6OiqSP5LDgGGWw

##### Associação da credencial FIDO2 ao vínculo de conta - POST /proxy/open-banking/enrollments/v1/enrollments/{enrollmentId}/fido-registration

O vínculo de conta deve estar no status "AWAITING_ENROLLMENT". Após o registro
com sucesso, o vínculo de conta deve transitar ao status "AUTHORISED". A falha de
verificação da credencial FIDO2 deve causar a rejeição do vínculo de conta por
parte da detentora, uma vez que não é possível reusar um mesmo "challenge" para
mais de um registro.

Exemplo de request:

Request Body:

```json
{
  "data": {
    "id": "dChFBsqJa5Bx8G5vUcNZ14wwA0s",
    "rawId": "dChFBsqJa5Bx8G5vUcNZ14wwA0s",
    "response": {
      "clientDataJSON": "eyJ0eXBlIjoid2ViYXV0aG4uY3JlYXRlIiwiY2hhbGxlbmdlIjoiMXlueHZ5eHpRektEZGNPNjhIY0xJZyIsIm9yaWdpbiI6Imh0dHBzOi8vdHBwLWNsaWVudDEuMTI3LjAuMC4xLm5pcC5pbzozMDA1IiwiY3Jvc3NPcmlnaW4iOmZhbHNlfQ",
      "attestationObject": "o2NmbXRkbm9uZWdhdHRTdG10oGhhdXRoRGF0YViYuaPcaIs3vOvomUZNWT85Y-SvtFN4ugAsg6-Cpli-WaddAAAAAPv8MAcVTk7MjAtuAgVX170AFHQoRQbKiWuQcfBub1HDWdeMMANLpQECAyYgASFYIB-TUaUPl98PPse5YWj1Z_MG6Kom_lnK_4eVCpMdH-mzIlggpuIxfx_WS5R4ICIvLt_qu5o6fuSk1xzd8hHbOcpgV3g"
    },
    "type": "public-key"
  }
}
```

##### Obter parâmetros para autenticação FIDO2 - POST /opus-open-finance/enrollments/v1/enrollments/{enrollmentId}/fido-sign-options

Método para obter os parâmetros para autenticação a partir de uma credencial FIDO2
previamente registrada. Um novo challenge deve ser criado a cada chamada.
Os parâmetros da resposta devem ser compatíveis com a definição [W3C](https://www.w3.org/TR/webauthn-2/#dictionary-assertion-options).

Exemplo de request:

Request Body:

```json
{
  "data": {
    "rp": "tpp-client1.127.0.0.1.nip.io",
    "platform": "ANDROID",
    "consentId": "urn:amazingbank:f83553aa-681c-4935-92c8-94b535137446"
  }
}
```

Response Body:

```json
{
  "data": "eyJraWQiOiJoRUhYZ21BRS1IVlBVZUNEUFNjblpQVzZkWGp3dWIwLTJuQng2SHZMOUNrIiwidHlwIjoiSldUIiwiYWxnIjoiUFMyNTYifQ.eyJhdWQiOiIyN2FlYThmNi0yMTE5LTU1ZjgtOTU1My01YWQ0YjA4ZWViMTciLCJkYXRhIjp7ImNoYWxsZW5nZSI6ImY4R2pfQVVKUUZ1OFUwaHlMalFmVFEiLCJycElkIjoidHBwLWNsaWVudDEuMTI3LjAuMC4xLm5pcC5pbyIsImFsbG93Q3JlZGVudGlhbHMiOlt7ImlkIjoiZENoRkJzcUphNUJ4OEc1dlVjTloxNHd3QTBzIiwidHlwZSI6InB1YmxpYy1rZXkifV0sInVzZXJWZXJpZmljYXRpb24iOiJwcmVmZXJyZWQifSwibWV0YSI6eyJyZXF1ZXN0RGF0ZVRpbWUiOiIyMDI0LTEyLTE3VDE0OjQwOjI1WiJ9LCJpc3MiOiIyN2FlYThmNi0yMTE5LTU1ZjgtOTU1My01YWQ0YjA4ZWViMTciLCJpYXQiOjE3MzQ0NDY0MjUsImp0aSI6IjA1NmIwMDNiLWJiNzMtNGEzZC1iMDkwLWUxNzA2YTQxNTcyNyJ9.qaBLit6ftdtS2OT_vXRljB8shCq_0OIeZdJlwDY5UI-JaPG3r-bIkT6wibIYObWkJyJ3AzWjHXtsTfBm05L0fcjTLmu49T29H8PPRbtYotaFFuZZqsmNfxjiqRk1Zh4uO2Zh9CFAFTqiD7XYpPc6EdgT9sEYybYFg5iS357dLsdnVg5s8bZ3I-fgMmygzxK53YgwxSmThgzkok98fp6K-1JJDSm74ZYUCE9BLovVNLIs1q8Uv4nGehc8NtQWzT-iNKl3uU5svBMFyhCrdsfIv8Kx1QiV8D3A-1m-KyKO3_CMSFqbpDMgb0x6pSTXXOVypxb25GodW6mjvndp741uFQ"
}
```

##### Autorização de um consentimento de pagamentos na jornada sem redirecionamento - POST /proxy/open-banking/enrollments/v1/consents/{consentId}/authorise

Autorização de um consentimento de pagamentos em status AWAITING_AUTHORISATION a
partir do access_token emitido pela jornada sem redirecionamento e envio de sinais
de risco. Para pagamentos de alçadas únicas, o consentimento de pagamento deve transitar
ao status AUTHORISED na execução com sucesso desse método. Para pagamentos com múltiplas
alçadas aprovadoras, o consentimento de pagamento ficará em PARTIALLY_ACCEPTED
até que todos tenham autorizado. Em caso de falha de negócio (HTTP Status Code 422),
o consentimento de pagamento precisa transitar para o status REJECTED e seguir
os motivos de rejeição presentes na API de pagamentos. Caso a detentora identifique
que a conta de débito informada pelo iniciador na criação do consentimento diverge
da conta de débito vinculada ao dispositivo, o detentor deve retornar o erro
HTTP 422 com código CONTA_DEBITO_DIVERGENTE_CONSENTIMENTO_VINCULO e rejeitar o consentimento
com o motivo CONTA_NAO_PERMITE_PAGAMENTO. Se o iniciador, durante a criação do consentimento,
omitir a conta de débito, o detentor deve considerar a conta de débito associada
ao vínculo para o preenchimento do objeto /data/debtorAccount, presente no consentimento,
após a sua autorização. Os limites relacionados ao vínculo devem ser validados
apenas em momento de liquidação do pagamento, independente dele ser agendado ou imediato.

Exemplo de request:

Request Body:

```json
{
  "data": {
    "enrollmentId": "urn:amazingbank:f83553aa-681c-4935-92c8-94b535137446",
    "riskSignals": {
      "screenBrightness": 90,
      "deviceId": "5ad82a8f-37e5-4369-a1a3-be4b1fb9c034",
      "isRootedDevice": true,
      "elapsedTimeSinceBoot": 28800000,
      "osVersion": "16.6",
      "userTimeZoneOffset": "-03",
      "language": "pt",
      "accountTenure": "2023-01-01",
      "screenDimensions": {
        "width": 1920,
        "height": 1080
      }
    },
    "fidoAssertion": {
      "id": "dChFBsqJa5Bx8G5vUcNZ14wwA0s",
      "rawId": "dChFBsqJa5Bx8G5vUcNZ14wwA0s",
      "response": {
        "clientDataJSON": "eyJ0eXBlIjoid2ViYXV0aG4uZ2V0IiwiY2hhbGxlbmdlIjoiZjhHal9BVUpRRnU4VTBoeUxqUWZUUSIsIm9yaWdpbiI6Imh0dHBzOi8vdHBwLWNsaWVudDEuMTI3LjAuMC4xLm5pcC5pbzozMDA1IiwiY3Jvc3NPcmlnaW4iOmZhbHNlfQ",
        "authenticatorData": "uaPcaIs3vOvomUZNWT85Y-SvtFN4ugAsg6-Cpli-WacdAAAAAA",
        "signature": "MEYCIQDnH28G2uBCPktUSodK8dBuNma2ftwDxTZxSesb0jGGhQIhAJR3Pvttqw_RbSNsdFYpVIb1fO7vZVk3OwY2n_P4Ue7T",
        "userHandle": "ZmZiNmFjZjEtNWYwZS00OGFjLWI4MDgtZTQyYmIxNjEwOGI4"
      },
      "type": "public-key"
    }
  }
}
```

## APIs

| Tipo Request   | Endpoint                                                                                             | Descrição                                     | Sucesso  |
| -------------- | ---------------------------------------------------------------------------------------------------- | --------------------------------------------- | -------- |
| POST           | /opus-open-finance/payments/v1/consents                                                              | Criação de um consentimento de pagamento                                     | 201      |
| GET            | /opus-open-finance/payments/v1/consents/{consentId}                                                  | Obtenção dos dados do consentimento de pagamento                    | 200      |
| POST           | /opus-open-finance/payments/v1/consents/{consentId}/authorisation-retry                              | Nova tentativa de autorização do consentimento                                 | 200      |
| POST           | /proxy/open-banking/payments/v2/pix/payments                                                         | Criação de um pagamento                                     | 201      |
| GET            | /proxy/open-banking/payments/v2/pix/payments/{paymentId}                                             | Obtenção dos dados do pagamento                                     | 200      |
| PATCH          | /proxy/open-banking/payments/v2/pix/payments/{paymentId}                                             | Revogação de um pagamento                                     | 200      |
| POST           | /proxy/open-banking/payments/v3/pix/payments                                                         | Criação de um pagamento                                     | 201      |
| GET            | /proxy/open-banking/payments/v3/pix/payments/{paymentId}                                             | Obtenção dos dados do pagamento                                     | 200      |
| PATCH          | /proxy/open-banking/payments/v3/pix/payments/{paymentId}                                             | Revogação de um pagamento                                     | 200      |
| POST           | /proxy/open-banking/payments/v4/pix/payments                                                         | Criação de um pagamento                                     | 201      |
| GET            | /proxy/open-banking/payments/v4/pix/payments/{paymentId}                                             | Obtenção dos dados do pagamento                                     | 200      |
| PATCH          | /proxy/open-banking/payments/v4/pix/payments/{paymentId}                                             | Revogação de um pagamento                                     | 200      |
| PATCH          | /proxy/open-banking/payments/v4/pix/payments/consents/{consentId}                                    | Revogação de todos os pagamentos referentes ao mesmo consentimento             | 200      |
| GET            | /opus-open-finance/dcm                                                                               | Obtenção dos dados de dcm dos brand clients                                 | 200      |
| PUT            | /opus-open-finance/dcm                                                                               | Atualização dos dados de dcm dos brand clients                                 | 200      |
| POST           | /opus-open-finance/automatic-payments/v1/recurring-consents                                          | Criação de um consentimento de pagamento automático                          | 201      |
| GET            | /opus-open-finance/automatic-payments/v1/recurring-consents/{recurringConsentId}                     | Obtenção dos dados do consentimento de pagamento automático         | 200      |
| PATCH          | /opus-open-finance/automatic-payments/v1/recurring-consents/{recurringConsentId}                     | Revogação de um consentimento de pagamento automático                          | 200      |
| POST           | /opus-open-finance/automatic-payments/v1/recurring-consents/{recurringConsentId}/authorisation-retry | Nova tentativa de autorização do consentimento                                 | 200      |
| POST           | /proxy/open-banking/automatic-payments/v1/pix/recurring-payments                                     | Criação de um pagamento automático                                    | 201      |
| GET            | /proxy/open-banking/automatic-payments/v1/pix/recurring-payments                                     | Obtenção dos dados dos pagamentos associados a um consentimento      | 200      |
| GET            | /proxy/open-banking/automatic-payments/v1/pix/recurring-payments/{recurringPaymentId}                | Obtenção dos dados de um pagamento automático                          | 200      |
| PATCH          | /proxy/open-banking/automatic-payments/v1/pix/recurring-payments/{recurringPaymentId}                | Revogação de um pagamento automático                                    | 200      |
| POST           | opus-open-finance/enrollments/v1/enrollments                                                         | Criar vínculo de conta                                         | 200      |
| GET            | opus-open-finance/enrollments/v1/enrollments/{enrollmentId}                                          | Obtenção dos dados do vínculo de conta                                         | 200      |
| PATCH          | opus-open-finance/enrollments/v1/enrollments/{enrollmentId}                                          | Rejeição o revogação de vínculo de conta                                      | 204      |
| POST           | opus-open-finance/enrollments/v1/enrollments/{enrollmentId}/risk-signals                             | Envio de sinais de risco para iniciação do vínculo de dispositivo           | 201      |
| POST           | opus-open-finance/enrollments/v1/enrollments/{enrollmentId}/fido-sign-options                        | Obtenção de parâmetros para autenticação FIDO2                            | 201      |
| POST           | /proxy/open-banking/enrollments/v1/enrollments/{enrollmentId}/fido-registration-options              | Obtenção de parâmetros para criação de credenciais FIDO2                  | 201      |
| POST           | /proxy/open-banking/enrollments/v1/enrollments/{enrollmentId}/fido-registration                      | Associação da credencial FIDO2 ao vínculo de conta                           | 201      |
| POST           | /proxy/open-banking/enrollments/v1/consents/{consentId}/authorise                                    | Autorização de um consentimento de pagamentos na jornada sem redirecionamento | 201      |

## Orientações importantes

- Todas as datas seguem o padrão da [RFC3339](https://datatracker.ietf.org/doc/html/rfc3339)
e formato "zulu".
