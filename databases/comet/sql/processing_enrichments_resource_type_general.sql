--- This creates all variables for all records (with null value if not present in imported JSON)
--- Values may include both null values and empty strings (as present in imported JSON)
--- Reminder to self: Use JSON_KEYS to identify keys in imported JSON

SELECT

* EXCEPT (originalValue, enrichedValue),

STRUCT(
LAX_STRING(JSON_EXTRACT(originalValue, '$.bibtex')) as bibtex,
LAX_STRING(JSON_EXTRACT(originalValue, '$.citeproc')) as citeproc,
LAX_STRING(JSON_EXTRACT(originalValue, '$.resourceType')) as resourceType,
LAX_STRING(JSON_EXTRACT(originalValue, '$.resourceTypeGeneral')) as resourceTypeGeneral,
LAX_STRING(JSON_EXTRACT(originalValue, '$.ris')) as ris,
LAX_STRING(JSON_EXTRACT(originalValue, '$.schemaOrg')) as schemaOrg
) as orginalValue,

STRUCT(
LAX_STRING(JSON_EXTRACT(enrichedValue, '$.bibtex')) as bibtex,
LAX_STRING(JSON_EXTRACT(enrichedValue, '$.citeproc')) as citeproc,
LAX_STRING(JSON_EXTRACT(enrichedValue, '$.resourceType')) as resourceType,
LAX_STRING(JSON_EXTRACT(enrichedValue, '$.resourceTypeGeneral')) as resourceTypeGeneral,
LAX_STRING(JSON_EXTRACT(enrichedValue, '$.ris')) as ris,
LAX_STRING(JSON_EXTRACT(enrichedValue, '$.schemaOrg')) as schemaOrg
) as enrichedValue,

 FROM `sos-datasources.comet.enrichments_resource_type_general_20260801` 