--- Script to reconstruct Unpaywall data structure from OpenAlex, to serve use cases that are dependent on Unpaywall structure 
--- Note: 20260423 Currently in progress, not equivalent yet! 


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

best_oa_location, -- need to be selected within
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
locations as oa_locations, -- need to be filtered and selected within
--- first_oa_location, --- this was based on oa_date, and cannot currently be reconstructed
open_access.oa_status as oa_status,
publication_date as published_date,
if(primary_location.source.type = "journal", primary_location.source.host_organization_name, null) as publisher,
b.title, --- ambiguous without table specification as present in OpenAlex and Crossref
updated_date as updated, -- this reflects any update in the OpenAlex record
publication_year as year,
open_access.any_repository_has_fulltext as has_repository_copy,
if(primary_location.source.type = "journal", primary_location.source.issn_l, null) as issn_l,
locations as oa_locations_embargoed, -- need to be filtered and selected within, can only indicated all closed locations, without reliable assessment of embargo
---x_reported_noncompliant_copies -- this cannot be reconstructed
---x_error, --- this cannot be reconstructed,
authorships as z_authors, --- need to be selected within


FROM TABLE_DOIS as a
LEFT JOIN `subugoe-collaborative.openalex_walden.works` as b
USING (doi)
LEFT JOIN `subugoe-collaborative.cr_instant.snapshot` as c
ON LOWER(a.doi) = LOWER(c.doi)

)

SELECT * FROM TABLE_VAR