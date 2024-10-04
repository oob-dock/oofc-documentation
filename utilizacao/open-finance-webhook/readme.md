# Recepção de Webhooks de Pagamentos

A API de Webhooks de Pagamentos trata as 
notificações enviadas pela Detentora, de 
mudanças de status dos pagamentos e 
consentimentos de pagamentos dos usuários.


## OpenAPI Specification

Uma descrição da API pode ser encontrada no [OAS](oas-webhook.yml) disponibilizado.


## Utilização do Webhook 

> **ATENÇÃO:** Os endpoints listados a seguir só podem ser utilizados
após um pagamento ou um consentimento de pagamento ter sido criado pelo 
usuário no sistema. Caso contrário uma notificação recebida será ignorada.


### Informações da notificação de atualização

> **IMPORTANTE:** Todas as notificações apenas enviam a data da 
atualização. Nenhuma delas informa para qual status um pagamento, ou um
consentimento foi alterado.

```JSON
{
  "data": {
    "timestamp": "2021-05-21T08:30:00Z"
  }
}
```
Caso deseje saber o status, é necessário fazer a chamada para o endpoint
*Consulta de status do pagamento* - GET /proxy/open-banking/payments/v4/pix/payments/{paymentId}, descrito [aqui](../open-finance-pagamentos)


### Pagamentos: 

Notificações de mudanças de estados de consentimentos e do pagamento.

#### POST /open-banking/webhook/v1/payments/{versionApi}/consents/{paymentId}

Recebe a notificação da instituição transmissora de dados, informando que 
ocorreu uma mudança no estado do consentimento do pagamento Pix 
realizado anteriormente.

#### POST /open-banking/webhook/v1/payments/{versionApi}/pix/payments/{paymentId}

Recebe a notificação da instituição transmissora de dados, informando que 
ocorreu uma mudança no estado do pagamento Pix realizado anteriormente.


### Pagamentos Automáticos: 

Notificações de mudanças nas entidades de consentimentos de longa duração e do pagamento.

#### POST /open-banking/webhook/v1/automatic-payments/{versionApi}/recurring-consents/{recurringPaymentId}

Recebe a notificação da instituição transmissora de dados, informando que 
ocorreu uma mudança no estado do consentimento do pagamento automático Pix 
realizado anteriormente.

#### POST /open-banking/webhook/v1/automatic-payments/{versionApi}/pix/recurring-payments/{recurringPaymentId}

Recebe a notificação da instituição transmissora de dados, informando que 
ocorreu uma mudança no estado do pagamento automático Pix realizado anteriormente.


## Orientações importantes

- Todas as datas seguem o padrão da [RFC3339](https://datatracker.ietf.org/doc/html/rfc3339)
e formato "zulu".
- Não há separação funcional entre pessoa natural e pessoa jurídica.
- Como descrito préviamente, os endpoints listados a seguir só podem ser utilizados
após um pagamento ou um consentimento de pagamento ter sido criado pelo 
usuário no sistema. Caso contrário uma notificação recebida será ignorada.
- Como descrito préviamente, todas as notificações apenas enviam a data da 
atualização. Nenhuma delas informa para qual status um pagamento, ou um
consentimento foi alterado.
- Caso a notificação traga uma atualização de status de um consentimento ou pagamento existente
no sistema, é enviada uma resposta de sucesso para a transmissora e a notificação será processada como válida.
- O fluxo de processamento das notificações validas é assíncrono, ou seja, uma notificação válida recebida é publicada
para ser consumida pelo próprio sistema num momento posterior.
- É de responsabilidade do cliente configurar esse fluxo (ttl, retry, ....) e indiferente do que escolher como ferramental, deve seguir como padrão:
    - Pubsub Id: "webhook-event-pub-sub"
    - Pubsub Topic: "opustpp-webhook-topic"
- É necessário o cadastro prévio da url de webhook no sistema para onde a notificação recebida, será redirecionada.
    - Essa url de webhook não é para ser a mesma cadastrada no diretório de participantes, na parte de Software Statement.
    Deve ser uma url interna do cliente, que receberá um POST obedecendo o seguinte formato:
```JSON
{
"requestBody": {
    "data": {
        "timestamp": "2024-09-02T08:30:00Z"
    }
},
"requestHeaders": {
    "x-webhook-interaction-id": "webhook-interaction-id",
    "content-type": "application/json",
    "accept": "*/*",
    "connection": "keep-alive",
    "x-fapi-interaction-id": "af113686-b4fd-413e-86a1-dc7eb1b4cc1a"
},
"requestMethod": "POST"
}
```
    - Caso não exista uma url pré-cadastrada no sistema, a notificação será recebida, retornará sucesso
    para a transmissora e apenas informará no log do sistema, que a notificação foi ignorada.


## APIs

| Tipo Request   | Endpoint                                                                                             | Descrição                                                               | Sucesso  |
| -------------- | ---------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------- | -------- |
| POST           | /open-banking/webhook/v1/payments/{versionApi}/consents/{paymentId}                                  | Notificação de atualização do consentimento do pagamento Pix            | 202      |
| POST           | /open-banking/webhook/v1/payments/{versionApi}/pix/payments/{paymentId}                              | Notificação de atualização do pagamento Pix                             | 202      |
| POST           | /open-banking/webhook/v1/automatic-payments/{versionApi}/recurring-consents/{recurringPaymentId}     | Notificação de atualização do consentimento do pagamento automático Pix | 202      |
| POST           | /open-banking/webhook/v1/automatic-payments/{versionApi}/pix/recurring-payments/{recurringPaymentId} | Notificação de atualização do pagamento automático Pix                  | 202      |

### Exemplo de um payload de notificação de alteração de status de consentimento

```JSON
{
    "data": {
        "timestamp": "2024-09-02T08:30:00Z"
    }
}
```

Para mais informações sobre os campos veja a [documentação oficial](https://openfinancebrasil.atlassian.net/wiki/spaces/OF/pages/105021457/Webhook)
do Open Finance Brasil.

### Exemplo de payload para o webhook cadastrado

```JSON
{
    "data": {
        "timestamp": "2024-09-02T08:30:00Z"
    }
}
```
