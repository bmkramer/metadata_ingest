WITH TABLE_ARRAY AS (
SELECT

SPLIT(SPLIT(id, " ")[safe_offset(0)], ":")[safe_offset(1)] as omid,
SPLIT(id, " ") as id_array,
NULLIF(title, "") as title,
SPLIT(author, "; ") as author_array,
NULLIF(issue, "") as issue,
NULLIF(volume, "") as volume,
NULLIF(page, "") as page,
NULLIF(type, "") as type,
SPLIT(venue, "; ") as venue_array,--- probably not needed but similar approach for author, venue, publisher, editor
SPLIT(pub_date, "-") as date_parts,
SPLIT(publisher, "; ") as publisher_array,--- probably not needed but similar approach for author, venue, publisher, editor
SPLIT(editor, "; ") as editor_array,

---FROM `sos-datasources.opencitations.test_csv0_ingest`
FROM `sos-datasources.opencitations.opencitations_meta_ingest_20240620`

),

--- ids
TABLE_ID AS (

SELECT

omid,
SPLIT(id_array, ":")[safe_offset(0)] as schema,
SPLIT(id_array, ":")[safe_offset(1)] as value

FROM TABLE_ARRAY
LEFT JOIN UNNEST(id_array) as id_array

),

TABLE_ID_ARRAY AS (

SELECT

omid,
ARRAY_AGG (
STRUCT(schema, value)
) as ids
FROM TABLE_ID
GROUP BY omid

),

--- author
TABLE_AUTHOR AS (

SELECT

omid,
REGEXP_REPLACE(author_array, r'\[(.*?)\]', "") as name, -- name part before [ids]
SPLIT(REGEXP_EXTRACT(author_array, r'\[(.*?)\]'), " ") as ids_array, --- [ids] part, convert into array

FROM TABLE_ARRAY
LEFT JOIN UNNEST(author_array) as author_array

),

TABLE_AUTHOR_2 AS (

SELECT

omid,
NULLIF(name, "") as name,
SPLIT(ids_array, ":")[safe_offset(0)] as schema,
SPLIT(ids_array, ":")[safe_offset(1)] as value

FROM TABLE_AUTHOR
LEFT JOIN UNNEST(ids_array) as ids_array

),

TABLE_AUTHOR_ARRAY AS (

SELECT

omid,
name,
ARRAY_AGG (
STRUCT(schema, value)
) as ids
FROM TABLE_AUTHOR_2
GROUP BY omid,name

),

TABLE_AUTHOR_ARRAY_2 AS (

SELECT

omid,
ARRAY_AGG (
STRUCT(name, ids)
) as author
FROM TABLE_AUTHOR_ARRAY
GROUP BY omid

),

--- venue
TABLE_VENUE AS (

SELECT

omid,
REGEXP_REPLACE(venue_array, r'\[(.*?)\]', "") as name, -- name part before [ids]
SPLIT(REGEXP_EXTRACT(venue_array, r'\[(.*?)\]'), " ") as ids_array, --- [ids] part, convert into array

FROM TABLE_ARRAY
LEFT JOIN UNNEST(venue_array) as venue_array

),

TABLE_VENUE_2 AS (

SELECT

omid,
NULLIF(name, "") as name,
SPLIT(ids_array, ":")[safe_offset(0)] as schema,
SPLIT(ids_array, ":")[safe_offset(1)] as value

FROM TABLE_VENUE
LEFT JOIN UNNEST(ids_array) as ids_array

),

TABLE_VENUE_ARRAY AS (

SELECT

omid,
name,
ARRAY_AGG (
STRUCT(schema, value)
) as ids
FROM TABLE_VENUE_2
GROUP BY omid,name

),

TABLE_VENUE_ARRAY_2 AS (

SELECT

omid,
ARRAY_AGG (
STRUCT(name, ids)
) as venue
FROM TABLE_VENUE_ARRAY
GROUP BY omid

),

