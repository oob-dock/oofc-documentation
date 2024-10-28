drop function if exists consent_consume;
create or replace function consent_consume(dt_start date, dt_end date, brand VARCHAR(36) default null)
	returns table (
		receptor				UUID,
		transmitter				UUID,
		endpoint_uri			TEXT,
		response_code			TEXT,
		api						TEXT,
		endpoint_description	TEXT,
		version					TEXT,
		method					TEXT,
		brand_id                VARCHAR(36),
		qty_requests			BIGINT
	)
language plpgsql
as $function$
declare dt_start_utc timestamptz;
declare dt_end_interval date;
declare dt_end_utc timestamptz;
begin
    select dt_end + INTERVAL '1 day' INTO dt_end_interval;
    select dt_start::date::timestamp AT TIME ZONE 'UTC' INTO dt_start_utc;
    select dt_end_interval::date::timestamp AT TIME ZONE 'UTC' INTO dt_end_utc;

	return query
		with endpoints as (
			select
				case
					WHEN r.event_data#>>'{endpoint}' LIKE '%/consents/v%/consents%' THEN 'Consentimento'
					WHEN r.event_data#>>'{endpoint}' LIKE '%/resources/v%/resources%' THEN 'Resources'
					WHEN r.event_data#>>'{endpoint}' LIKE '%/customers/%' THEN 'Dados Cadastrais'
					WHEN r.event_data#>>'{endpoint}' LIKE '%/credit-cards-accounts/v%/accounts%' THEN 'Cartão de crédito'
					WHEN r.event_data#>>'{endpoint}' LIKE '%/accounts/v%/accounts%' THEN 'Contas'
					WHEN r.event_data#>>'{endpoint}' LIKE '%/loans/v%/contracts%' THEN 'Empréstimos'
					WHEN r.event_data#>>'{endpoint}' LIKE '%/financings/v%/contracts%' THEN 'Financiamentos'
					WHEN r.event_data#>>'{endpoint}' LIKE '%/unarranged-accounts-overdraft/v%/contracts%' THEN 'Adiantamento a Depositantes'
					WHEN r.event_data#>>'{endpoint}' LIKE '%/invoice-financings/v%/contracts%' THEN 'Direitos Creditórios Descontados'
				end 																	as api,
				case
					WHEN r.event_data#>>'{endpoint}' LIKE '%/consents/v%/consents' THEN 'Criar novo pedido de consentimento'
					WHEN r.event_data#>>'{endpoint}' LIKE '%/consents/v%/consents/%' AND r.event_data#>>'{httpMethod}' = 'GET' THEN 'Obter detalhes do consentimento identificado por consentId'
					WHEN r.event_data#>>'{endpoint}' LIKE '%/consents/v%/consents/%' AND r.event_data#>>'{httpMethod}' = 'DELETE' THEN 'Deletar / Revogar o consentimento identificado por consentId'
					WHEN r.event_data#>>'{endpoint}' LIKE '%/resources%' THEN 'Obtém a lista de recursos consentidos pelo cliente'
					WHEN r.event_data#>>'{endpoint}' LIKE '%/personal/identifications' THEN 'Identificação pessoa natural'
					WHEN r.event_data#>>'{endpoint}' LIKE '%/business/identifications' THEN 'Identificação pessoa jurídica'
					WHEN r.event_data#>>'{endpoint}' LIKE '%/personal/qualifications' THEN 'Qualificação pessoa natural'
					WHEN r.event_data#>>'{endpoint}' LIKE '%/business/qualifications' THEN 'Qualificação pessoa jurídica'
					WHEN r.event_data#>>'{endpoint}' LIKE '%/personal/financial-relations' THEN 'Relacionamento pessoa natural'
					WHEN r.event_data#>>'{endpoint}' LIKE '%/business/financial-relations' THEN 'Relacionamento pessoa jurídica'
					WHEN r.event_data#>>'{endpoint}' LIKE '%/credit-cards-accounts/v%/accounts' THEN 'Lista de cartões de crédito'
					WHEN r.event_data#>>'{endpoint}' LIKE '%/credit-cards-accounts/v%/accounts/%/limits%' THEN 'Limites de cartão de crédito'
					WHEN r.event_data#>>'{endpoint}' LIKE '%/credit-cards-accounts/v%/accounts/%/bills/%/transactions%' THEN 'Transações de cartão de crédito por fatura'
					WHEN r.event_data#>>'{endpoint}' LIKE '%/credit-cards-accounts/v%/accounts/%/transactions%' THEN 'Transações de cartão de crédito'
					WHEN r.event_data#>>'{endpoint}' LIKE '%/credit-cards-accounts/v%/accounts/%/transactions-current%' THEN 'Transações de cartão de crédito'
					WHEN r.event_data#>>'{endpoint}' LIKE '%/credit-cards-accounts/v%/accounts/%/bills%' THEN 'Fatura de Cartão de Crédito'
					WHEN r.event_data#>>'{endpoint}' LIKE '%/credit-cards-accounts/v%/accounts/%' THEN 'Identificação de cartão de crédito'
					WHEN r.event_data#>>'{endpoint}' LIKE '%/accounts/v%/accounts' THEN 'Lista de contas'
					WHEN r.event_data#>>'{endpoint}' LIKE '%/accounts/v%/accounts/%/balances' THEN 'Saldos da conta'
					WHEN r.event_data#>>'{endpoint}' LIKE '%/accounts/v%/accounts/%/transactions' THEN 'Transações da conta'
					WHEN r.event_data#>>'{endpoint}' LIKE '%/accounts/v%/accounts/%/transactions-current' THEN 'Transações da conta'
					WHEN r.event_data#>>'{endpoint}' LIKE '%/accounts/v%/accounts/%/overdraft-limits' THEN 'Limites da conta'
					WHEN r.event_data#>>'{endpoint}' LIKE '%/accounts/v%/accounts/%' THEN 'Identificação da conta'
					WHEN r.event_data#>>'{endpoint}' LIKE '%/loans/v%/contracts' THEN 'Empréstimos'
					WHEN r.event_data#>>'{endpoint}' LIKE '%/loans/v%/contracts/%/warranties' THEN 'Empréstimos - Garantias do Contrato'
					WHEN r.event_data#>>'{endpoint}' LIKE '%/loans/v%/contracts/%/payments' THEN 'Empréstimos - Pagamentos do Contrato'
					WHEN r.event_data#>>'{endpoint}' LIKE '%/loans/v%/contracts/%/scheduled-instalments' THEN 'Empréstimos - Parcelas do Contrato'
					WHEN r.event_data#>>'{endpoint}' LIKE '%/loans/v%/contracts/%' THEN 'Empréstimos - Contrato'
					WHEN r.event_data#>>'{endpoint}' LIKE '%/financings/v%/contracts' THEN 'Financiamentos'
					WHEN r.event_data#>>'{endpoint}' LIKE '%/financings/v%/contracts/%/warranties' THEN 'Financiamentos - Garantias do Contrato'
					WHEN r.event_data#>>'{endpoint}' LIKE '%/financings/v%/contracts/%/payments' THEN 'Financiamentos - Pagamentos do Contrato'
					WHEN r.event_data#>>'{endpoint}' LIKE '%/financings/v%/contracts/%/scheduled-instalments' THEN 'Financiamentos - Parcelas do Contrato'
					WHEN r.event_data#>>'{endpoint}' LIKE '%/financings/v%/contracts/%' THEN 'Financiamentos - Contrato'
					WHEN r.event_data#>>'{endpoint}' LIKE '%/unarranged-accounts-overdraft/v%/contracts' THEN 'Adiantamento a Depositantes'
					WHEN r.event_data#>>'{endpoint}' LIKE '%/unarranged-accounts-overdraft/v%/contracts/%/warranties' THEN 'Adiantamento a Depositantes - Garantias do Contrato'
					WHEN r.event_data#>>'{endpoint}' LIKE '%/unarranged-accounts-overdraft/v%/contracts/%/payments' THEN 'Adiantamento a Depositantes - Pagamentos do Contrato'
					WHEN r.event_data#>>'{endpoint}' LIKE '%/unarranged-accounts-overdraft/v%/contracts/%/scheduled-instalments' THEN 'Adiantamento a Depositantes - Parcelas do Contrato'
					WHEN r.event_data#>>'{endpoint}' LIKE '%/unarranged-accounts-overdraft/v%/contracts/%' THEN 'Adiantamento a Depositantes - Contrato'
					WHEN r.event_data#>>'{endpoint}' LIKE '%/invoice-financings/v%/contracts' THEN 'Direitos Creditórios Descontados'
					WHEN r.event_data#>>'{endpoint}' LIKE '%/invoice-financings/v%/contracts/%/warranties' THEN 'Direitos Creditórios Descontados - Garantias do Contrato'
					WHEN r.event_data#>>'{endpoint}' LIKE '%/invoice-financings/v%/contracts/%/payments' THEN 'Direitos Creditórios Descontados - Pagamentos do Contrato'
					WHEN r.event_data#>>'{endpoint}' LIKE '%/invoice-financings/v%/contracts/%/scheduled-instalments' THEN 'Direitos Creditórios Descontados - Parcelas do Contrato'
					WHEN r.event_data#>>'{endpoint}' LIKE '%/invoice-financings/v%/contracts/%' THEN 'Direitos Creditórios Descontados - Contrato'
				end																	  as endpoint_description,
				case
					WHEN r.event_data#>>'{endpoint}' LIKE '%/consents/v%/consents/%' then (REGEXP_REPLACE(r.event_data#>>'{endpoint}', 'v(.*)/consents/.*', 'v\1/consents/{consentId}'))
			        WHEN r.event_data#>>'{endpoint}' LIKE '%/accounts/%/bills/%/transactions' then (REGEXP_REPLACE(r.event_data#>>'{endpoint}', 'v(.*)/accounts/.*/bills/.*/transactions', 'v\1/accounts/{creditCardAccountId}/bills/{billId}/transactions'))
			        WHEN r.event_data#>>'{endpoint}' LIKE '%credit-cards-accounts/v%/accounts/%/%' then (REGEXP_REPLACE(r.event_data#>>'{endpoint}', 'v(.*)/accounts/.*/', 'v\1/accounts/{creditCardAccountId}/'))
			        WHEN r.event_data#>>'{endpoint}' LIKE '%credit-cards-accounts/v%/accounts/%' then (REGEXP_REPLACE(r.event_data#>>'{endpoint}', 'v(.*)/accounts/.*', 'v\1/accounts/{creditCardAccountId}'))
			        WHEN r.event_data#>>'{endpoint}' LIKE '%/v%/accounts/%/%' then (REGEXP_REPLACE(r.event_data#>>'{endpoint}', 'v(.*)/accounts/.*/', 'v\1/accounts/{accountId}/'))
			        WHEN r.event_data#>>'{endpoint}' LIKE '%/v%/accounts/%' then (REGEXP_REPLACE(r.event_data#>>'{endpoint}', 'v(.*)/accounts/.*', 'v\1/accounts/{accountId}'))
			        WHEN r.event_data#>>'{endpoint}' LIKE '%/v%/contracts/%/%' then (REGEXP_REPLACE(r.event_data#>>'{endpoint}', 'v(.*)/contracts/.*/', 'v\1/contracts/{contractId}/'))
			        WHEN r.event_data#>>'{endpoint}' LIKE '%/v%/contracts/%' then (REGEXP_REPLACE(r.event_data#>>'{endpoint}', 'v(.*)/contracts/.*', 'v\1/contracts/{contractId}'))
			        else (r.event_data#>>'{endpoint}')
				end																		as endpoint_uri,
				REGEXP_REPLACE(r.event_data#>>'{endpoint}', '.*/(v\d+)/.*', '\1')		as "version",
				client_org_id 															as receptor,
				server_org_id															as transmitter,
				r.event_data#>>'{statusCode}'											as response_code,
				r.event_data#>>'{httpMethod}'											as method,
				r.brand_id                                                              as brand_id
		from report r
		where r.event_role = 'CLIENT'
		and created_at between dt_start_utc and dt_end_utc)
		select	endpoints.receptor,
				endpoints.transmitter,
				endpoints.endpoint_uri,
				endpoints.response_code,
				endpoints.api,
				endpoints.endpoint_description,
				endpoints."version",
				endpoints."method",
				endpoints.brand_id,
				count(*)						as qty_requests
		from endpoints
		where endpoints.api is not null and (endpoints.brand_id = brand or brand is null)
		group by endpoints.receptor, endpoints.transmitter, endpoints.endpoint_uri, endpoints.response_code, endpoints.api, endpoints.endpoint_description, endpoints.method, endpoints."version", endpoints.brand_id;
end;$function$
;
