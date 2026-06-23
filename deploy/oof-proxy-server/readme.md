# Instalação do OOF Proxy Server

## Pré-requisitos

### Dapr

O módulo OOF Proxy Server utiliza o Dapr para acesso ao **state store**
de cache, onde as respostas HTTP interceptadas são armazenadas e
recuperadas pelo proxy.

Este módulo foi testado com o Dapr na versão `v1.17.1`. É recomendado
utilizar **Dapr `>= 1.16`**.

### State store para cache

É necessário configurar um **state store do Dapr com suporte a TTL**,
para que as entradas de cache expirem automaticamente conforme o TTL
definido em cada requisição.

O nome do componente deve corresponder ao valor da variável
`env.dapr.urlsCacheStateStore.name` definida no Helm (ver seção
**Configuração**).

### Certificado CA para interceptação HTTPS (MITM)

O proxy realiza interceptação MITM (*Man-in-the-Middle*) em requisições
HTTPS, reassinando dinamicamente os certificados apresentados aos
clientes. Para isso, é necessário um certificado CA e sua respectiva
chave privada.

O certificado e a chave devem ser armazenados como **Kubernetes
Secrets** e referenciados nas variáveis `env.httpProxy.caCertSecretName`,
`env.httpProxy.caCertSecretKey`, `env.httpProxy.caKeySecretName` e
`env.httpProxy.caKeySecretKey` no Helm chart.

A CA utilizada **deve ser confiada pelas aplicações cliente** que roteiam
tráfego por este proxy (ex.: configurada como CA raiz nos módulos da solução
Opus Open Finance que fazem requisições por ele).

## Instalação

A instalação do módulo é feita via **Helm Chart**.

De forma geral, é necessário:

1. Garantir que o Dapr esteja instalado no cluster na versão suportada.
2. Criar o Secret Kubernetes com o certificado CA e sua chave privada.
3. Aplicar o componente de state store com suporte a TTL.
4. Configurar os valores do Helm conforme descrito nas seções abaixo.

## Configuração

As configurações obrigatórias deste módulo são feitas principalmente
por meio do bloco `env` do arquivo
`helm/oof-proxy-server/values.yaml`.

### dapr

Configurações relacionadas à integração com o Dapr.

- `env.dapr.appId`  
  Identificador da aplicação no Dapr.  
  Se vazio, o chart utilizará o nome padrão do release (nome completo
  do chart). Pode ser utilizado para padronizar a identificação da
  aplicação em diferentes ambientes.

- `env.dapr.urlsCacheStateStore`  
  Bloco que define o componente de state store utilizado para cache
  das respostas HTTP interceptadas pelo proxy:

  - `name`: Nome do componente
    [Dapr de state store](https://docs.dapr.io/operations/components/setup-state-store/)
    (deve corresponder a `URLS_CACHE_STATE_STORE_NAME`). **Obrigatório.**
  - `type`: [Tipo do componente de state store](https://docs.dapr.io/reference/components-reference/supported-state-stores/)
    (por exemplo, `state.redis`). **Obrigatório.**
  - `version`: Versão do componente (por exemplo, `v1`). Padrão: `v1`.
  - `connectionMetadata`: Lista de metadados de conexão exigidos pelo
    componente (host, credenciais, etc.).

  **Importante:** o state store deve ter suporte nativo a TTL para que
  as entradas de cache expirem automaticamente.

**Exemplo:**

```yaml
env:
  dapr:
    urlsCacheStateStore:
      name: "statestore"
      type: "state.redis"
      version: "v1"
      connectionMetadata:
        - name: redisHost
          value: "redis:6379"
        - name: redisPassword
          value: ""
```

### httpProxy

Configurações relacionadas ao servidor de proxy e à interceptação HTTPS.

- `env.httpProxy.port`  
  Porta de escuta do servidor de proxy.  
  **Padrão:** `8081`.

- `env.httpProxy.caCertSecretName` / `env.httpProxy.caCertSecretKey`  
  Nome e chave de um Secret Kubernetes que contém o certificado CA
  utilizado para assinar certificados na interceptação MITM HTTPS.
  **Obrigatórios.**

- `env.httpProxy.caKeySecretName` / `env.httpProxy.caKeySecretKey`  
  Nome e chave de um Secret Kubernetes que contém a chave privada
  associada ao certificado CA. **Obrigatórios.**

**Exemplo:**

```yaml
env:
  httpProxy:
    port: 8081
    caCertSecretName: "http-proxy-ca-cert"
    caCertSecretKey: "tls.crt"
    caKeySecretName: "proxy-ca-key"
    caKeySecretKey: "tls.key"
```

## additionalVars

As configurações opcionais da aplicação podem ser definidas através do
bloco `additionalVars` no `values.yaml`. Cada entrada neste bloco é
traduzida em uma variável de ambiente do container.

```yaml
additionalVars:
  - name: NOME_DA_VARIAVEL
    value: "VALOR_DA_VARIAVEL"
```

As variáveis que podem ser definidas neste formato estão listadas
abaixo.

### LOG_LEVEL

Nível de log da aplicação. Valores possíveis: `debug`, `info`, `warn`,
`error`, `fatal`.  
**Valor padrão:** `"info"`.

**Exemplo:**

```yaml
additionalVars:
  - name: LOG_LEVEL
    value: "debug"
```

### HTTP_READ_TIMEOUT_SECONDS / HTTP_WRITE_TIMEOUT_SECONDS / HTTP_IDLE_TIMEOUT_SECONDS

Timeouts (em segundos) para leitura, escrita e conexões ociosas do
servidor HTTP de gerenciamento exposto pelo módulo.  
**Valores padrão:** `10`, `10` e `30`, respectivamente.

### SHUTDOWN_TIMEOUT_SECONDS

Tempo máximo (em segundos) aguardado para o **graceful shutdown** da
aplicação.  
**Valor padrão:** `30`.

### APP_PORT

Porta de escuta do servidor HTTP de gerenciamento (endpoints `/live`,
`/ready`, `/metrics`).  
**Valor padrão:** `8080`.

### HTTP_PROXY_READ_TIMEOUT_SECONDS / HTTP_PROXY_WRITE_TIMEOUT_SECONDS / HTTP_PROXY_IDLE_TIMEOUT_SECONDS

Timeouts (em segundos) para leitura, escrita e conexões ociosas do
servidor de proxy.  
**Valores padrão:** `30`, `60` e `90`, respectivamente.

### CACHE_SAVE_BATCH_SIZE

Tamanho do lote para operações em batch de salvamento de cache.  
**Valor padrão:** `10`.

### CACHE_SAVE_WINDOW_TIME

Intervalo de tempo para janela de salvamento em batch do cache.  
**Valor padrão:** `500ms`.

### DAPR_OPERATION_TIMEOUT

Timeout aplicado individualmente a cada operação realizada no state
store via Dapr (leitura e escrita de cache).  
**Valor padrão:** `750ms`.

### HTTP_PROXY_VERBOSE

Ativa o logging detalhado interno da biblioteca de proxy.  
**Atenção:** gera volume elevado de logs; não recomendado em produção.  
**Valor padrão:** `false`.

### HTTP_PROXY_LOG_REQUESTS

Loga headers e metadados das requisições interceptadas pelo proxy.  
**Valor padrão:** `false`.

### HTTP_PROXY_LOG_RESPONSES

Loga headers e metadados das respostas interceptadas pelo proxy.  
**Valor padrão:** `false`.

### HTTP_PROXY_LOG_RESPONSE_BODY

Loga o body das respostas interceptadas pelo proxy.  
**Valor padrão:** `false`.

---
