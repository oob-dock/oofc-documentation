drop function if exists payment_initiator;
create or replace function payment_initiator(dt_start date, dt_end date, itp uuid default null)
	returns table (
		itp_id			UUID,
		org_id			UUID,
		api				TEXT,
		endpoint 		TEXT,
		status_code 	TEXT,
		method 			TEXT,
		endpoint_uri 	TEXT,
		api_version 	TEXT,
		error_code 		TEXT,
		produto 		TEXT,
		qty_requests 	BIGINT
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
   		select
		  COALESCE(itp, r.client_org_id) as itp_id,   
		  r.server_org_id as org_id,   
		   case 
		    when r.event_data #>>'{endpoint}' like '/open-banking/payments/v%/pix/payments' then 'Pagamentos'
		   else 'Pagamentos Automáticos'
		end as api,
		case 
		 	when r.event_data #>>'{endpoint}' like '/open-banking/payments/v%/pix/payments' then 'Pix - Criar iniciação de pagamento'
		 	else 'Cria uma transação de pagamento'
		end as endpoint,
		r.event_data#>>'{statusCode}' as status_code,
		r.event_data#>>'{httpMethod}' as "method",
		r.event_data#>>'{endpoint}' as endpoint_uri,
		regexp_replace(r.event_data #>> '{endpoint}', '^.*?/v(\d+)/.*$', '\1') AS api_version,
		(r.event_data #> '{additionalInfo,errorCodes}' ->> 0) as error_code,
		r.event_data #>> '{additionalInfo,paymentType}' as produto,
		count(*) as qty_requests
		from report r
		where r.event_role = 'CLIENT' and r.event_data#>>'{httpMethod}' = 'POST' and
		(r.event_data #>>'{endpoint}' like '/open-banking/payments/v%/pix/payments' or r.event_data #>>'{endpoint}' like '/open-banking/automatic-payments/v%/pix/recurring-payments') and
		r.event_timestamp::timestamptz between dt_start_utc and dt_end_utc
		and (itp IS NULL OR r.client_org_id = itp)
		group by 
			r.server_org_id, 
			r.client_org_id, 
			r.event_data#>>'{httpMethod}', 
			r.event_data#>>'{endpoint}', 
			r.event_data#>>'{statusCode}', 
			(r.event_data #> '{additionalInfo,errorCodes}' ->> 0),
			regexp_replace(r.event_data #>> '{endpoint}', '^.*/v(\d+)/.*$', '\1'),
			r.event_data #>> '{additionalInfo,paymentType}';
end;$function$;