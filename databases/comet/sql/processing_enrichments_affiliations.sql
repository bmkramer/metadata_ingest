--- This creates all variables for all records (with null value if not present in imported JSON)
--- Values may include both null values and empty strings (as present in imported JSON)

SELECT 

* EXCEPT (originalValue, enrichedValue),

STRUCT(
LAX_STRING(JSON_EXTRACT(originalValue, '$.contributorType')) as contributorType,
LAX_STRING(JSON_EXTRACT(originalValue, '$.familyName')) as familyName,
LAX_STRING(JSON_EXTRACT(originalValue, '$.givenName')) as givenName,
LAX_STRING(JSON_EXTRACT(originalValue, '$.lang')) as lang,
LAX_STRING(JSON_EXTRACT(originalValue, '$.name')) as name,
LAX_STRING(JSON_EXTRACT(originalValue, '$.nameType')) as nameType
) as originalValue,

STRUCT(
LAX_STRING(JSON_EXTRACT(enrichedValue, '$.contributorType')) as contributorType,
LAX_STRING(JSON_EXTRACT(enrichedValue, '$.familyName')) as familyName,
LAX_STRING(JSON_EXTRACT(enrichedValue, '$.givenName')) as givenName,
LAX_STRING(JSON_EXTRACT(enrichedValue, '$.lang')) as lang,
LAX_STRING(JSON_EXTRACT(enrichedValue, '$.name')) as name,
LAX_STRING(JSON_EXTRACT(enrichedValue, '$.nameType')) as nameType
) as enrichedValue

FROM `sos-datasources.comet.enrichments_affiliations_20260801`