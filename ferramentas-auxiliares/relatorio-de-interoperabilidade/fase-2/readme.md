# Relatório de Interoperabilidade da fase 2

A Opus está fornecendo alguns scripts SQL que ajudarão os clientes na hora da coleta
de dados para criação do relatório de interoperabilidade do
Open Finance Brasil **OFB**.

**OBS:** fica a cargo de nossos clientes
rodar os scripts e formatar as informações da forma e no período exigido pelo OFB.

## Scripts - Consentimento Receptor

**Importante:** O script SQL fornecido nessa seção deve ser
executado no **banco de dados do OOD4TPP**.

É necessário criar a função *consent_receptor* executando o seguinte [script](attachments/consent_receptor.sql).

Para obter os dados, execute função com o seguinte comando:

```sql
SELECT * FROM consent_receptor('<data_inicio>','<data_fim>','<org_id_opcional>');
```

Sendo que os parâmetros devem ser preenchidos no formato yyyy-MM-dd, 
com o id da organização sendo opcional, por exemplo:

```sql
SELECT * FROM consent_receptor('2023-01-02','2023-01-08');
SELECT * FROM consent_receptor('2023-01-02','2023-01-08','27a20310-756e-43b8-a43c-6927be86b99e');

```

## Scripts - Estoque de consentimentos

**Importante:** Os scripts SQL fornecidos nessa seção devem ser
executados no **banco de dados do OOD4TPP**.

### Quantidade de clientes ativos

É necessário criar a função *consent_stock_clients* executando o seguinte [script](attachments/consent_stock_clients.sql).

Para obter os dados, execute função com o seguinte comando:

```sql
SELECT * FROM consent_stock_clients('<data_fim>','<org_id_opcional>');
```

Sendo que os parâmetros devem ser preenchidos no formato yyyy-MM-dd,
com o id da organização sendo opcional, por exemplo:

```sql
SELECT * FROM consent_stock_clients('2023-01-08');
SELECT * FROM consent_stock_clients('2023-01-08', '27a20310-756e-43b8-a43c-6927be86b99e');
```

### Quantidade de consentimentos ativos

É necessário criar a função *consent_stock* executando o seguinte [script](attachments/consent_stock.sql).

Para obter os dados, execute função com o seguinte comando:

```sql
SELECT * FROM consent_stock('<data_fim>', '<org_id_opcional>');
```

Sendo que os parâmetros devem ser preenchidos no formato yyyy-MM-dd,
com o id da organização sendo opcional, por exemplo:

```sql
SELECT * FROM consent_stock('2023-01-08');
SELECT * FROM consent_stock('2023-01-08', '27a20310-756e-43b8-a43c-6927be86b99e');
```

## Scripts - Consumo receptor

**Importante:** O script SQL fornecido nessa seção deve ser
executado no **banco de dados do serviço PCM**.

É necessário criar a função *consent_consume* executando o seguinte [script](attachments/consent_consume.sql).

Para obter os dados, execute função com o seguinte comando:

```sql
SELECT * FROM consent_consume('<data_inicio>','<data_fim>', '<brand_id_opcional>');
```

Sendo que os parâmetros devem ser preenchidos no formato yyyy-MM-dd,
com o id da marca sendo opcional, por exemplo:

```sql
SELECT * FROM consent_consume('2023-01-02','2023-01-08');
SELECT * FROM consent_consume('2023-01-02','2023-01-08', '27a20310-756e-43b8-a43c-6927be86b99e');
```

## Informações da transmissora

Para obter as informações da organização transmissora deve-se executar o script
[getOrganization](../../get-organisation-script/getOrganization.js)
informando os IDs dos Authorisation Servers retornados pela consulta *consent_receptor*,
*consent_stock_clients* e *consent_stock* ou os IDs das organizações retornados pela
consulta *consent_consume*.

Será necessário instalar a versão do [Node.js](https://nodejs.org/en/download)
correspondente ao seu Sistema Operacional.

Com o Node.js instalado, execute o seguinte comando da raiz desse projeto:

```bash
node ferramentas-auxiliares/get-organisation-script/getOrganization.js [TIPO_CONSULTA] [IDs das transmissores]
```

Para consultas por Authorisation Server, o parâmetro *TIPO_CONSULTA* deve possuir
o valor **AS**. Para consultas por Organização, o valor deve ser **ORG**.

Os identificadores devem ser separados por espaço,
conforme exemplo abaixo:

```bash
$ node ferramentas-auxiliares/get-organisation-script/getOrganization.js AS e5355a94-5218-4314-82f9-1a5cabdde134 64508ff9-8453-4dc4-8aff-cb526aac837b eaf49708-0c81-46bc-ac42-6b8378485544
----------------------------------------------
Auth ID: e5355a94-5218-4314-82f9-1a5cabdde134
Organisation Id: 062c5edb-4e83-5002-9981-e2a96c5ad41e
Organisation Name: BCO VOTORANTIM S.A.
Parent Organization: N/A
----------------------------------------------
Auth ID: 64508ff9-8453-4dc4-8aff-cb526aac837b
Organisation Id: fd0ea3e7-aeca-55f9-a0a2-ec56980059fb
Organisation Name: BCO WOORI BANK DO BRASIL S.A.
Parent Organization: N/A
----------------------------------------------
Auth ID: eaf49708-0c81-46bc-ac42-6b8378485544
Organisation Id: 18543a69-338d-5e5b-8aa3-dc640ef5f4a2
Organisation Name: UNIPRIME CENTRAL CCC LTDA.
Parent Organization: 03046391000173
----------------------------------------------
```

```bash
$ node ferramentas-auxiliares/get-organisation-script/getOrganization.js ORG e1d52399-a2a1-53be-a84b-085c1a94aac5 dac315e0-71bd-52e4-8294-cea70640ffc9
----------------------------------------------
Organisation Id: b185ecfd-53b1-51ac-86bf-51d6cd66d828
Organisation Name: SISPRIME DO BRASIL - COOPERATIVA DE CREDITO
Parent Organization: N/A
----------------------------------------------
Organisation Id: dac315e0-71bd-52e4-8294-cea70640ffc9
Organisation Name: BCO CREFISA S.A.
Parent Organization: 60779196000196
----------------------------------------------
```

Caso a transmissora não possua uma Parent Organization, o retorno do script para
ela será *N/A*. Caso não exista uma transmissora relacionada ao ID informado,
o retorno será *Not found*.

**IMPORTANTE**: Pode ser necessário somar os valores retornados pelos scripts
*consent_receptor*, *consent_stock_clients* e *consent_stock* caso Authorisation
Servers diferentes pertençam a mesma organização.
