# Gestão de informações salvas no banco de dados

Disponibilização de APIs para o gerenciamento de informações
contidas no banco de dados do oofc-core.

## OpenAPI Specification

Uma descrição da API pode ser encontrada no [OAS](oas-interno.yml) disponibilizado.

## Orientações importantes

Essas APIs são para quem não tem o conhecimento do applicationId
(Identificador do aplicativo que realiza a requisição) e
tem a necessidade de ter uma outra identificação referente ao applicationId.

## Utilização das APIs para o gerenciamento do external client id

### Consulta do external client id - GET opus-open-finance/application/v1/external-client/{id}

Permite a consulta do external client id cadastrado em uma aplicação.

### Criação ou atualização de external client id - PATCH opus-open-finance/application/v1/application/{applicationId}/external-client/{id}

Permite a criação ou atualização do external client id de uma aplicação.
Para a criação a aplicação não pode ter um external client id cadastrado. Já a
atualização é realizada quando o external client id existe.

### Criação ou atualização de webhook url - PATCH opus-open-finance/application/v1/application/{applicationId}/webhook-url

Permite a criação ou atualização do webhook url de uma aplicação cliente.
Essa url é chamada durante o processo de notificação de mudança de status de um pagamento.

## APIs

| Tipo Request | Endpoint                                                                           | Descrição                                   | Sucesso  |
| ------------ | ---------------------------------------------------------------------------------- | ------------------------------------------- | -------- |
| GET          | /opus-open-finance/application/v1/external-client/{id}                             | Obtenção do external client id              | 200      |
| PATCH        | /opus-open-finance/application/v1/application/{applicationId}/external-client/{id} | Criação e atualização do external client id | 204      |
| PATCH        | /opus-open-finance/application/v1/application/{applicationId}/webhook-url          | Criação e atualização do webhook url        | 204      |

### Exemplo de response (GET)

```JSON
{
    "data": {
        "externalClientId": "externalClientId",
        "applicationId": "30370c82-db45-4a0d-86a5-4a35cd0b4ab8",
    }
}
```