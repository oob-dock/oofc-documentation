# Instalação do OOF Proxy Cache Warmer

## Pré-requisitos

### Dapr

O módulo OOF Proxy Cache Warmer faz uso intenso do Dapr para gerenciamento de
**virtual actors** e **jobs/reminders** responsáveis por buscar
URLs e aquecer o cache do módulo OOF Proxy.

Este módulo foi testado com o Dapr na versão `v1.17.1` e é altamente
recomendado utilizar **Dapr `>= 1.16`**, pois as versões anteriores não
contém as otimizações necessárias para o uso de virtual actors e reminders
em produção com boa performance.

### State store para actors

É necessário configurar uma **state store do Dapr com suporte a actors**, isto é,
um componente de state store com o metadado:

```yaml
metadata:
  - name: actorStateStore
    value: "true"
```

O nome do componente deve corresponder ao valor da variável
`ACTOR_STATE_STORE_NAME` utilizada pela aplicação. No Helm, esse nome é
configurado via `env.dapr.actorStateStore.name` (ver seção **Configuração**).

## Instalação

A instalação do módulo é feita via **Helm Chart**.

De forma geral, é necessário:

1. Garantir que o Dapr esteja instalado no cluster na versão suportada.
2. Aplicar o componente de state store com `actorStateStore: true`.
3. Configurar os valores do Helm conforme descrito nas seções abaixo.

## Configuração

As configurações obrigatórias deste módulo são feitas principalmente por meio do
bloco `env` do arquivo
`helm/oof-proxy-cache-warmer/values.yaml`.

### dapr

Configurações relacionadas à integração com o Dapr.

- `env.dapr.appId`  
  Identificador da aplicação no Dapr.  
  Se vazio, o chart utilizará o nome padrão do release (nome completo do chart).
  Pode ser utilizado para padronizar a identificação da aplicação em diferentes
  ambientes.

