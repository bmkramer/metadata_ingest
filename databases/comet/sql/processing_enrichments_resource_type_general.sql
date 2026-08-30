SELECT

* EXCEPT (originalValue, enrichedValue),

STRUCT(
STRING(JSON_EXTRACT(originalValue, '$.bibtex')) as bibtex,
STRING(JSON_EXTRACT(originalValue, '$.citeproc')) as citeproc,
STRING(JSON_EXTRACT(originalValue, '$.resourceType')) as resourceType,
STRING(JSON_EXTRACT(originalValue, '$.resourceTypeGeneral')) as resourceTypeGeneral,
STRING(JSON_EXTRACT(originalValue, '$.ris')) as ris,
STRING(JSON_EXTRACT(originalValue, '$.schemaOrg')) as schemaOrg
) as orginalValue,

STRUCT(
STRING(JSON_EXTRACT(enrichedValue, '$.bibtex')) as bibtex,
STRING(JSON_EXTRACT(enrichedValue, '$.citeproc')) as citeproc,
STRING(JSON_EXTRACT(enrichedValue, '$.resourceType')) as resourceType,
STRING(JSON_EXTRACT(enrichedValue, '$.resourceTypeGeneral')) as resourceTypeGeneral,
STRING(JSON_EXTRACT(enrichedValue, '$.ris')) as ris,
STRING(JSON_EXTRACT(enrichedValue, '$.schemaOrg')) as schemaOrg
) as enrichedValue,

 FROM `sos-datasources.comet.enrichments_resource_type_general_20260801` 