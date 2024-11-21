# Instalação do Opus Open Finance Client

## Pré-requisitos

Para a configuração das chaves essas precisam estar propriamente cadastradas.
Para mais informações veja a página sobre o [cadastro do TPP](../../configuracao%20do%20produto/readme.md).

As chaves privadas de certificados devem ser persistidas de forma segura.
É possível fazer isso utilizando *secrets* no Kubernetes.

### Criação do(s) secret(s) para armazenar as chaves privadas

Para criar um secret com o conteúdo de um diretório:

```shell
kubectl -n <NOME_DO_NAMESPACE> create secret generic <NOME_DO_SECRET> --from-file=<CAMINHO_DO_DIRETORIO>
```

Por exemplo, se as chaves estão armazenadas em um diretório local:

```shell
$ ls /tmp/oofc
enc.key sig.key enc.cert
$ kubectl -n oofc create secret generic oofc-tpp-keys --from-file=/tmp/oofc
secret/oofc-tpp-keys created
```

Para descrever o conteúdo do secret:

```shell
$ kubectl -n oofc get secret oofc-tpp-keys -o yaml
apiVersion: v1
data:
  enc.key: LS0t.................LS0t
  sig.key: LS0t.................LQ==
  enc.cert: LS0t.................ALQr
  id_token_enc.key: LS0t.................LS0K
kind: Secret
metadata:
  creationTimestamp: "2022-06-20T20:40:31Z"
  name: oofc-tpp-keys
  namespace: oofc
  resourceVersion: "105304459"
  selfLink: /api/v1/namespaces/oofc/secrets/oofc-tpp-keys
  uid: fe0dc884-9e9a-4874-bfc0-c937861c4394
type: Opaque
```

### Dapr

