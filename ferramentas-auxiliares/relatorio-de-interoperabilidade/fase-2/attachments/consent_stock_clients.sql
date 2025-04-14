drop function if exists consent_stock_clients;
CREATE OR REPLACE FUNCTION public.consent_stock_clients(dt_end date, organisation_id uuid default null)
    RETURNS TABLE(
        org_name character varying,
        org_id UUID,
        qty_cpfs bigint,
        qty_cnpjs bigint
    )
LANGUAGE plpgsql
AS $function$
declare dt_end_interval date;
declare dt_end_utc timestamptz;
begin
    select dt_end + INTERVAL '1 day' INTO dt_end_interval;
    select dt_end_interval::date::timestamp AT TIME ZONE 'UTC' INTO dt_end_utc;

    return query
        select o."name"                                     as org_name,
               o.id_organisation 							as org_id,
               count(distinct c.person_document_number)     as qty_cpfs,
               count(distinct c.business_document_number)   as qty_cnpjs
           from consent c
           inner join application a 
           on (a.id = c.id_application)
           inner join organisation o 
           on (a.id_organisation = o.id_organisation)
           where c.status = 'AUTHORISED' AND (c.dt_invalidation > dt_end_utc or c.dt_invalidation is null) AND c.tp_consent = 1 
           AND c.dt_creation < dt_end_utc AND c.access_token_data is not null 
           AND (o.id_organisation = organisation_id OR organisation_id is null)
           group by o."name", o.id_organisation;
end;$function$
;
