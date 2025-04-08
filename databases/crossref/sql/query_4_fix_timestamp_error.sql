--- there are a couple of instances of date-parts where the year has 5 digits
--- in these cases, the derived timestamp is out of bounds, resulting in an error upon import as josn
--- the code below (to be run manually for now) searches for these instances, and then provides the code to fix them
--- current approach completely removed the timestamp, which is not optimal :)


--- find instance(s) where year in date-parts has 5 digits

SELECT

col1

FROM `sos-datasources.crossref_metadata.0_json_string_table`
WHERE REGEXP_CONTAINS(col1, r'("date-time": ")(\d{5})')

--- apply code below to fix these instances, replacing the data-parts string with the value found
----
---SELECT

---REPLACE(
---col1,
---{"date-parts": [[20201, 4, 26]], "date-time": "20201-04-26T00:00:00Z", "timestamp": 575324726400000}',
---{"date-parts": [[2021, 4, 26]], "date-time": "2021-04-26T00:00:00Z"}') as col1

---FROM `sos-datasources.crossref_metadata.0_json_string_table`