O Opus Open Finance Client faz uso do [Dapr](../shared-definitions.md#dapr) para
realizar o envio de eventos do tipo cliente nas chamadas direcionadas à
Transmissora de Dados/Detentora de Conta que devem ser reportadas à Plataforma
de Coleta de Métricas (PCM).

## Instalação

A instalação do módulo é feita via Helm Chart.

## Configuração

A configuração é feita através de um arquivo YAML.
As seções necessárias são descritas a seguir.

### services

Configuração do serviço

* `directoryAuthUrl`: Endereço base do authorisation server para acesso as
  APIs do diretório central
* `directoryApiUrl`: Endereço base da Api do diretório central
* `directoryPartUrl`: Endereço base da API de participantes do diretório central
* `directoryKeystoreUrl`: Endereço base da API de chaves públicas do diretório central

Exemplo:

```yaml
env:
  services:
    directoryAuthUrl: https://auth.sandbox.directory.openbankingbrasil.org.br
    directoryApiUrl: https://matls-api.sandbox.directory.openbankingbrasil.org.br
    directoryPartUrl: https://data.sandbox.directory.openbankingbrasil.org.br
    directoryKeystoreUrl: https://keystore.sandbox.directory.openbankingbrasil.org.br
```

### privateKeys

Lista de chaves privadas utilizadas para encriptar ou assinar mensagens.
As chaves devem ser geradas no diretório de participantes.

* `brSealSecretName`: nome do secret do Kubernetes que contém o certificado de assinatura.
* `brSealSecretKey`: nome da chave da secret que contém o certificado de
assinatura (BRSEAL).
* `brSealId`: código identificador da organização.
* `brcacSecretName`: nome do secret do Kubernetes que contém o certificado de transporte.
* `brcacSecretKey`: nome da chave da secret que contém o certificado de
transporte (BRCAC).
* `brcacKeySecretName`: nome do secret do Kubernetes que contém
a chave privada do certificado de transporte.
* `brcacKeySecretKey`:nome da chave da secret que contém a chave do
certificado de transporte.
* `brIdTokenEncSecretName`: nome do secret do Kubernetes que contém o certificado
de criptografia.
* `brIdTokenEncSecretKey`: nome da chave da secret que contém o certificado de criptografia.
* `softwareStatementId`: código identificador da aplicação.
* `securityProfilePriority`: lista de prioridade dos modos de autenticação.
  É obrigatório listar os quatro formatos, sendo eles:
  `private_key_jwt_par`, `private_key_jwt`, `tls_client_auth_par`, `tls_client_auth`.

Exemplo:

```yaml
env:
  privateKeys:
    - brSealSecretName: "oofc-tpp-keys"
      brSealSecretKey : "sig.key"
      brSealId : "3229f80d-7e31-4f2d-a59c-689a8ace632c"
      softwareStatements:
        - brcacSecretName: "oofc-tpp-keys"
          brcacSecretKey: "enc.cert"
          brcacKeySecretName: "oofc-tpp-keys"
          brcacKeySecretKey: "enc.key"
          brIdTokenEncSecretName: "oofc-tpp-keys"
          brIdTokenEncSecretKey: "id_token_enc.key"
          softwareStatementId: "e3c4bde9-5b86-4782-be87-33cf7f46b6bb"
          securityProfilePriority: "private_key_jwt_par,private_key_jwt,tls_client_auth,tls_client_auth_par"
```

### db

Configuração de acesso ao banco

* `name`: Nome da base.
* `username`: Nome do usuário de acesso ao banco.
* `password`: Senha do usuário de acesso ao banco.
* `host`: Host do banco.
* `port`: Porta do banco de dados.

```yaml
env:
  db:
    name: "oofc_core"
    username: "oofc_core"
    password: "oofc_core"
    host: "postgres.local"
    port: 5001
```

### config

* `logLevel`: Define o nível de detalhe do log da aplicação. É recomendável
ativar o nível `DEBUG` somente em ambientes de desenvolvimento/homologação,
ou para facilitar a análise de erros em produção.
Em produção é aconselhável utilizar o nível `INFO`.
* `redirectUri`: Define a uri padrão na qual os consentimentos devem ser
redirecionados. Será utilizado caso não seja configurado um `fqdn` no `application`
conforme especificado na [configuração do produto](../../configuracao%20do%20produto/readme.md).
Deve apontar para a url de instalação do OpusTPP e ser completado por `/opus-open-finance`.
É **importante** que as url's sejam configuradas como redirect url's permitidas no
software-statement.
    * Exemplo da variável na instalação da OPUS de QA: `https://client.qa.oofc.opus-software.com.br/opus-open-finance`
    * Exemplo da url permitida no software-statement para client de dados: `https://client.qa.oofc.opus-software.com.br/opus-open-finance/consents/redirect-uri`
    * Exemplo da url permitida no software-statement para client de pagamentos: `https://client.qa.oofc.opus-software.com.br/opus-open-finance/payments/redirect-uri`
* `issuerCacheTime`: Variável de cache em segundos para guardar informações do
.well-know das detentoras chamadas com o uso do OOB4TPP. Caso não
veja necessidade pode desativar com o issuerCacheTime: "0".
* `androidAssetLinksFile`: Lista de configurações de *asset links* do Android.
  * `fqdn`: Determina que o arquivo definido no campo `value` será retornado
  apenas quando a rota do *asset links* for acessada a partir deste `FQDN`.
  Caso esse campo seja omitido, o `value` será retornado por padrão para
  qualquer `FQDN` que não esteja atrelado a um valor.
  * `value`: Variável responsável por armazenar o conteúdo do arquivo de *asset
  links*. O conteúdo do arquivo deverá ser configurado como *plain text* e será
  exposto na rota `GET https://<FQDN>/.well-known/assetlinks.json`.
* `appleAppSiteAssociationFile`: Lista de configuração do *Apple App Site Association*
para IOS.
  * `fqdn`: Determina que o arquivo definido no campo `value` será retornada
  apenas quando a rota do *Apple App Site Association* for acessada a partir deste
  `FQDN`. Caso esse campo seja omitido, o `value` será retornado por padrão para
  qualquer `FQDN` que não esteja atrelado a um valor.
  * `value`: Variável responsável por armazenar o conteúdo do arquivo de *Apple
  App Site Association*. O conteúdo do arquivo deverá ser configurado como *plain
  text* e será exposto na rota `GET https://<fqdn>/.well-known/apple-app-site-association.json`.

```yaml
env:
  config:
    logLevel: "DEBUG"
    issuerCacheTime: "0"
    redirectUri: "https://client.qa.oofc.opus-software.com.br/opus-open-finance"
    androidAssetLinksFile:
      - value: '{\"msg\": \"Android asset links not configured\"}'
      - fqdn: client.qa.oofc.opus-software.com.br
        value: '[{\"relation\":[\"delegate_permission/common.handle_all_urls\"],\"target\":{\"namespace\":\"android_app\",\"package_name\":\"br.com.teste.app\",\"sha256_cert_fingerprints\":[]}}]'
    appleAppSiteAssociationFile:
      - value: '{\"applinks\":{\"apps\":[],\"details\":[{\"appID\":\"6KBUHP7MVP.org.reactjs.native.example.app2as\",\"paths\":[\"/auth/auth\",\"/auth/handoff/*\"],\"appIDs\":[\"6KBUHP7MVP.org.reactjs.native.example.app2as\"],\"components\":[{\"/\":\"/auth/auth\"},{\"/\":\"/auth/handoff/*\"}]}]}}'
```

### dapr

Configurações relacionadas ao Dapr.

* `enabled`: Habilita o Dapr na aplicação para realizar o consumo de eventos.
Possíveis valores: `true` ou `false`. Default: `true`.
* `daprPubsubId`: Identificador do componente de pub/sub do Dapr a ser utilizado.
* `daprPubsubWebhookId`: Identificador do componente de pub/sub do Dapr a ser utilizado para eventos de webhook. (Pode ser usado o mesmo do daprPubsubId)
* `daprAppPort`: Porta utilizada para comunicação do Dapr com o oofc-core.
* `schedulerHostAddress`: host + porta do scheduler dapr interno. Deve ser considerado o namespace, caso esteja em um diferente, como no exemplo.
* * Para que serve o Scheduler Dapr? - Para gerenciamento de jobs do Opus Open Finance Client, que devem executar em background. 
* * Posso ficar sem o Scheduler? Não! Sem essa ferramenta, algumas funcionalidades não funcionarão corretamente.  

```yaml
env:
  dapr:
    enabled: "true"
    daprPubsubId: "pcm-event-pub-sub"
    daprPubsubWebhookId: "pcm-event-pub-sub"
    schedulerHostAddress: "dapr-scheduler-server.oob.svc.cluster.local:50006"
    daprAppPort: 3002
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

### OUTGOING_HTTP_LOGGER_ENABLED

Define se a aplicação deverá logar todos os requests e responses das chamadas
HTTP de saída. Por padrão este log é **habilitado**.

**Formato:** `true` para habilitado ou `false` para desabilitado.

**Ex:**

```yaml
additionalVars:
  - name: OUTGOING_HTTP_LOGGER_ENABLED
    value: "true"
```

### SEQUELIZE_POOL_CONNECTION_MIN

Define o tamanho mínimo do pool de conexões com a base de dados. Por padrão este log é **1**.

**Formato:** inteiro

**Ex:**

```yaml
additionalVars:
  - name: SEQUELIZE_POOL_CONNECTION_MIN
    value: "1"
```

### SEQUELIZE_POOL_CONNECTION_MAX

Define o tamanho máximo do pool de conexões com a base de dados. Por padrão este log é **5**.

**Formato:** inteiro

**Ex:**

```yaml
additionalVars:
  - name: SEQUELIZE_POOL_CONNECTION_MAX
    value: "5"
```

### SEQUELIZE_LOG_ENABLED

Define se a aplicação deverá logar todos logs do sequelize. Por padrão este log é **desabilitado**.

**Formato:** `true` para habilitado ou `false` para desabilitado.

**Ex:**

```yaml
additionalVars:
  - name: SEQUELIZE_LOG_ENABLED
    value: "false"
```
