---set source table
WITH table_source as (

SELECT * FROM `subugoe-collaborative.cr_instant.snapshot` --- 20260131

),

--- deduplicate DOIs on created_date
 table_cleaned AS (

    SELECT
        papers.*

    FROM (SELECT DOI, ARRAY_AGG(DATE(created) ORDER BY DATE(created) DESC)[offset(0)] as var_dedup
    FROM table_source
    GROUP BY DOI) as dois

    LEFT JOIN table_source as papers
    ON papers.DOI = dois.DOI
    AND DATE(papers.created) = DATE(dois.var_dedup)
)

SELECT
    UPPER(TRIM(doi)) as source_id,
    UPPER(TRIM(doi)) as doi,
    RANK() OVER (ORDER BY is_referenced_by_count DESC, created DESC) as deduplication_rank,
    DATE(created) AS created_date,
    type,
    member,
    IF(issued is not null, EXTRACT(YEAR from issued), null) as published_year,

    CASE
        WHEN (SELECT COUNT(1) FROM UNNEST(author) AS authors WHERE authors.family is not null) > 0 THEN TRUE
        ELSE FALSE
    END
    as has_authors,
    ARRAY_LENGTH(author) as count_authors,
    CASE
        WHEN (SELECT COUNT(1) FROM UNNEST(author) AS authors WHERE authors.family is not null) > 0 THEN TRUE
        ELSE FALSE
    END
    as has_authors_string,
    ARRAY_LENGTH(author) as count_authors_string,
    CASE
        WHEN (SELECT COUNT(1) FROM UNNEST(author) AS authors WHERE authors.ORCID is not null) > 0 THEN TRUE
        ELSE FALSE
    END as has_authors_id_orcid,
    (SELECT COUNT(1) FROM UNNEST(author) AS authors WHERE authors.ORCID is not null) as count_authors_id_orcid,
    CASE
        WHEN (SELECT COUNT(1) FROM UNNEST(author) AS authors WHERE authors.sequence is not null) > 0 THEN TRUE
        ELSE FALSE
    END as has_authors_sequence,
    (SELECT COUNT(1) FROM UNNEST(author) AS authors WHERE authors.sequence is not null) as count_authors_sequence,

    CASE
        WHEN (SELECT COUNT(1) FROM UNNEST(author) AS authors, UNNEST(authors.affiliation) AS affiliation WHERE affiliation.name is not null) > 0 THEN TRUE
        ELSE FALSE
    END
    as has_affiliations,
    (SELECT COUNT(1) FROM UNNEST(author) AS authors, UNNEST(authors.affiliation) AS affiliation WHERE affiliation.name is not null) as count_affiliations,
    CASE
        WHEN (SELECT COUNT(1) FROM UNNEST(author) AS authors, UNNEST(authors.affiliation) AS affiliation WHERE affiliation.name is not null) > 0 THEN TRUE
        ELSE FALSE
    END
    as has_affiliations_string,
    (SELECT COUNT(1) FROM UNNEST(author) AS authors, UNNEST(authors.affiliation) AS affiliation WHERE affiliation.name is not null) as count_affiliations_string,
     CASE
        WHEN (SELECT COUNT(1) FROM UNNEST(author) AS authors, UNNEST(authors.affiliation) AS affiliation, UNNEST (affiliation.id) AS affiliation_id WHERE (affiliation_id.id is not null AND affiliation_id.id_type = 'ROR')) > 0 THEN TRUE
        ELSE FALSE
    END
    as has_affiliations_id_ror,
    (SELECT COUNT(1) FROM UNNEST(author) AS authors, UNNEST(authors.affiliation) AS affiliation, UNNEST (affiliation.id) AS affiliation_id WHERE (affiliation_id.id is not null AND affiliation_id.id_type = 'ROR')) as count_affiliations_id_ror,

    CASE
        WHEN (abstract is not null) THEN TRUE
        ELSE FALSE
    END
    as has_abstract,
    LENGTH(abstract) as count_abstract,

    -- Citations
    CASE
        WHEN is_referenced_by_count > 0 THEN TRUE
        ELSE FALSE
    END
    as has_citations,
    is_referenced_by_count as count_citations,

    -- References
    CASE
        WHEN references_count > 0 THEN TRUE
        ELSE FALSE
    END
    as has_references,
    references_count as count_references,

    -- Fields
    CASE
        WHEN ARRAY_LENGTH(subject) > 0 THEN subject[OFFSET(0)]
        ELSE null
    END as top_field,
    CASE
        WHEN ARRAY_LENGTH(subject) > 0 THEN TRUE
        ELSE FALSE
    END as has_fields,
    CASE
        WHEN ARRAY_LENGTH(subject) > 0 THEN ARRAY_LENGTH(subject)
        ELSE null
    END as count_fields,

    -- Venue
    -- In current dataset (20260131) container_title is string, not array of strings
    CASE
        ---WHEN ARRAY_LENGTH(container_title) > 0 THEN TRUE
        WHEN container_title is not null THEN TRUE
        ELSE FALSE
        END
    as has_venue,
    ---ARRAY_LENGTH(container_title) as count_venue,
    null as count_venue,
    CASE
        ---WHEN ARRAY_LENGTH(container_title) > 0 THEN TRUE
        WHEN container_title is not null THEN TRUE
        ELSE FALSE
        END
    as has_venue_string,
    ---ARRAY_LENGTH(container_title) as count_venue_string,
    null as count_venue_string,
    CASE
        WHEN ARRAY_LENGTH(issn_type) > 0 THEN TRUE
        ELSE FALSE
        END
    as has_venue_id_issn,
    ARRAY_LENGTH(issn_type) as count_venue_id_issn,

    -- Funder
    -- use ARRAY_LENGTH for funders as not all funder records have funder name
    -- also include Funder DOIs as source ids (to enable comparison with Funder IDs in other systems)
    CASE
        WHEN ARRAY_LENGTH(funder) > 0 THEN TRUE
        ELSE FALSE
    END as has_funders,
    ARRAY_LENGTH(funder) as count_funders,
    CASE
        WHEN (SELECT COUNT(1) FROM UNNEST(funder) AS funders WHERE funders.name is not null) > 0 THEN TRUE
        ELSE FALSE
    END
    as has_funders_string,
    (SELECT COUNT(1) FROM UNNEST(funder) AS funders WHERE funders.name is not null) as count_funders_string,
    CASE WHEN (SELECT COUNT(1) FROM UNNEST(funder) AS funders, UNNEST (funders.id) WHERE id_type = "DOI") > 0 THEN TRUE 
        ELSE FALSE 
    END 
    as has_funders_id_source,
   (SELECT COUNT(1) FROM UNNEST(funder) AS funders, UNNEST (funders.id) WHERE id_type = "DOI") as count_funders_id_source,
    CASE WHEN (SELECT COUNT(1) FROM UNNEST(funder) AS funders, UNNEST (funders.id) WHERE id_type = "DOI") > 0 THEN TRUE 
        ELSE FALSE 
    END 
    as has_funders_id_doi,
   (SELECT COUNT(1) FROM UNNEST(funder) AS funders, UNNEST (funders.id) WHERE id_type = "DOI") as count_funders_id_doi,
     CASE WHEN (SELECT COUNT(1) FROM UNNEST(funder) AS funders, UNNEST (funders.id) WHERE id_type = "ROR") > 0 THEN TRUE 
        ELSE FALSE 
    END 
    as has_funders_id_ror,
   (SELECT COUNT(1) FROM UNNEST(funder) AS funders, UNNEST (funders.id) WHERE id_type = "ROR") as count_funders_id_ror,


FROM table_cleaned