--- source:
---https://cloud.google.com/blog/products/data-analytics/load-your-json-data-into-bigquery-despite-wacky-formatting/
---(afterwards, select * from 'external table' to create  table in situ)

CREATE OR REPLACE EXTERNAL TABLE `sos-datasources.crossref_metadata.0_json_string` (

col1 STRING
)
OPTIONS (
format = 'CSV',
/*
* The Control-P delimiter ‘\x10’ is a non-printing character not likely to be
* found in your data so it’s used as a delimiter to load
* the entire JSON data as if it were a 1-column CSV.
*/
field_delimiter = '\x10',
/*
* Set quote option to an empty string since the data
* does not contain CSV quoted sections and the default quote character,
* double quotes, can otherwise cause issues when parsing JSON as CSV.
*/
quote = '',
uris = ['gs://crossref_metadata/crossref_unzipped/*.jsonl']
--- works with wildcard
--- only works with unzipped files!
);
