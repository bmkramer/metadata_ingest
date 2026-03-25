SELECT

a.doi,
b.source_id as openaire_id,
has_funders,
count_funders,
has_funders_id_source,
has_funders_string


FROM `sos-project-space.TEMP.dois_nwo` as a
LEFT JOIN `sos-datasources.openaire_update.openaire_truthtable_20260129` as b
ON UPPER(a.doi) = UPPER(b.doi)