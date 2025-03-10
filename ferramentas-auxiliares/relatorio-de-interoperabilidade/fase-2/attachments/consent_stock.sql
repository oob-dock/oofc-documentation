drop function if exists consent_stock;
CREATE OR REPLACE FUNCTION public.consent_stock(dt_end date, brand uuid default null)
 RETURNS TABLE(app_name character varying,  brand_id UUID, authorisation_server uuid, qty_consents bigint)
 LANGUAGE plpgsql
AS $function$
declare dt_end_interval date;
declare dt_end_utc timestamptz;
begin
    select dt_end + INTERVAL '1 day' INTO dt_end_interval;
    select dt_end_interval::date::timestamp AT TIME ZONE 'UTC' INTO dt_end_utc;

    return query
		select o."name" 									as org_name,
		       c.id_brand               			        as brand_id,
               as1.id_authorisation_server                  as authorisation_server,
			   count(distinct c.id_consent)                 as qty_consents
		from consent c
		inner join application a on a.id = c.id_application
		inner join organisation o on a.id_organisation = o.id_organisation
		inner join brand b ON c.id_brand = b.id
		inner join authorisation_server as1 on as1.id_brand = b.id
        where status = 'AUTHORISED' AND (dt_invalidation > dt_end_utc or dt_invalidation is null) AND c.tp_consent = 1 AND dt_creation < dt_end_utc and access_token_data is not null and (b.id = brand or brand is null)
		group by o.id_organisation, as1.id_authorisation_server, c.id_brand;
end;$function$
;
