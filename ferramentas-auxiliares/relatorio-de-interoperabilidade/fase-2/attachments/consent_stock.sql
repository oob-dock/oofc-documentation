drop function if exists consent_stock;
CREATE OR REPLACE FUNCTION public.consent_stock(dt_end date, organisation_id uuid default null)
    RETURNS TABLE(
        org_name character varying,
        org_id UUID,
        authorisation_server uuid,
        qty_consents bigint
    )
LANGUAGE plpgsql
AS $function$
declare dt_end_interval date;
declare dt_end_utc timestamptz;
begin
    select dt_end + INTERVAL '1 day' INTO dt_end_interval;
    select dt_end_interval::date::timestamp AT TIME ZONE 'UTC' INTO dt_end_utc;

    return query
		select o."name" 								                    as org_name,
           o.id_organisation               			        as org_id,
        	 bc.id_selected_authorisation_server          as authorisation_server,
        	 count(c.id_consent)                          as qty_consents
        FROM public.consent c
        inner join application a 
        on (a.id = c.id_application)
        inner join organisation o 
        on (a.id_organisation = o.id_organisation)
        inner join brand_client bc  
        on (bc.id_brand = c.id_brand and bc.id_brand_client = c.id_brand_client)
        where c.status = 'AUTHORISED' AND (c.dt_invalidation > dt_end_utc or c.dt_invalidation is null) 
        AND c.tp_consent = 1 AND c.dt_creation < dt_end_utc AND access_token_data is not null 
        and (o.id_organisation = organisation_id or organisation_id is null)
        group by o."name", o.id_organisation, bc.id_selected_authorisation_server;
end;$function$
;
