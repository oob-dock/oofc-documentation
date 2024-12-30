# Relatório de Semanal da fase 3

A Opus está fornecendo alguns scripts SQL que ajudarão os clientes na hora da coleta
de dados para criação do relatório semanal do
Open Finance Brasil **OFB**.

**OBS:** fica a cargo de nossos clientes
rodar os scripts e formatar as informações da forma e no período exigido pelo OFB.

## Scripts - Pagamento Iniciador

**Importante:** O script SQL fornecido nessa seção deve ser
executado no **banco de dados da PCM**.

É necessário criar a função *payment_initiator* executando o seguinte [script](attachments/payment_initiator.sql).

Para obter os dados, execute função com o seguinte comando:

```sql
SELECT * FROM payment_initiator('<data_inicio>','<data_fim>','<itp_id_opcional>');
```

Sendo que os parâmetros devem ser preenchidos no formato yyyy-MM-dd,
com o id do itp sendo opcional, por exemplo:

```sql
SELECT * FROM payment_initiator('2023-01-02','2023-01-08');
SELECT * FROM payment_initiator('2023-01-02','2023-01-08','27a20310-756e-43b8-a43c-6927be86b99e');

```