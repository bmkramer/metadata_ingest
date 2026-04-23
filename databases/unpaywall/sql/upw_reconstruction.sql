--- Script to reconstruct Unpaywall data structure from OpenAlex, to serve use cases that are dependent on Unpaywall structure 
--- Note: 20260423 Currently in progress, not fully equivalent yet! 


--- filter on Crossref DOIs
--- at this point, can also check whether resulting list contains duplicate dois 
WITH TABLE_DOIS AS (

SELECT 
doi 
FROM (SELECT doi, CASE WHEN (SELECT COUNT(1) FROM UNNEST(indexed_in) AS i WHERE i = "crossref") > 0 THEN TRUE ELSE FALSE END as is_crossref_doi FROM `subugoe-collaborative.openalex_walden.works` ) WHERE is_crossref_doi

),

--- collect relevant variables from OpenAlex to reproduce Unpaywall structure
TABLE_VAR AS (
  
SELECT

struct(
  best_oa_location.source.type as host_type, 
  null as is_best, --- not disrectly available as locations variable anymore
  best_oa_location.license,
  null as oa_date, --- this has been deprecated
  null as pmh_id, --- not in OpenAlex, could use best_oa_location.id which can be pmh_id. NB this will be included in next SUB ingest of OpenAlex
  IFNULL(best_oa_location.pdf_url,best_oa_location.landing_page_url) as url,
  best_oa_location.landing_page_url as url_for_landing_page,
  best_oa_location.pdf_url as url_for_pdf,
  best_oa_location.version,
  IF(best_oa_location.source.type = "repository", best_oa_location.source.host_organization_name, null) as repository_institution,
  null as endpoint_id, -- not documented as UPW variable, l.id can be used as needed (from next SUB ingest)
  null as id, -- not documented as UPW variable, l.id can be used as needed (from next SUB ingest)
  "deprecated" as evidence, -- will be fully deprecated
  "deprecated" as updated --- will be fully deprecated
  ) as best_oa_location, 
  
a.doi,
CONCAT("https://doi.org/", a.doi) as doi_url,
c.type as genre, --- taken directly from Crossref to be comparable with UPW
is_paratext,
open_access.is_oa as is_oa,
if(primary_location.source.type = "journal", primary_location.source.is_in_doaj, null) as journal_is_in_doaj,
if(primary_location.source.type = "journal", primary_location.source.is_oa, null) as journal_is_oa,
if(primary_location.source.type = "journal", primary_location.source.issn, null) as journal_issns,
if(primary_location.source.type = "journal", primary_location.source.issn_l, null) as journal_issn_l,
if(primary_location.source.type = "journal", primary_location.source.display_name, null) as journal_name,

(SELECT array_agg(struct(
  l.source.type as host_type, 
  null as is_best, --- not disrectly available as locations variable anymore
  l.license,
  null as oa_date, --- this has been deprecated
  null as pmh_id, --- not in OpenAlex, could use best_oa_location.id which can be pmh_id. NB this will be included in next SUB ingest of OpenAlex
  IFNULL(l.pdf_url,l.landing_page_url) as url,
  l.landing_page_url as url_for_landing_page,
  l.pdf_url as url_for_pdf,
  l.version,
  IF(l.source.type = "repository", l.source.host_organization_name, null) as repository_institution,
  null as endpoint_id, -- not documented as UPW variable, l.id can be used as needed (from next SUB ingest)
  null as id, -- not documented as UPW variable, l.id can be used as needed (from next SUB ingest)
  "deprecated" as evidence, -- will be fully deprecated
  "deprecated" as updated --- will be fully deprecated
  ))
  FROM  unnest(locations) as l WHERE l.is_oa is true) as oa_locations,

null as first_oa_location, --- this was based on oa_date, and cannot currently be reconstructed
open_access.oa_status as oa_status,
publication_date as published_date,
if(primary_location.source.type = "journal", primary_location.source.host_organization_name, null) as publisher,
b.title, --- ambiguous without table specification as present in OpenAlex and Crossref
updated_date as updated, -- this reflects any update in the OpenAlex record
publication_year as year,
open_access.any_repository_has_fulltext as has_repository_copy,
if(primary_location.source.type = "journal", primary_location.source.issn_l, null) as issn_l,

(SELECT array_agg(struct(
  l.source.type as host_type, 
  null as is_best, --- not disrectly available as locations variable anymore
  l.license,
  null as oa_date, --- this has been deprecated
  null as pmh_id, --- not in OpenAlex, could use best_oa_location.id which can be pmh_id. NB this will be included in next SUB ingest of OpenAlex
  IFNULL(l.pdf_url,l.landing_page_url) as url,
  l.landing_page_url as url_for_landing_page,
  l.pdf_url as url_for_pdf,
  l.version,
  IF(l.source.type = "repository", l.source.host_organization_name, null) as repository_institution,
  null as endpoint_id, --- not clear what this represents, as UPW values are different from pmh_id; l.id could be used as needed (from next SUB ingest)
  ---null as id, -- not documented as UPW variable, l.id can be used as needed (from next SUB ingest)
  "deprecated" as evidence, -- will be fully deprecated
  "deprecated" as updated --- will be fully deprecated
  ))
  FROM  unnest(locations) as l WHERE l.is_oa is not true) as oa_locations_embargoed, -- can only indicate all closed locations, without reliable assessment of embargo

  --- null as x_reported_noncompliant_copies, -- this cannot be reconstructed; does not seem to be part of UPW data currently
  --- null as x_error, --- this cannot be reconstructed; does not seem to be part of UPW data currently
  
  (SELECT array_agg(struct(
  au.raw_affiliation_strings, 
  au.is_corresponding,
  au.raw_author_name,
  au.author_position))
  FROM  unnest(authorships) as au) as z_authors   


FROM TABLE_DOIS as a
LEFT JOIN `subugoe-collaborative.openalex_walden.works` as b
USING (doi)
LEFT JOIN `subugoe-collaborative.cr_instant.snapshot` as c
ON LOWER(a.doi) = LOWER(c.doi)

)

SELECT * FROM TABLE_VAR