- `env.dapr.actorStateStore`  
  Bloco que define o componente de state store que será utilizado pelos actors:

  - `name`: Nome do componente [Dapr de state store](https://docs.dapr.io/operations/components/setup-state-store/) (deve bater com
    `ACTOR_STATE_STORE_NAME`).
  - `type`: [Tipo do componente de state store](https://docs.dapr.io/reference/components-reference/supported-state-stores/) (por exemplo, `state.redis`).
  - `version`: Versão do componente (por exemplo, `v1`).
  - `connectionMetadata`: Lista de metadados de conexão exigidos pelo
    componente (host, credenciais, etc.).

  **Importante:** este componente deve conter o metadado `actorStateStore: true`
  para que o Dapr o utilize como state store de actors.

**Exemplo:**

```yaml
env:
  dapr:
    actorStateStore:
      name: "statestore"
      type: "state.redis"
      version: "v1"
      connectionMetadata:
        redisHost: "redis:6379"
        redisPassword: ""
```

### directory

Configurações relacionadas ao acesso ao Diretório de Participantes, utilizado
para obter informações e montar a lista de URLs a serem aquecidas.

- `env.directory.centralJwks`  
  Endereço do JWKS do diretório de participantes.  
  Deve ser preenchida com o mesmo valor do que a configuração `env.as.central_directory_jwks`
  definida no módulo Authorization Server.  

- `env.directory.apiBaseUrl`  
  URL base da API do Diretório de Participantes (por exemplo, endpoint para
  obtenção de token, organisations, software statements). **Obrigatória.**

  **Sandbox:** https://matls-auth.sandbox.directory.openbankingbrasil.org.br  
  **Produção:** https://matls-auth.directory.openbankingbrasil.org.br

- `env.directory.clientId`  
  Client ID utilizado para autenticação mTLS/OAuth no Diretório. **Obrigatória.**

- `env.directory.brcacSecretName` / `env.directory.brcacSecretKey`  
  Nome e chave de um Secret Kubernetes que contém o certificado BRCAC utilizado
  na autenticação no Diretório. **Obrigatório.**

- `env.directory.brcacKeySecretName` / `env.directory.brcacKeySecretKey`  
  Nome e chave de um Secret Kubernetes que contém a chave privada associada ao
  certificado BRCAC. **Obrigatório.**

- `env.directory.keystoreBaseUrl`  
  URL base utilizada para montar as URLs de keystore (JWKS, etc.) no Diretório.
  **Obrigatória.**

  **Sandbox:** https://keystore.sandbox.directory.openbankingbrasil.org.br  
  **Produção:** https://keystore.directory.openbankingbrasil.org.br

- `env.directory.proxyUrl`  
  URL do proxy utilizado para rotear **todas** as requisições do cliente do
  Diretório de Participantes (token, organisations e software statements).
  Quando definida, cada requisição tem sua URL reescrita para usar o host do
  proxy como base e a URL original é passada como query param (percent-encoded)
  seguindo o template da variável — ex.: `https://proxy.example.com?url=%s`.
  Quando não definida, o cliente do diretório faz requisições diretamente.
  **Opcional.**

**Exemplo:**

```yaml
env:
  directory:
    apiBaseUrl: "https://matls-auth.sandbox.directory.openbankingbrasil.org.br"
    clientId: "SEU_CLIENT_ID"
    brcacSecretName: "directory-brcac-cert"
    brcacSecretKey: "cert"
    brcacKeySecretName: "directory-brcac-key"
    brcacKeySecretKey: "key"
    keystoreBaseUrl: "https://keystore.sandbox.directory.openbankingbrasil.org.br"
```

## httpProxy

Este módulo possui o objetivo de se comunicar com o módulo
[OOF Proxy Server](../oof-proxy-server/readme.md) oferecido junto à solução do
Opus Open Finance. Ele realiza o mapeamento de URLs encontradas no diretório
de participantes e também recebe solicitações de adição de URLs via API.
Ao acessar essas URLs através do proxy server, ele alimenta o cache de
respostas que é utilizado pelos outros módulos da solução que possuem
comunicação estabelecida com o proxy.

**A configuração desta funcionalidade é obrigatória**.

Configurações:

- `env.httpProxy.url`  
Endereço interno do módulo OOF Proxy Server. **Importante**: A porta destino
deste endereço deve ser a mesma definida na variável `env.httpProxy.port` do
módulo OOF Proxy Server.

- `env.httpProxy.caCertSecretName` / `env.httpProxy.caCertSecretKey`  
Nome e chave de um Secret Kubernetes que contém o certificado CA utilizado para
assinar certificados na interceptação MITM HTTPS. Os valores definidos nestas
variáveis devem ser os mesmos valores configurados nas variáveis de mesmo nome
do módulo OOF Proxy Server.

Exemplo:

```yaml
env:
  httpProxy:
    url: "http://oof-proxy-server:8081"
    caCertSecretName: "http-proxy-ca-cert"
    caCertSecretKey: "tls.crt"
```

## additionalVars

As configurações opcionais da aplicação podem ser definidas através do bloco
`additionalVars` no `values.yaml`. Cada entrada neste bloco é traduzida em uma
variável de ambiente do container.

```yaml
additionalVars:
  - name: NOME_DA_VARIAVEL
    value: "VALOR_DA_VARIAVEL"
```

As variáveis que podem ser definidas neste formato estão listadas abaixo.

### LOG_LEVEL

Nível de log da aplicação. Valores possíveis: `debug`, `info`, `warn`, `error`,
`fatal`.  
**Valor padrão:** `"info"`.

**Exemplo:**

```yaml
additionalVars:
  - name: LOG_LEVEL
    value: "debug"
```

### SECURITY_SKIP_CERTIFICATE_VERIFICATION

Indica se a verificação de certificados deve ser ignorada nas conexões TLS.
Essa configuração é utilizada durante o processo de criação do cliente HTTP
que fará as requisições ao Diretório de Participantes.
**Atenção:** não deve ser habilitada em produção.  
**Valor padrão:** `false`.

### HTTP_READ_TIMEOUT_SECONDS / HTTP_WRITE_TIMEOUT_SECONDS / HTTP_IDLE_TIMEOUT_SECONDS

Timeouts (em segundos) para leitura, escrita e conexões ociosas do servidor HTTP
exposto pelo módulo.  
**Valores padrão:** `5`, `5` e `10`, respectivamente.

### SHUTDOWN_TIMEOUT_SECONDS

Tempo máximo (em segundos) aguardado para o **graceful shutdown** da aplicação.  
**Valor padrão:** `30`.

### DIRECTORY_URL_MAPPER_JOB_ENABLED / DIRECTORY_URL_MAPPER_JOB_SCHEDULE / DIRECTORY_URL_MAPPER_JOB_DUE_TIME

Controlam a execução do **job do Diretório de Participantes**:

- `DIRECTORY_URL_MAPPER_JOB_ENABLED`: habilita ou desabilita o job. Padrão: `true`.
- `DIRECTORY_URL_MAPPER_JOB_SCHEDULE`: expressão cron de 6 campos (segundos
  minutos horas dia mês dia-da-semana). Padrão: `0 0 */6 * * *` (a cada 6 horas).
- `DIRECTORY_URL_MAPPER_JOB_DUE_TIME`: atraso inicial antes da primeira
  execução (`1m` por padrão).

### DIRECTORY_URL_MAPPER_JOB_EXECUTION_TIMEOUT

Duração máxima permitida para uma única execução do job do Diretório. O callback
do job responde imediatamente com HTTP 200 e processa de forma assíncrona em
background com este timeout. Se uma execução anterior ainda estiver em andamento
quando o próximo disparo ocorrer, a nova execução é ignorada (proteção contra
overlap).  
**Valor padrão:** `30m`.

### ACTOR_IDLE_TIMEOUT / ACTOR_SCAN_INTERVAL / ACTOR_DRAIN_ONGOING_CALL_TIMEOUT

Configurações gerais de actors do Dapr:

- `ACTOR_IDLE_TIMEOUT`: tempo até um actor ocioso ser descarregado. Padrão: `5m`.
- `ACTOR_SCAN_INTERVAL`: intervalo entre varreduras de actors. Padrão: `30s`.
- `ACTOR_DRAIN_ONGOING_CALL_TIMEOUT`: timeout para drenagem de chamadas em
  andamento durante shutdown. Padrão: `30s`.

### ACTOR_EXECUTION_TIME_EXTENSION_THRESHOLD

Limite utilizado para decidir quando uma extensão da configuração de data de
execução máxima de um actor deve disparar o re-registro do reminder.  
**Valor padrão:** `5m`.

### ACTOR_MIN_RESCHEDULE_429_INTERVAL_MILLISECONDS / ACTOR_MAX_RESCHEDULE_429_INTERVAL_MILLISECONDS

Intervalo mínimo e máximo (em milissegundos) usado ao reagendar o reminder
após respostas HTTP `429` vindas das chamadas de GET das URLs que visam popular
o cache.  
**Valores padrão:** `1000` e `5000`, respectivamente.

### ACTOR_DUE_TIME_MAX_JITTER

Variação máxima (jitter) do atraso do scheduler do actor.  
**Valor padrão:** `3s`.

### ACTOR_MAX_CONCURRENT_FETCHES

Limite máximo de fetches concorrentes permitidos.  
**Valor padrão:** `20`.

### ACTOR_FETCH_SEMAPHORE_TIMEOUT

Timeout para adquirir semáforo de fetch.  
**Valor padrão:** `3s`.

### ACTOR_REMINDER_FAILURE_MAX_RETRIES / ACTOR_REMINDER_FAILURE_INTERVAL / ACTOR_REMINDER_FAILURE_INTERVAL_MAX_JITTER

Configurações de retry para re-registro de reminders em caso de falha:

- `ACTOR_REMINDER_FAILURE_MAX_RETRIES`: número máximo de tentativas de re-registro do reminder em caso de falha. Padrão: `3`.
- `ACTOR_REMINDER_FAILURE_INTERVAL`: intervalo de espera entre tentativas de re-registro do reminder em caso de falha. Padrão: `5s`.
- `ACTOR_REMINDER_FAILURE_INTERVAL_MAX_JITTER`: variação máxima (jitter) do intervalo de re-registro do reminder em caso de falha. Padrão: `3s`.

### CACHEABLE_URL_REQUEST_TIMEOUT_SECONDS

Timeout (em segundos) das requisições HTTP de GET das URLs que visam popular o
cache.  
**Valor padrão:** `5`.

### CACHEABLE_URL_REQUEST_MAX_RETRIES

Número máximo de tentativas de retry para erros não-404/não-429 ao realizar as
chamadas de GET das URLs que visam popular o cache.
**Valor padrão:** `5`.

### CACHEABLE_URL_REQUEST_MAX_NOT_FOUND_RETRIES_IN_A_ROW

Número máximo de respostas `404` consecutivas antes de o actor parar de
processar a URL.  
**Valor padrão:** `5`.

### CACHEABLE_URL_REQUEST_INITIAL_RETRY_INTERVAL / CACHEABLE_URL_REQUEST_MAX_RETRY_INTERVAL

Intervalo inicial e máximo do **backoff exponencial** aplicado aos reminders de
retry em erros de chamadas das URLs para popular o cache (não-404/não-429).  
**Valores padrão:** `2s` (inicial) e `30s` (máximo).

### DIRECTORY_REQUEST_TIMEOUT_SECONDS / DIRECTORY_REQUEST_MAX_RETRIES / DIRECTORY_REQUEST_WAIT_BETWEEN_RETRIES_SECONDS

Timeout e política de retry para chamadas HTTP ao Diretório de Participantes:

- `DIRECTORY_REQUEST_TIMEOUT_SECONDS`: timeout por requisição. Padrão: `5`.
- `DIRECTORY_REQUEST_MAX_RETRIES`: máximo de tentativas. Padrão: `5`.
- `DIRECTORY_REQUEST_WAIT_BETWEEN_RETRIES_SECONDS`: espera entre tentativas.
  Padrão: `3`.

### DIRECTORY_PARALLEL_SOFTWARE_STATEMENT_REQUESTS

Número máximo de requisições concorrentes feitas ao Diretório de Participantes
ao buscar software statements para uma organização.  
**Valor padrão:** `10`.

### URL_WARMER_DUE_TIME_INCREMENT

Incremento de delay de início (due time) entre actors criados diretamente via API.  
**Valor padrão:** `100ms`.

### URL_KEYSTORE_ACTOR_* / URL_PEM_ACTOR_* / URL_CRL_ACTOR_* / URL_DISCOVERED_DUE_TIME_INCREMENT

Configurações de tempo e TTL específicas por tipo de URL:

- `URL_KEYSTORE_ACTOR_DUE_TIME_INCREMENT`: incremento de delay de início (due
  time) entre actors criados a partir das URLs das organizações que foram
  geradas após consulta ao Diretório de Participantes.  
  Padrão: `300ms`.
- `URL_KEYSTORE_ACTOR_MAX_LIFETIME`: duração máxima de execução dos actors de
  URLs das organizações.  
  Padrão: `24h`.
- `URL_KEYSTORE_ACTOR_SCHEDULE_INTERVAL`: intervalo do reminder para actors de
  URLs das organizações.  
  Padrão: `3h`.
- `URL_KEYSTORE_CACHE_TTL`: TTL padrão passado para a camada de cache (OOF
  Proxy Cache) via query param para actors de URLs das organizações. Este valor
  controla por quanto tempo a resposta da chamada da URL ficará válida no
  cache.  
  Padrão: `24h`.

- `URL_PEM_ACTOR_MAX_LIFETIME`, `URL_PEM_ACTOR_SCHEDULE_INTERVAL`,
  `URL_PEM_CACHE_TTL`: configurações análogas para URLs PEM.  
  Padrões: `24h`, `3h`, `24h`.

- `URL_CRL_ACTOR_MAX_LIFETIME`, `URL_CRL_ACTOR_SCHEDULE_INTERVAL`,
  `URL_CRL_CACHE_TTL`: configurações análogas para URLs de CRL.  
  Padrões: `24h`, `3h`, `24h`.

- `URL_DISCOVERED_DUE_TIME_INCREMENT`: incremento de delay de início (due time)
  entre actors criados a partir de URLs descobertas após o GET de outras URLs.  
  Padrão: `50ms`.