--- publisher
TABLE_PUBLISHER AS (

SELECT

omid,
REGEXP_REPLACE(publisher_array, r'\[(.*?)\]', "") as name, -- name part before [ids]
SPLIT(REGEXP_EXTRACT(publisher_array, r'\[(.*?)\]'), " ") as ids_array, --- [ids] part, convert into array

FROM TABLE_ARRAY
LEFT JOIN UNNEST(publisher_array) as publisher_array

),

TABLE_PUBLISHER_2 AS (

SELECT

omid,
NULLIF(name, "") as name,
SPLIT(ids_array, ":")[safe_offset(0)] as schema,
SPLIT(ids_array, ":")[safe_offset(1)] as value

FROM TABLE_PUBLISHER
LEFT JOIN UNNEST(ids_array) as ids_array

),

TABLE_PUBLISHER_ARRAY AS (

SELECT

omid,
name,
ARRAY_AGG (
STRUCT(schema, value)
) as ids
FROM TABLE_PUBLISHER_2
GROUP BY omid,name

),

TABLE_PUBLISHER_ARRAY_2 AS (

SELECT

omid,
ARRAY_AGG (
STRUCT(name, ids)
) as publisher
FROM TABLE_PUBLISHER_ARRAY
GROUP BY omid

),

--- publisher
TABLE_EDITOR AS (

SELECT

omid,
REGEXP_REPLACE(editor_array, r'\[(.*?)\]', "") as name, -- name part before [ids]
SPLIT(REGEXP_EXTRACT(editor_array, r'\[(.*?)\]'), " ") as ids_array, --- [ids] part, convert into array

FROM TABLE_ARRAY
LEFT JOIN UNNEST(editor_array) as editor_array

),

TABLE_EDITOR_2 AS (

SELECT

omid,
NULLIF(name, "") as name,
SPLIT(ids_array, ":")[safe_offset(0)] as schema,
SPLIT(ids_array, ":")[safe_offset(1)] as value

FROM TABLE_EDITOR
LEFT JOIN UNNEST(ids_array) as ids_array

),

TABLE_EDITOR_ARRAY AS (

SELECT

omid,
name,
ARRAY_AGG (
STRUCT(schema, value)
) as ids
FROM TABLE_EDITOR_2
GROUP BY omid,name

),

TABLE_EDITOR_ARRAY_2 AS (

SELECT

omid,
ARRAY_AGG (
STRUCT(name, ids)
) as editor
FROM TABLE_EDITOR_ARRAY
GROUP BY omid

),

---pub_date
TABLE_PUB_DATE AS (

SELECT

omid,
SAFE_CAST(date_parts AS INT64) as date_parts

FROM TABLE_ARRAY
LEFT JOIN UNNEST (date_parts) as date_parts

),

TABLE_PUB_DATE_ARRAY AS (

SELECT

omid,
STRUCT(ARRAY_AGG(date_parts IGNORE NULLS) as date_parts) as pub_date

FROM TABLE_PUB_DATE
GROUP BY omid

),

TABLE_JOIN AS (

SELECT

a.omid,
b.ids,
a.title,
c.author,
a.issue,
a.volume,
a.page,
d.venue,
g.pub_date,
a.type,
e.publisher,
f.editor


FROM TABLE_ARRAY as a
LEFT JOIN TABLE_ID_ARRAY as b
USING (omid)
LEFT JOIN TABLE_AUTHOR_ARRAY_2 as c
USING (omid)
LEFT JOIN TABLE_VENUE_ARRAY_2 as d
USING (omid)
LEFT JOIN TABLE_PUBLISHER_ARRAY_2 as e
USING (omid)
LEFT JOIN TABLE_EDITOR_ARRAY_2 as f
USING (omid)
LEFT JOIN TABLE_PUB_DATE_ARRAY as g
USING (omid)
)

SELECT * FROM TABLE_JOIN
ORDER BY omid