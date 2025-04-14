drop function if exists consent_receptor;
create or replace function consent_receptor(dt_start date, dt_end date, organisation_id uuid default null)
    returns table (
		app_name					VARCHAR,
        org_id                      UUID,
		authorisation_server        UUID,        
        qty_consents                BIGINT,
        qty_redirects               BIGINT,
        qty_authorisation_codes     BIGINT,
        qty_access_token            BIGINT
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
        select o."name" 							as org_name,
        	   o.id_organisation               		as org_id,
        	   bc.id_selected_authorisation_server  as authorisation_server,
        	   count(distinct c.id_consent)			as qty_consents,
        	   count(c.authorization_url) 			as qty_redirects,
        	   count(distinct c.authorisation_code) as qty_authorisation_codes,
        	   count(distinct c.access_token_data) 	as qty_access_token
        from consent c
        inner join application a
        on (a.id = c.id_application)
        inner join organisation o
        on (a.id_organisation = o.id_organisation)
        inner join brand_client bc
        on (bc.id_brand = c.id_brand and bc.id_brand_client = c.id_brand_client)
        where c.dt_creation between dt_start_utc and dt_end_utc and c.tp_consent = 1 
        and (o.id_organisation = organisation_id or organisation_id is null)
        group by o."name", o.id_organisation, bc.id_selected_authorisation_server;
end;$function$;