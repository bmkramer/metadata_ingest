--- This creates all variables for all records (with null value if not present in imported JSON)
--- Values may include both null values and empty strings (as present in imported JSON)
--- Reminder to self: Use JSON_KEYS to identify keys in imported JSON

WITH TABLE AS (
SELECT 
*,
--- convert full JSON to string for all downstream matching
TO_JSON_STRING(originalValue) as originalValue_string,
TO_JSON_STRING(enrichedValue) as enrichedValue_string,
FROM `sos-datasources.comet.enrichments_affiliations_20260801` 
),

TABLE_STRINGS_ORIGINAL AS (
SELECT 
doi,
originalValue_string,
enrichedValue_string,
--- direct extractions of string values
LAX_STRING(JSON_EXTRACT(originalValue, '$.contributorType')) as contributorType_original,
LAX_STRING(JSON_EXTRACT(originalValue, '$.familyName')) as familyName,
LAX_STRING(JSON_EXTRACT(originalValue, '$.givenName')) as givenName,
LAX_STRING(JSON_EXTRACT(originalValue, '$.lang')) as lang,
LAX_STRING(JSON_EXTRACT(originalValue, '$.name')) as name,
LAX_STRING(JSON_EXTRACT(originalValue, '$.nameType')) as nameType
FROM TABLE
),

TABLE_STRINGS_ENRICHED AS (
SELECT 
doi,
originalValue_string,
enrichedValue_string,
--- direct extractions of string values
LAX_STRING(JSON_EXTRACT(enrichedValue, '$.contributorType')) as contributorType,
LAX_STRING(JSON_EXTRACT(enrichedValue, '$.familyName')) as familyName,
LAX_STRING(JSON_EXTRACT(enrichedValue, '$.givenName')) as givenName,
LAX_STRING(JSON_EXTRACT(enrichedValue, '$.lang')) as lang,
LAX_STRING(JSON_EXTRACT(enrichedValue, '$.name')) as name,
LAX_STRING(JSON_EXTRACT(enrichedValue, '$.nameType')) as nameType
FROM TABLE
),

TABLE_ARRAYS AS (
SELECT
doi,
originalValue_string,
enrichedValue_string,
--- split arrays for downstream extraction
JSON_QUERY_ARRAY(originalValue, '$.affiliation') as affiliations_original,
JSON_QUERY_ARRAY(originalValue, '$.nameIdentifiers') as nameIdentifiers_original,
JSON_QUERY_ARRAY(enrichedValue, '$.affiliation') as affiliations_enriched,
JSON_QUERY_ARRAY(enrichedValue, '$.nameIdentifiers') as nameIdentifiers_enriched,
FROM TABLE
),

-- extract arrays per variable
TABLE_AFFILATIONS_ORIGINAL AS (
SELECT 
doi,
originalValue_string,
enrichedValue_string,
--- create array of struct with extracted values
ARRAY_AGG(
STRUCT(
LAX_STRING(JSON_EXTRACT(affiliation, '$.affiliationIdentifier')) as affiliationIdentifier,
LAX_STRING(JSON_EXTRACT(affiliation, '$.affiliationIdentifierScheme')) as affiliationIdentifierScheme,
LAX_STRING(JSON_EXTRACT(affiliation, '$.name')) as name,
LAX_STRING(JSON_EXTRACT(affiliation, '$.schemeUri')) as schemeUri
)) as affiliation
FROM TABLE_ARRAYS
LEFT JOIN UNNEST (affiliations_original) as affiliation
GROUP BY ALL
),

TABLE_AFFILATIONS_ENRICHED AS (
SELECT 
doi,
originalValue_string,
enrichedValue_string,
--- create array of struct with extracted values
ARRAY_AGG(
STRUCT(
LAX_STRING(JSON_EXTRACT(affiliation, '$.affiliationIdentifier')) as affiliationIdentifier,
LAX_STRING(JSON_EXTRACT(affiliation, '$.affiliationIdentifierScheme')) as affiliationIdentifierScheme,
LAX_STRING(JSON_EXTRACT(affiliation, '$.name')) as name,
LAX_STRING(JSON_EXTRACT(affiliation, '$.schemeUri')) as schemeUri
)) as affiliation
FROM TABLE_ARRAYS
LEFT JOIN UNNEST (affiliations_enriched) as affiliation
GROUP BY ALL
),

TABLE_NAME_IDENTIFIERS_ORIGINAL AS (

SELECT 

doi,
originalValue_string,
enrichedValue_string,
--- create array of struct with extracted values
ARRAY_AGG(
STRUCT(
LAX_STRING(JSON_EXTRACT(nameIdentifier, '$.nameIdentifier')) as affiliationIdentifier,
LAX_STRING(JSON_EXTRACT(nameIdentifier, '$.nameIdentifierScheme')) as affiliationIdentifierScheme,
LAX_STRING(JSON_EXTRACT(nameIdentifier, '$.schemeUri')) as schemeUri
)) as nameIdentifiers
FROM TABLE_ARRAYS
LEFT JOIN UNNEST (nameIdentifiers_original) as nameIdentifier
GROUP BY ALL
),

 TABLE_NAME_IDENTIFIERS_ENRICHED AS (
SELECT 
doi,
originalValue_string,
enrichedValue_string,
--- create array of struct with extracted values
ARRAY_AGG(
STRUCT(
LAX_STRING(JSON_EXTRACT(nameIdentifier, '$.nameIdentifier')) as affiliationIdentifier,
LAX_STRING(JSON_EXTRACT(nameIdentifier, '$.nameIdentifierScheme')) as affiliationIdentifierScheme,
LAX_STRING(JSON_EXTRACT(nameIdentifier, '$.schemeUri')) as schemeUri
)) as nameIdentifiers
FROM TABLE_ARRAYS
LEFT JOIN UNNEST (nameIdentifiers_enriched) as nameIdentifier
GROUP BY ALL
),

--- combine all extracted variables in structs
TABLE_JOIN AS (

SELECT 

a.* EXCEPT (originalValue, enrichedValue, originalValue_string, enrichedValue_string),

STRUCT(
d.affiliation,  
b.familyName,
b.givenName,
b.lang,
b.name,
f.nameIdentifiers,
b.nameType
) as originalValue,
STRUCT(
e.affiliation,
c.familyName,
c.givenName,
c.lang,
c.name,
g.nameIdentifiers,
c.nameType
) as enrichedValue,


FROM TABLE as a
LEFT JOIN TABLE_STRINGS_ORIGINAL as b
USING (doi,originalValue_string,enrichedValue_string)
LEFT JOIN TABLE_STRINGS_ENRICHED as c
USING (doi,originalValue_string,enrichedValue_string)
LEFT JOIN TABLE_AFFILATIONS_ORIGINAL as d
USING (doi,originalValue_string,enrichedValue_string)
LEFT JOIN TABLE_AFFILATIONS_ENRICHED as e
USING (doi,originalValue_string,enrichedValue_string)
LEFT JOIN TABLE_NAME_IDENTIFIERS_ORIGINAL as f
USING (doi,originalValue_string,enrichedValue_string)
LEFT JOIN TABLE_NAME_IDENTIFIERS_ENRICHED as g
USING (doi,originalValue_string,enrichedValue_string)

)

SELECT * FROM TABLE_JOIN