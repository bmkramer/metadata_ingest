WITH TABLE_SUBSET AS (
SELECT DISTINCT
acronym,
openaire_shortname
FROM `sos-project-space.FUNDERS_202604.funders_subset_openalex_openaire`
),

TABLE_PROJECT_ID AS

(SELECT DISTINCT

b.id as project_id,
b.funding.shortName,
EXTRACT(year FROM startDate) as year_start

FROM TABLE_SUBSET as a
LEFT JOIN (SELECT id, startDate, funding FROM `sos-datasources.openaire.project_20260129`, UNNEST(fundings) as funding) as b
ON a.openaire_shortname = b.funding.shortName

ORDER BY shortName

),


TABLE_JOIN_RELATION AS (

SELECT

a.* ,
b.source as product_id

FROM TABLE_PROJECT_ID as a
LEFT JOIN `sos-datasources.openaire.relation_product_project_20260129` as b
ON a.project_id = b.target

),

TABLE_PRODUCT AS (

SELECT

id,
if(pid.scheme = "doi", pid.value, null) as doi,
EXTRACT (year FROM publicationDate) as publication_year,
type

FROM `sos-datasources.openaire.publication_20260129`
LEFT JOIN UNNEST(pids) as pid

UNION ALL

SELECT

id,
if(pid.scheme = "doi", pid.value, null) as doi,
EXTRACT (year FROM publicationDate) as publication_year,
type

FROM `sos-datasources.openaire.dataset_20260129`
LEFT JOIN UNNEST(pids) as pid

UNION ALL

SELECT

id,
if(pid.scheme = "doi", pid.value, null) as doi,
EXTRACT (year FROM publicationDate) as publication_year,
type

FROM `sos-datasources.openaire.software_20260129`
LEFT JOIN UNNEST(pids) as pid

UNION ALL

SELECT

id,
if(pid.scheme = "doi", pid.value, null) as doi,
EXTRACT (year FROM publicationDate) as publication_year,
type

FROM `sos-datasources.openaire.otherresearchproduct_20260129`
LEFT JOIN UNNEST(pids) as pid

),


TABLE_JOIN_PRODUCT AS (
SELECT
a.*,
b.* EXCEPT (id)

FROM TABLE_JOIN_RELATION as a
LEFT JOIN TABLE_PRODUCT as b
ON a.product_id = b.id

),

TABLE_JOIN_CROSSREF AS (

SELECT

a.*,
if(b.DOI is not null, true, false) as cr_included,
b.type as cr_type,
EXTRACT(YEAR from issued) as cr_year


FROM TABLE_JOIN_PRODUCT as a
LEFT JOIN `sos-datasources.backup.cr_instant_snapshot_20260131` as b
ON UPPER(TRIM(a.doi)) = UPPER(TRIM(b.DOI))

),

TABLE_AGG AS (
  
SELECT

shortName,
count(distinct project_id) as project_ids,
MIN(year_start) as project_start_year_min,
MAX(year_start) as project_start_year_max,
count(distinct product_id) as product_ids,
count(distinct if(doi is not null, product_id, null)) as product_ids_with_doi,
---count(distinct doi) as dois,
---count(distinct if(cr_included, doi, null)) as crossref_dois,
count(distinct if(cr_type = "journal-article", doi, null)) as dois_crossref_journal_article,

FROM TABLE_JOIN_CROSSREF

GROUP BY ALL
ORDER BY shortname
)

SELECT * FROM TABLE_AGG
