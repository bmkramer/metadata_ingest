SELECT 

* EXCEPT (roles),
JSON_VALUE_ARRAY(JSON_STRIP_NULLS(roles)) as roles
--- JSON_STRIP_NULLS removes null values within arrays
--- cases where variable is null will be transformed into empty arrays

FROM `sos-datasources.upload.openaire_person_authorship_202608` 