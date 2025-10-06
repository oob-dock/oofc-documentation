# ODR-SCHEDULER

A aplicação Opus Data Receiver - Scheduler é responsável por agendar, validar e disparar uma atualização de um dado de um usuário cadastrado.


## Configuração

A configuração é feita através de um arquivo YAML.
As seções necessárias são descritas a seguir.

### Expressões Cron

Os períodos configurados no Opus Data Receiver - Scheduler, seguem o formato definido pelo Cron do [Dapr](https://docs.dapr.io/reference/components-reference/supported-bindings/cron/)

* Example patterns:

* -- "0 0 * * * *" = the top of every hour of every day.
* -- "*\/10 * * * * *" = every ten seconds.
* --  "0 0 8-10 * * *" = 8, 9 and 10 o'clock of every day.
* --  "0 0 6,19 * * *" = 6:00 AM and 7:00 PM every day.
* --  "0 0/30 8-10 * * *" = 8:00, 8:30, 9:00, 9:30, 10:00 and 10:30 every day.
* --  "0 0 9-17 * * MON-FRI" = on the hour nine-to-five weekdays
* --  "0 0 0 25 12 ?" = every Christmas Day at midnight

### service

Configuração de acesso ao Opus Data Receiver - Scheduler

* `port`: Nome da porta habilitada para acesso ao Opus Data Receiver - Scheduler

```yaml
service:
  port: 8087
```

## atualização automatica

* `autoUpdatePendingSetup`: Define se o ODR (true) buscará automaticamente por atualizações de status para configurações pendentes (AGUARDANDO_AUTORIZAÇÃO), ou não (false)
* `cron.pendingStatus`: Uma vez que autoUpdatePendingSetup é verdadeiro, define o período ( como uma expressão cron) para buscar atualizações de status de setups pendentes (No caso do OFB, AWAITING_AUTHORISATION -> AUTHORISED).

```yaml
env:
  autoUpdatePendingSetup: "true"
  cron:
    pendingStatus: "*/15 * * * * *"
```

## políticas de agendamento

Configuração da parte de políticas de agendamentos do Opus Data Receiver - Scheduler

Obs: Toda essa sessão te prefixo `env.update.`

* `controlRegulatoryLimit`: Define se o  Opus Data Receiver - Scheduler deve ou não limitar as chamadas baseado nos limites regulatórios. DEVE FICAR DESLIGADO.

```yaml
env:
  update: 
    controlRegulatoryLimit: "false"
```

* `rule.policy`: Define qual tipo de política de atualização será usada.
* * RegulatoryPolicies ( Default ) - > Política em que a próxima data de atualização será calculada adicionando a frequência pré-configurada pelo cliente. Deve seguir o limite definido pelo Open Finance Brasil.
Mais informações: (https://openfinancebrasil.atlassian.net/wiki/spaces/OF/pages/17957025/Refer+ncia).

      
* * ClientPolicies -> A próxima data será agendada usando a data limite da instância Scheduler_Update_Rule e <ENV_SCHEDULER_UPDATE_DAY_REQUEST_MAX>. Não há limite predefinido. Cria um pipeline a partir das políticas do cliente, ordenando por prioridade crescente. 

* `rule.chunksize`: Define  o tamanho do bloco de seleção dos dados escolhidos para atualização. Durante essa fase, os dados são carregados em blocos e transmitidos para processar a atualização.

* `dayRequestMax`: **Ativo apenas com a política : ClientPolicies!** Controla o número máximo de requisições feitas por dia pelo Opus Data Receiver. 

* `job.name`: Define o nome do job responsável por iniciar o processo de atualização no Opus Data Receiver - Scheduler
* `job.cronPeriod`: Indica a frequência com que o job de atualização deve ser ativado para iniciar o processo. É uma expressão cron que segue o formato [dapr]()

```yaml
env:
  update: 
    rule:
      policy: "RegulatoryPolicies"
      chunksize: 200
    dayRequestMax: 10000000
    job:
      name: "update-executor-job"
      cronPeriod: "*/15 * * * * *"
```

### dapr

Configurações relacionadas ao Dapr.

* `enabled`: Habilita o Dapr na aplicação para realizar o consumo de eventos.
Possíveis valores: `true` ou `false`. Default: `true`.
* `env.pubSubId`: Identificador do componente de pub/sub do Dapr a ser utilizado.
* `appPort`: Porta utilizada para comunicação do Dapr com o Opus Data Receiver - Scheduler.
* `httpPort`: Porta utilizada pelo Opus Data Receiver para se comunicar via HTTP com o sidecard DaprReceiver - Scheduler.
* `grpcPort`: Porta utilizada pelo Opus Data Receiver para se comunicar via gRPC com o sidecard DaprReceiver - Scheduler.
* `schedulerHostAddress`: Host do produto Dapr Scheduler, usado para criação e gestão de background jobs. (Levar em conta o namespace)

```yaml
dapr:
  enabled: true
  appId: "odr-scheduler"
  appPort: 8087
  httpPort: 3500
  grpcPort: 50001
  schedulerHostAddress: "dapr-scheduler-server.oob.svc.cluster.local:50006"
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
    name: "odr_scheduler_db"
    username: "odr_scheduler_user"
    password: ""
    showLog: "false"
    persistence:
      command: 
        batchSize: "200"
        waitPeriodSeconds: "1"
```
### driver

Configurações relacionadas ao driver usado pelo Opus Data Receiver - Scheduler. 

O Opus Data Receiver - Scheduler usa o driver apenas para buscar informações sobre os recursos, baseado no padrão estabelecido pelo Open Finance Brasil e a API /resources.

Cada driver leva seu prefixo na configuração. Como essa instalação leva por padrão o driver do Open Finance Brasil, fica ofb.

 * `driver.ofb.url`: Define o endpoint da API que o Driver OFB utiliza para busca dos dados.

Esse Driver conecta a uma API Rest, por isso tem um client HTTP dentro dele.

#### driver - http client

Configurações relacionadas ao cliente Http usado pelo Opus Data Receiver - Scheduler

Obs: Todos tem prefixo `env.httpClient.`

* `connectTimeout`: Define quanto é o tempo máximo (em milissegundos) que o cliente do Opus Data Receiver - Scheduler aguardará enquanto estabelece uma conexão TCP com o servidor.
* `readTimeout`: Define quanto é o tempo máximo que o cliente do Opus Data Receiver - Scheduler aguardará para que os dados sejam lidos do servidor após a conexão ter sido estabelecida.


```yaml
env:
  driver:
    ofb:
      url: "https://obb.qa.oob.opus-software.com.br:8090"
  httpClient:
    connectTimeout: 5000
    readTimeout : 5000
```

### odr_setup

Configurações relacionadas a comunicação com a aplicação Opus Data Receiver -  Setup
Obs: Por hora o ODR - Setup está dentro do mesmo pod que o ODR -Core

* `odrSetup.url`: Define o endpoint da API do Opus Data Receiver - Setup.

```yaml
env:
  odrScheduler:
      url: "https://odr.core.qa:8090"
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

Define qual nível usado para os logs produzidos pelo Opus Data Receiver - Scheduler.
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

## Exemplo completo

```yaml

replicaCount: 1

image:
  repository: 618430153747.dkr.ecr.sa-east-1.amazonaws.com/digital-banking-microservices/odr-scheduler
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


nameOverride: ""
fullnameOverride: ""

service:
  type: ClusterIP
  port: 8087

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
  appId: "odr-scheduler"
  appPort: 8087
  httpPort: 3500
  grpcPort: 50001
  schedulerHostAddress: "dapr-scheduler-server.namespace:50006"


env:
  pubSubId: "pcm-event-pub-sub-retry"

  # Define if ODR will (true) automatically search for status updates
  # for pending setups (AWAITING_AUTHORISATION), or not (false)
  autoUpdatePendingSetup: "true"

  update:
    controlRegulatoryLimit: "false"
    dayRequestMax: 10000
    rule:

      # Define the update rule policy:
      #  RegulatoryPolicies -> Must follow the limit defined by OF.
      #       more info: (https://openfinancebrasil.atlassian.net/wiki/spaces/OF/pages/17957025/Refer+ncia)
      #        Will calculate next update date adding the frequency pre configured by the client
      #
      #  ClientPolicies -> No pre defined limit. Create a pipeline from client policies
      #        order by a crescent priority.
      #        Will use limit date form Scheduler_Update_Rule instance and
      #       <ENV_SCHEDULER_UPDATE_DAY_REQUEST_MAX> to schedule the next date.
      policy: "RegulatoryPolicies"

      # During select update rule data phase, the data is loaded in chunks
      # and streamed to process the update, and this value define the chunk size
      chunksize: 200
    job:
      name: "update-executor-job"
      # Indicates the frequency which the update data job should be wake
      # to start the process
      cronPeriod: "*/15 * * * * *"

  cron:
    # Since ENV_SCHEDULER_AUTO_UPDATE_PENDING_SETUP is true:
    # Define the period as a cron expression, to search status updates
    # for pending setups (AWAITING_AUTHORISATION)
    pendingStatus: "*/15 * * * * *"


  db:
    vendor: "postgres"
    host: "db-opus-open-banking.cbibhmphwidp.us-east-1.rds.amazonaws.com"
    port: 5432
    name: "odr_scheduler_db"
    username: "odr_scheduler_user"
    password: "password"
    showLog: "false"
    persistence:
      command: 
        batchSize: "200"
        waitPeriodSeconds: "1"

  odrSetup:
      url: "http://host.odr.core.internal:3001"


  driver:
    ofb:
      url: "http://host.oofc-core.external:3001"

  httpClient:
    connectTimeout: 5000
    readTimeout : 5000


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

```