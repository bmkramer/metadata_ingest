WITH TABLE_SUBSET AS (
SELECT DISTINCT
acronym,
openalex_funder_id as funder_id
FROM `sos-project-space.FUNDERS_202604.funders_subset_openalex_openaire`
),

TABLE_AWARDS AS (
SELECT
a.acronym,
CONCAT(a.acronym,"|",provenance) as acronym_provenance_uuid,
b.funder.id as funder_id,
b.id as award_id,
b.start_year as award_start_year,
b.provenance

FROM TABLE_SUBSET as a
LEFT JOIN `subugoe-collaborative.openalex_walden.awards` as b
ON a.funder_id = b.funder.id

WHERE b.funder.id is not null
),

TABLE_AWARDS_AGG AS (
SELECT
acronym,
acronym_provenance_uuid,
provenance,
MIN(award_start_year) as award_start_year_min,
MAX(award_start_year) as award_start_year_max,
count(award_id) as award_count
FROM TABLE_AWARDS
GROUP BY ALL
ORDER BY award_count DESC
),

TABLE_AWARDS_WORKS AS (
SELECT DISTINCT
a.acronym,
a.acronym_provenance_uuid,
b.id as work_id,
b.doi,
CASE WHEN (SELECT COUNT(1) FROM UNNEST(indexed_in) AS i WHERE i = "crossref") > 0 THEN TRUE ELSE FALSE END as is_crossref_doi,
IF(b.type IN ("article", "review") AND (source_type = "journal"), TRUE, FALSE) as is_journal_article,
FROM TABLE_AWARDS as a
LEFT JOIN (SELECT w.id, w.doi, indexed_in, award, funders, type, primary_location.source.type as source_type FROM `subugoe-collaborative.openalex_walden.works` as w,
UNNEST (awards) as award) as b
ON a.award_id = b.award.id

WHERE a.award_id is not null
),

TABLE_AWARDS_WORKS_AGG_PROVENANCE AS (
SELECT
acronym_provenance_uuid, --- to split by provenance
count(distinct if(work_id is not null, work_id, null)) as work_ids_award,
---count(distinct if(doi is not null, doi, null)) as dois_award,
---count(distinct if(doi is not null and is_crossref_doi, doi, null)) as dois_cr_award,
count(distinct if(doi is not null and is_crossref_doi and is_journal_article, doi, null)) as dois_cr_article_award,
FROM TABLE_AWARDS_WORKS
GROUP BY ALL
),

TABLE_AWARDS_WORKS_AGG_ALL AS (
SELECT
acronym, --- to split by acronym
count(distinct if(work_id is not null, work_id, null)) as work_ids_award,
---count(distinct if(doi is not null, doi, null)) as dois_award,
---count(distinct if(doi is not null and is_crossref_doi, doi, null)) as dois_cr_award,
count(distinct if(doi is not null and is_crossref_doi and is_journal_article, doi, null)) as dois_cr_article_award,
FROM TABLE_AWARDS_WORKS
GROUP BY ALL
),

TABLE_JOIN_AWARDS_PROVENANCE AS (
SELECT
a.* EXCEPT (acronym_provenance_uuid),
b.* EXCEPT (acronym_provenance_uuid)
FROM TABLE_AWARDS_AGG as a
LEFT JOIN TABLE_AWARDS_WORKS_AGG_PROVENANCE as b
USING (acronym_provenance_uuid)
ORDER BY acronym
),

TABLE_FUNDERS_WORKS AS (
SELECT DISTINCT
a.acronym,
b.id as work_id,
b.doi,
CASE WHEN (SELECT COUNT(1) FROM UNNEST(indexed_in) AS i WHERE i = "crossref") > 0 THEN TRUE ELSE FALSE END as is_crossref_doi,
IF(b.type IN ("article", "review") AND (source_type = "journal"), TRUE, FALSE) as is_journal_article,
FROM TABLE_SUBSET as a
LEFT JOIN (SELECT w.id, w.doi, indexed_in, funder, type, primary_location.source.type as source_type FROM `subugoe-collaborative.openalex_walden.works` as w,
UNNEST (funders) as funder) as b
ON a.funder_id = b.funder.id
WHERE a.funder_id is not null
),

TABLE_FUNDERS_WORKS_AGG AS (
SELECT
acronym,
count(distinct if(work_id is not null, work_id, null)) as work_ids_funder,
--count(distinct if(doi is not null, doi, null)) as dois_funder,
--count(distinct if(doi is not null and is_crossref_doi, doi, null)) as dois_cr_funder,
count(distinct if(doi is not null and is_crossref_doi and is_journal_article, doi, null)) as dois_cr_article_funder,
FROM TABLE_FUNDERS_WORKS
GROUP BY ALL
),

TABLE_UNION AS (
---awards and works linked to awards, by provenance
SELECT
acronym,
provenance,
award_start_year_min,
award_start_year_max,
award_count,
work_ids_award,
dois_cr_article_award,
null as work_ids_funder_only,
null as dois_cr_article_funder_only
FROM TABLE_JOIN_AWARDS_PROVENANCE

UNION ALL

--- works linked to awards, all
--- include works linked to funders only
SELECT
a.acronym,
"all" as provenance,
null as award_start_year_min,
null as award_start_year_max,
null as award_count,
a.work_ids_award,
a.dois_cr_article_award,
(b.work_ids_funder- a.work_ids_award) as work_ids_funder_only,
(b.dois_cr_article_funder - a.dois_cr_article_award) as dois_cr_article_funder_only
FROM TABLE_AWARDS_WORKS_AGG_ALL as a
LEFT JOIN TABLE_FUNDERS_WORKS_AGG as b 
USING (acronym)
)

SELECT * FROM TABLE_FUNDERS_WORKS_AGG