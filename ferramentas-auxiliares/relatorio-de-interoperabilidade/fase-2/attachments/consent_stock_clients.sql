drop function if exists consent_stock_clients;
CREATE OR REPLACE FUNCTION public.consent_stock_clients(dt_end date, brand uuid default null)
 RETURNS TABLE(app_name character varying, brand_id uuid, qty_cpfs bigint, qty_cnpjs bigint)
 LANGUAGE plpgsql
AS $function$
declare dt_end_interval date;
declare dt_end_utc timestamptz;
begin
    select dt_end + INTERVAL '1 day' INTO dt_end_interval;
    select dt_end_interval::date::timestamp AT TIME ZONE 'UTC' INTO dt_end_utc;

    return query
        select o."name"                                     as org_name,
        	   c.id_brand                                   as brand_id,
               count(distinct c.person_document_number)     as qty_cpfs,
               count(distinct c.business_document_number)   as qty_cnpjs
        from consent c
        inner join application a on a.id = c.id_application
        inner join organisation o on a.id_organisation = o.id_organisation
        inner join brand b ON c.id_brand = b.id
        where status = 'AUTHORISED' AND (dt_invalidation > dt_end_utc or dt_invalidation is null) AND c.tp_consent = 1 AND dt_creation < dt_end_utc AND access_token_data is not null AND (b.id = brand OR brand is null)
        group by o.id_organisation, c.id_brand;
end;$function$
;
