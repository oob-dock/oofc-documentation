# Instalação do Opus Data Receiver

O Opus Data Receiver armazena e atualiza automaticamente os dados financeiros dos usuários de um cliente. 
Um usuário é um cliente para o cliente do Opus Data Receiver.

Esses dados podem ser acessados via Api REST.

## Pré-requisitos

O Opus Data Receiver usa o produto oofc-core e suas dependências (como o oofc-pcm) para acessar os dados do ambiente do Open Finance.

### Dapr

O Opus Data Receiver faz uso do [Dapr](../shared-definitions.md#dapr) para
realizar o envio de eventos internos, entre o odr-core e o odr-scheduler e, para eventos externos
direcionados aos n notificadores de seus clintes.

## Instalação

O Opus Data Receiver é dividido em 2 sistemas: odr-core e odr-scheduler
A instalação do módulo é feita via Helm Chart de cada um desses sistemas.

## [ODR-Core](readme_core.md)
## [ODR-Scheduler](readme_Scheduler.md)