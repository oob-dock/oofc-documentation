# ODR-CORE

A aplicação Opus Data Receiver - Core é responsável por buscar, armazenar e disponibilizar os dados recebidos dos usuários, para os clientes.


## Configuração

A configuração é feita através de um arquivo YAML.
As seções necessárias são descritas a seguir.

### service

Configuração de acesso ao Opus Data Receiver - Core

* `port`: Nome da porta habilitada para acesso ao Opus Data Receiver - Core

```yaml
service:
  port: 8090
```

### dapr

Configurações relacionadas ao Dapr.

* `enabled`: Habilita o Dapr na aplicação para realizar o consumo de eventos.
Possíveis valores: `true` ou `false`. Default: `true`.
* `env.pubSubId`: Identificador do componente de pub/sub do Dapr a ser utilizado.
* `appPort`: Porta utilizada para comunicação do Dapr com o Opus Data Receiver - Core.
* `httpPort`: Porta utilizada pelo Opus Data Receiver para se comunicar via HTTP com o sidecard DaprReceiver - Core.
* `grpcPort`: Porta utilizada pelo Opus Data Receiver para se comunicar via gRPC com o sidecard DaprReceiver - Core.

```yaml
dapr:
  enabled: true
  appId: "odr-core"
  appPort: 8090
  httpPort: 3500
  grpcPort: 50001
env:
  pubSubId: "pcm-event-pub-sub-retry"
```

### base de dados

Configuração de acesso a base de dados

* `vendor`: Nome do produto usado como sistema de base de dados.
* `name`: Nome da base de dados.
* `username`: Nome do usuário de acesso a base de dados.
* `password`: Senha do usuário de acesso a base de dados.
* `host`: Host da base de dados.
* `port`: Porta da base de dados.
* `showLog`: Flag para habilitar logs da base de dados


Configuração do mecanismo de persistência em lote

* `persistence.command.batchSize` : Número máximo de queries por persistência em lote
* `persistence.command.waitPeriodSeconds` : Define quanto tempo o mecanismo de persistência deve esperar desde a primeira query adicionada em sua fila, antes de fazer o flush dos dados.

```yaml
env:
  db:
    vendor: "postgres"
    host: ""
    port: 5432
    name: "odr_core_db"
    username: "odr_core_user"
    password: ""
    showLog: "false"
    persistence:
      command: 
        batchSize: "200"
        waitPeriodSeconds: "1"
```
### driver

Configurações relacionadas ao driver usado pelo Opus Data Receiver - Core. 

Cada driver leva seu prefixo na configuração. Como essa instalação leva por padrão o driver do Open Finance Brasil, fica ofb.

 * `driver.ofb.url`: Define o endpoint da API que o Driver OFB utiliza para busca dos dados.

Esse Driver conecta a uma API Rest, por isso tem um client HTTP dentro dele.

#### driver - http client

Configurações relacionadas ao cliente Http usado pelo Opus Data Receiver - Core

Obs: Todos tem prefixo `env.httpClient.`

* `connectTimeout`: Define quanto é o tempo máximo (em milissegundos) que o cliente do Opus Data Receiver - Core aguardará enquanto estabelece uma conexão TCP com o servidor.
* `readTimeout`: Define quanto é o tempo máximo que o cliente do Opus Data Receiver - Core aguardará para que os dados sejam lidos do servidor após a conexão ter sido estabelecida.

#### driver - busca paginada

* `core.maxPeriodSecondsLooping`: Tempo máximo permitido para buscar todas as páginas de uma API com resposta paginada. Irá percorrer todas as páginas disponíveis até chegar ao final ou acabar o tempo definido aqui, o que vier primeiro.

