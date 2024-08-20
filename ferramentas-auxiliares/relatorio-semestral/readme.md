# Relatório Semestral

A Opus está fornecendo alguns scripts SQL que ajudarão os clientes na hora da coleta
de dados para criação do relatório semestral do Open Finance Brasil **OFB**.

**OBS:** fica a cargo de nossos clientes
rodar os scripts e formatar as informações da forma e no período exigido pelo OFB.

## Scripts - Quantidade de chamadas - Consentimento Recepção

**Importante:** O script SQL fornecido nessa seção deve ser
executado no **banco de dados do PCM**.

Para obter os dados, execute a query abaixo:

```sql
@set initial_date = '<data_inicial> 00:00:00.000 -0300'
@set final_date = '<data_final> 23:59:59.999 -0300'

with
result_tab AS (
	WITH endpoints_table as (
	SELECT date_trunc('month', created_at,'America/Sao_Paulo') as ano_mes, (event_data->>'endpoint'::text) as endpoint
	FROM public.report
	where event_role = 'CLIENT'
	and created_at between :initial_date and :final_date
	and event_data->>'endpoint'::text not in ('/register','/token'))
	
	SELECT TO_CHAR(ano_mes,'yyyy-MM') as ano_mes, count(1) as qtd_chamadas
	FROM endpoints_table
	where endpoint like '/open-banking/consents%'
	group by TO_CHAR(ano_mes,'yyyy-MM')
	order by TO_CHAR(ano_mes,'yyyy-MM')
)

select *
from result_tab;
```

Sendo que os parâmetros <data_inicial> e <data_final> devem ser preenchidos no formato 
yyyy-MM-dd, por exemplo:

```sql
@set initial_date = '2024-01-01 00:00:00.000 -0300'
@set final_date = '2024-06-30 23:59:59.999 -0300'

```

## Scripts - Quantidade de chamadas - Resources Recepção

**Importante:** O script SQL fornecido nessa seção deve ser
executado no **banco de dados do PCM**.

Para obter os dados, execute a query abaixo:

```sql
@set initial_date = '<data_inicial> 00:00:00.000 -0300'
@set final_date = '<data_final> 23:59:59.999 -0300'

with
result_tab AS (

	WITH endpoints_table as (
	SELECT date_trunc('month', created_at,'America/Sao_Paulo') as ano_mes, (event_data->>'endpoint'::text) as endpoint
	FROM public.report
	where event_role = 'CLIENT'
	and created_at between :initial_date and :final_date	
	and event_data->>'endpoint'::text not in ('/register','/token'))
	
	SELECT TO_CHAR(ano_mes,'yyyy-MM') as ano_mes, count(1) as qtd_chamadas
	FROM endpoints_table
	where endpoint like '/open-banking/resources%'
	group by TO_CHAR(ano_mes,'yyyy-MM')
	order by TO_CHAR(ano_mes,'yyyy-MM')
)

select *
from result_tab;
```

Sendo que os parâmetros <data_inicial> e <data_final> devem ser preenchidos no formato 
yyyy-MM-dd, por exemplo:

```sql
@set initial_date = '2024-01-01 00:00:00.000 -0300'
@set final_date = '2024-06-30 23:59:59.999 -0300'

```

## Scripts - Quantidade de chamadas - Dados Cadastrais Recepção

**Importante:** O script SQL fornecido nessa seção deve ser
executado no **banco de dados do PCM**.

Para obter os dados, execute a query abaixo:

```sql
@set initial_date = '<data_inicial> 00:00:00.000 -0300'
@set final_date = '<data_final> 23:59:59.999 -0300'

with
result_tab AS (

	WITH endpoints_table as (
	SELECT date_trunc('month', created_at,'America/Sao_Paulo') as ano_mes, (event_data->>'endpoint'::text) as endpoint
	FROM public.report
	where event_role = 'CLIENT'
	and created_at between :initial_date and :final_date	
	and event_data->>'endpoint'::text not in ('/register','/token'))
	
	SELECT TO_CHAR(ano_mes,'yyyy-MM') as ano_mes, count(1) as qtd_chamadas
	FROM endpoints_table
	where endpoint like '/open-banking/customers%'
	group by TO_CHAR(ano_mes,'yyyy-MM')
	order by TO_CHAR(ano_mes,'yyyy-MM')
)

select *
from result_tab;
```

Sendo que os parâmetros <data_inicial> e <data_final> devem ser preenchidos no formato 
yyyy-MM-dd, por exemplo:

```sql
@set initial_date = '2024-01-01 00:00:00.000 -0300'
@set final_date = '2024-06-30 23:59:59.999 -0300'

```

## Scripts - Quantidade de chamadas - Dados Transacionais Recepção

**Importante:** O script SQL fornecido nessa seção deve ser
executado no **banco de dados do PCM**.

Para obter os dados, execute a query abaixo:

```sql
@set initial_date = '<data_inicial> 00:00:00.000 -0300'
@set final_date = '<data_final> 23:59:59.999 -0300'

with
result_tab AS (

	WITH endpoints_table as (
	SELECT date_trunc('month', created_at,'America/Sao_Paulo') as ano_mes, (event_data->>'endpoint'::text) as endpoint
	FROM public.report
	where event_role = 'CLIENT'
	and created_at between :initial_date and :final_date	
	and event_data->>'endpoint'::text not in ('/register','/token'))
	
	SELECT TO_CHAR(ano_mes,'yyyy-MM') as ano_mes, count(1) as qtd_chamadas
	FROM endpoints_table
	where endpoint not like '/open-banking/consents%' and endpoint not like '/open-banking/resources%' and endpoint not like '/open-banking/customers%'
	and endpoint not like '/open-banking/payments%' and endpoint not like '/open-banking/automatic-payments%'
	group by TO_CHAR(ano_mes,'yyyy-MM')
	order by TO_CHAR(ano_mes,'yyyy-MM')
)

select *
from result_tab;
```

Sendo que os parâmetros <data_inicial> e <data_final> devem ser preenchidos no formato 
yyyy-MM-dd, por exemplo:

```sql
@set initial_date = '2024-01-01 00:00:00.000 -0300'
@set final_date = '2024-06-30 23:59:59.999 -0300'

```
