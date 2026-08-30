--- This creates all variables for all records (with null value if not present in imported JSON)

SELECT 

* EXCEPT (originalValue, enrichedValue),

STRUCT(
LAX_STRING(JSON_EXTRACT(originalValue, '$.awardNumber')) as awardNumber,
LAX_STRING(JSON_EXTRACT(originalValue, '$.awardTitle')) as awardTitle,
LAX_STRING(JSON_EXTRACT(originalValue, '$.awardUri')) as awardUri,
LAX_STRING(JSON_EXTRACT(originalValue, '$.funderIdentifier')) as funderIdentifier,
LAX_STRING(JSON_EXTRACT(originalValue, '$.funderIdentifierType')) as funderIdentifierType,
LAX_STRING(JSON_EXTRACT(originalValue, '$.funderName')) as funderName,
LAX_STRING(JSON_EXTRACT(originalValue, '$.schemeUri')) as schemeUri
) as originalValue,

STRUCT(
LAX_STRING(JSON_EXTRACT(enrichedValue, '$.awardNumber')) as awardNumber,
LAX_STRING(JSON_EXTRACT(enrichedValue, '$.awardTitle')) as awardTitle,
LAX_STRING(JSON_EXTRACT(enrichedValue, '$.awardUri')) as awardUri,
LAX_STRING(JSON_EXTRACT(enrichedValue, '$.funderIdentifier')) as funderIdentifier,
LAX_STRING(JSON_EXTRACT(enrichedValue, '$.funderIdentifierType')) as funderIdentifierType,
LAX_STRING(JSON_EXTRACT(enrichedValue, '$.funderName')) as funderName,
LAX_STRING(JSON_EXTRACT(enrichedValue, '$.schemeUri')) as schemeUri
) as enrichedValue

 FROM `sos-datasources.comet.enrichments_funders_20260801` 