Obs: Para o caso do Open Finance Brasil, é permitido iterar uma busca inicial, mudando apenas as páginas, por 1 hora sem custo adicional, se for passado o [PAGINATION-KEY](https://openfinancebrasil.atlassian.net/wiki/spaces/OF/pages/17924220/Limites+operacionais#Pagina%C3%A7%C3%A3o-no-contexto-dos-limites-operacionais).


```yaml
env:
  driver:
    ofb:
      url: "https://obb.qa.oob.opus-software.com.br:8090"
  httpClient:
    connectTimeout: 5000
    readTimeout : 5000
  core:
    maxPeriodSecondsLooping: 3600
```

### odr_scheduler

Configurações relacionadas a comunicação com a aplicação Opus Data Receiver -  Scheduler

* `odrScheduler.url`: Define o endpoint da API do Opus Data Receiver - Scheduler.

```yaml
env:
  odrScheduler:
      url: "https://odr.scheduler.qa:8090"
```

## additionalVars

Utilizado para definir configurações opcionais na aplicação. Essa configuração
permite definir uma lista de propriedades a serem passadas para a aplicação no formato:

```yaml
additionalVars:
  - name: FIRST_PROPERTY
    value: "FIRST_VALUE"
  - name: SECOND_PROPERTY
    value: "SECOND_VALUE"
```

As configurações que podem ser definidas neste formato estão listadas abaixo:

### SPRING_CLOUD_OPENFEIGN_CLIENT_CONFIG_DEFAULT_LOGGERLEVEL

Define qual nível usado para os logs produzidos pelo client Http do Driver OFB.

**Formato:** `full, basic, headers, none`.

**Ex:**

```yaml
additionalVars:
  - name: SPRING_CLOUD_OPENFEIGN_CLIENT_CONFIG_DEFAULT_LOGGERLEVEL
    value: "true"
```

### LOGGING_LEVEL_BR_COM_OPUS_OOD

Define qual nível usado para os logs produzidos pelo Opus Data Receiver - Core.
A ordem é TRACE < DEBUG < INFO < WARN < ERROR < FATAL.

**Formato:** `TRACE, DEBUG, INFO, WARN, ERROR, FATAL`.

**Ex:**

```yaml
additionalVars:
  - name: LOGGING_LEVEL_BR_COM_OPUS_OOD
    value: "INFO"
```

### SPRING_DATASOURCE_HIKARI_IDLETIMEOUT

Define o tempo máximo (em milissegundos) que uma conexão pode ficar ociosa no pool do HikariCP antes de ser fechada
com a base de dados.

**Formato:** inteiro.

**Ex:**

```yaml
additionalVars:
  - name: SPRING_DATASOURCE_HIKARI_IDLETIMEOUT
    value: "10000"
```

### SPRING_DATASOURCE_HIKARI_MAXIMUMPOOLSIZE

Define o tamanho máximo do pool de conexões do HikariCP, que é o gerenciador de pool de conexões padrão do Spring Boot
com a base de dados.

**Formato:** inteiro.

**Ex:**

```yaml
additionalVars:
  - name: SPRING_DATASOURCE_HIKARI_MAXIMUMPOOLSIZE
    value: "10"
```

### SPRING_DATASOURCE_HIKARI_MINIMUMIDLE

Define o número mínimo de conexões ociosas que o pool de conexões HikariCP tentará manter com a base de dados.

Importante:

* Tráfego variável: Para aplicações com tráfego irregular, configure minimum-idle com um valor menor que maximum-pool-size. O pool irá encolher durante períodos de baixa atividade e se expandir em picos de tráfego.

* Tráfego constante: Para performance máxima, principalmente em ambientes de alta concorrência, o ideal é ter um pool de tamanho fixo, ou seja, configurar minimum-idle com o mesmo valor de maximum-pool-size. Isso evita o tempo gasto para criar e destruir conexões.

**Formato:** inteiro.

**Ex:**

```yaml

additionalVars:
  - name: SPRING_DATASOURCE_HIKARI_MINIMUMIDLE
    value: "10"
```

## Execmplo completo

```yaml
replicaCount: 1

image:
  repository: 618430153747.dkr.ecr.sa-east-1.amazonaws.com/digital-banking-microservices/odr-core
  pullPolicy: IfNotPresent

imagePullSecretName: "aws-ecr-registry-secret"

resources: 
  limits:
    cpu: 500m
    memory: 512Mi
  requests:
    cpu: 300m
    memory: 128Mi

imagePullSecrets:
  - name: aws-ecr-registry-secret

additionalVars:
  - name: SPRING_DATASOURCE_HIKARI_MINIMUMIDLE
    value: "1"
  - name: SPRING_DATASOURCE_HIKARI_MAXIMUMPOOLSIZE
    value: "10"
  - name: SPRING_DATASOURCE_HIKARI_IDLETIMEOUT
    value: "10000"

  #LOGGING_LEVEL_APPLICATION: INFO, DEBUG, WARN, ERROR, OFF
  - name: LOGGING_LEVEL_BR_COM_OPUS_OOD
    value: "INFO"

  #HTTP_CLIENT_LOGGING_LEVEL: full, basic, headers, none
  - name: SPRING_CLOUD_OPENFEIGN_CLIENT_CONFIG_DEFAULT_LOGGERLEVEL
    value: "full"


nameOverride: ""
fullnameOverride: ""

service:
  type: ClusterIP
  port: 8090

ingress:
  enabled: false

hpa:
  enabled: false
  minReplicas: 1
  maxReplicas: 10
  averageCPUUtilization: 80
  averageMemoryUtilization: 80

dapr:
  enabled: true
  appId: "odr-core"
  appPort: 8090
  httpPort: 3500
  grpcPort: 50001


env:
  pubSubId: "pcm-event-pub-sub-retry"

  core:
    maxPeriodSecondsLooping: 3600

  db:
    vendor: "postgres"
    host: "db-opus-open-banking.cbibhmphwidp.us-east-1.rds.amazonaws.com"
    port: 5432
    name: "odr_core_db"
    username: "odr_core_user"
    password: "password"
    showLog: "false"
    persistence:
      command: 
        batchSize: "200"
        waitPeriodSeconds: "1"

  driver:
    ofb:
      url: "http://host.oofc-core.exteral:3001"

  httpClient:
    connectTimeout: 5000
    readTimeout : 5000


  odrScheduler:
    url: "http://host.odr.scheduler.internal:3001"
```