# Metadata ingest 

Metadata ingest from various open data sources into Google Big Query (GBQ) project [SOS Datasources](https://console.cloud.google.com/bigquery?ws=!1m4!1m3!3m2!1ssos-datasources) and make them publicly available for use. 

To use the data for your own analysis, you would need your own [Google Cloud project](https://console.cloud.google.com/projectcreate), to which processing/compute costs would be billed. There's a [free trial period](https://cloud.google.com/free/docs/free-cloud-features) during which you have $300 credit, and there is a [free tier](https://cloud.google.com/bigquery/pricing) of 1 TB processing per month.

## Workflow

_(this still needs to be wrapped in e.g. a Python script)_ 

- download datafile to local
- extract folder(s) where applicable
- upload folder(s) with compressed json files (json.gz or jsonl.gz) to a Google Cloud Storage (GCS) bucket
- (optional: extract all files using a [Dataflow template](https://cloud.google.com/dataflow/docs/guides/templates/provided/bulk-decompress-cloud-storage))
- create a table in the GBQ web UI from the json files in GCS, providing the schema as json

This workflow assumes data can be imported 'as is'. In cases where data first need to be transformed (i.e. to replace dashes with underscores in variable names), the extracted JSONL files are first read as csv (1 string per record) and transformed in Big Query using an SQL script. The transformed table is then exported to a GCS bucket as jsonl (with or without compression and re-imported from there.
_(NB In future implementation, this step is probably better done locally for efficiencty)_    

JSON schemas and SQL scripts used for ingest and transformation are available in folder [/databases]

## Data sources

- Crossref public data file (2025-03-13)
- - fefd
