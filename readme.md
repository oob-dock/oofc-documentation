# Opus Open Client

O ***Opus Open Client*** é um *middleware* que
abstrai complexidades regulatórias
e facilita o desenvolvimento de aplicações para TPPs
tanto no ecosistema de **Open Finance Brasil** quanto **Open Insurance Brasil**.

## Open Finance Brasil

Ele garante aderência aos
[padrões de segurança](https://openfinancebrasil.atlassian.net/wiki/spaces/OF/pages/17378203/Introdu+o+-+Seguran+a)
do Open Finance (ex.: [FAPI-BR](https://openbanking-brasil.github.io/specs-seguranca/open-banking-brasil-financial-api-1_ID3.html),
[DCR](https://openbanking-brasil.github.io/specs-seguranca/open-banking-brasil-dynamic-client-registration-1_ID2.html),
[padrões de certificados](https://openbanking-brasil.github.io/specs-seguranca/open-banking-brasil-certificate-standards-1_ID1.html))
e faz o gerenciamento de tokens necessários para comunicação com cada instituição
de maneira transparente,
além de executar operações de solicitação e utilização de consentimentos
de acordo com a regulamentação.
Desta forma, permite que dados e serviços do Open Finance Brasil
sejam acessados através de uma API REST tradicional.

O produto é composto por dois módulos
(que podem ser adquiridos independentemente):

1. **Receptor de Dados Cadastrais e Transacionais:**
suporta a solicitação e obtenção de dados de usuários clientes de instituições financeiras,
incluindo: dados cadastrais, transações de contas e cartões de crédito,
e informações de produtos de crédito contratados.
2. **Iniciador de Transação de Pagamento:**
suporta a iniciação e execução de transações de pagamentos,
incluindo a solicitação e subsequente consumo de consentimentos
dados por usuários clientes de instituições financeiras.

## Open Insurance Brasil

Ele garante aderência aos
[padrões de segurança](https://br-openinsurance.github.io/areadesenvolvedor/#introducao-seguranca)
do Open Insurance (ex.: [FAPI-BR](https://br-openinsurance.github.io/areadesenvolvedor/#fapi-security-profile-1-0),
[DCR](https://br-openinsurance.github.io/areadesenvolvedor/#dynamic-client-registration-dcr),
[padrões de certificados](https://br-openinsurance.github.io/areadesenvolvedor/#padrao-de-certificados))
e faz o gerenciamento de tokens necessários para comunicação com cada instituição
de maneira transparente,
além de executar operações de solicitação e utilização de consentimentos
de acordo com a regulamentação.
Desta forma, permite que dados e serviços do Open Insurance Brasil
sejam acessados através de uma API REST tradicional.

O produto é composto por um módulo

1. **Receptor de Dados Cadastrais e Apólices:**
suporta a solicitação e obtenção de dados cadastrais, de informações sobre
dados pessoais de seguro, previdência complementar aberta e capitalização.

## Visão geral

Em resumo, para utilizar das APIs do Open Finance Brasil e Open Insurance Brasil
é necessário:

1. Cadastrar a Instituição, a aplicação e seus certificados de segurança
no *Diretório de Participantes*.
2. Solicitar a criação de um **consentimento** junto a uma ***Instituição Destino***
(*Transmissora de Dados* para compartilhamento de dados
ou *Detentora de Conta* para iniciação de pagamentos).
3. Redirecionar o usuário para que ele aprove (ou rejeite) o consentimento
nos canais da Instituição Destino.
4. Consumir o consentimento, se aprovado
(obtendo dados ou efetuando uma transação de pagamento).

Detalhes do fluxo de solicitação e utilização de consentimentos
para cada tipo de operação estão disponíveis
nas seções específicas.

## Índice desta documentação para Open Finance

- [Configuração prévia](configuracao&#32;do&#32;produto/readme.md)
- [Instalação](deploy/oofc-core/readme.md)
- [Utilização do produto](utilizacao/readme.md)
    - [Receptor de Dados Cadastrais e Transacionais](utilizacao/open-finance-dados/readme.md)
    - [Iniciador de Transação de Pagamento](utilizacao/open-finance-pagamentos/readme.md)
- [Postman collection de exemplos](ferramentas-auxiliares/postman/readme.md)
- [Exemplo de uso contra o mockbank](ferramentas-auxiliares/mockbank/readme.md)
- [Relatório de interoperabilidade](ferramentas-auxiliares/relatorio-de-interoperabilidade/fase-2/readme.md)
- [Relatório semestral](ferramentas-auxiliares/relatorio-semestral/readme.md)

## Índice desta documentação para Open Insurance

- [Configuração prévia](configuracao&#32;do&#32;produto/readme.md)
- [Instalação](deploy/ooic-core/readme.md)
- [Utilização do produto](utilizacao/readme.md)
    - [Receptor de Dados Cadastrais e Apólices](utilizacao/open-insurance-dados/readme.md)
- [Postman collection de exemplos](ferramentas-auxiliares/postman/readme.md)
- [Exemplo de uso contra o mockbank](ferramentas-auxiliares/mockbank/readme.md)
