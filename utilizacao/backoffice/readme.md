# Backoffice API

Este documento resume os endpoints de backoffice do Opus TPP.

Fonte oficial do contrato: [backoffice.yml](backoffice.yml).

## Versão

- API: 1.0.0-beta.1

## Endpoints

### 1. Listar consentimentos

- Método e rota: GET /backoffice/consents
- Descrição: lista consentimentos com filtros, paginação e ordenação

Filtros principais:
- cnpj, cpf
- createdOnBegin, createdOnEnd, expiresOn
- searchKey, searchKeys
- tppId
- consentId, consentIdList
- consentStatus, consentStatusList
- page, pageSize, orderType
- Header obrigatório: x-application-id

### 2. Listar enrollments

- Método e rota: GET /backoffice/enrollments
- Descrição: lista enrollments com filtros, paginação e ordenação

Filtros principais:
- cnpj, cpf
- createdOnBegin, createdOnEnd, expiresOn
- tppId
- enrollmentId, enrollmentIdList
- enrollmentStatus, enrollmentStatusList
- page, pageSize, orderType
- Header obrigatório: x-application-id

### 3. Listar pagamentos por consentimento

- Método e rota: GET /backoffice/consents/{consentId}/payments
- Descrição: lista pagamentos associados ao consentimento

Parâmetros principais:
- consentId

## Padrões de resposta

As respostas seguem estrutura com:
- data: lista de itens do recurso
- meta: metadados de paginação e data/hora da requisição