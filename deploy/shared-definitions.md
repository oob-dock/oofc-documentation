# Definições compartilhadas

## Dapr

O [Dapr](https://dapr.io/) é um *Runtime* de Aplicações Distribuídas que visa
simplificar a conectividade entre microsserviços atráves de vários
[blocos de construção](https://docs.dapr.io/concepts/building-blocks-concept/).

O Opus Open Finance Client faz uso do seguinte bloco de construção do Dapr:

* Publish and Subscribe: Utilizado para publicar e consumir eventos de chamadas
de APIs que devem ser reportados para a PCM (Plataform de Coleta de Métricas)

## Scripts DDL

Os scripts DDL serão aplicados em um processo separado da execução do serviço.
Para configurar a execução destes scripts será necessário ajustar os valores
das seguintes propriedades:

```yaml
  db:
    ddl:
      username: "ddl-username"
      password: "ddl-password"
      logLevel: "info"
```

**Observação**: a configuração de `logLevel` pode assumir um
dos seguintes valores: `emerg`, `error`, `warn`, `info` ou `debug`.

**Importante**: O uso do nível de log `debug` **NÃO** é recomendado, pois
pode gerar uma grande quantidade de informações desnecessárias.
Isso pode dificultar a leitura dos logs e ocultar mensagens importantes
em meio ao excesso de dados.