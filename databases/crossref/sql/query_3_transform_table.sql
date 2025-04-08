WITH TABLE_0 AS (

SELECT col1 FROM `sos-datasources.crossref_metadata.0_json_string_table`
--- or directly from external table!
---SELECT col1 FROM `sos-datasources.crossref_metadata.0_json_string`

),

--- replace nested array with simple array for date-parts throughout
--- all have ARRAY_LENGTH 1
TABLE_1 AS (

SELECT

REGEXP_REPLACE(col1, r'("date-parts": )(\[\[)([0-9\, ]+)(\]\])', r'\1[\3]') as col1

FROM TABLE_0
),

--- replace nested array [[null]] with empty array [] for date-parts throughout
TABLE_1A AS (

SELECT

REPLACE(col1, '"date-parts": [[null]]', '"date-parts": []') as col1

FROM TABLE_1
),


--- use array for "award": (expected to be array most times, simple string sometimes)
TABLE_2 AS (

SELECT

REGEXP_REPLACE(col1, r'("award": )(")(.*?)(")', r'\1[\2\3\4]') as col1

FROM TABLE_1A
),




--- replace dashes with underscores in variable names (1 dash)
--- this is done in sequence for multiple occurrences - can probably be better integrated
TABLE_3 AS (

SELECT

REGEXP_REPLACE(col1, r'(")([A-Za-z]+)(-)([A-Za-z]+)(": )', r'\1\2_\4\5') as col1

FROM TABLE_2
),

--- replace dashes with underscores in variable names (2 dashes)
TABLE_3A AS (

SELECT

REGEXP_REPLACE(col1, r'(")([A-Za-z]+)(-)([A-Za-z]+)(-)([A-Za-z]+)(": )', r'\1\2_\4_\6\7') as col1

FROM TABLE_3
),

--- replace dashes with underscores in variable names (3 dashes)
TABLE_3B AS (

SELECT

REGEXP_REPLACE(col1, r'(")([A-Za-z]+)(-)([A-Za-z]+)(-)([A-Za-z]+)(-)([A-Za-z]+)(": )', r'\1\2_\4_\6_\8\9') as col1

FROM TABLE_3A
)

--- parse to json before export
SELECT parse_json(col1) as crossref FROM TABLE_3B
ORDER BY col1

--- or do not parse_json yet to enable future UNION DISTINCT on transformed tables (for json extraction in situ)

---SELECT col1 FROM TABLE_3B
---ORDER BY col1

--- saved as `sos-datasources.crossref_metadata.0_export`
--- saved as `sos-datasources.crossref_metadata.0_json_string_table_transform`
