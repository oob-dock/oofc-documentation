drop function if exists consent_receptor;
create or replace function consent_receptor(dt_start date, dt_end date, brand uuid default null)
    returns table (
		app_name					VARCHAR,
        authorisation_server        UUID,
        brand_id                    UUID,
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
			   as1.id_authorisation_server 			as authorisation_server,
			   c.id_brand               			as brand_id,
			   count(distinct c.id_consent)			as qty_consents,
			   count(c.authorization_url) 			as qty_redirects,
			   count(distinct c.authorisation_code) as qty_authorisation_codes,
			   count(distinct c.access_token_data) 	as qty_access_token
		from consent c
		inner join application a on a.id = c.id_application
		inner join organisation o on a.id_organisation = o.id_organisation
		inner join brand b ON c.id_brand = b.id
		inner join authorisation_server as1 on as1.id_brand = b.id
		where c.dt_creation between dt_start_utc and dt_end_utc and c.tp_consent = 1 and (b.id = brand or brand is null)
		group by o.id_organisation, as1.id_authorisation_server, c.id_brand;

end;$function$;