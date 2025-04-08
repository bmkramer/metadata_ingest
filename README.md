# Metadata ingest 

Metadata ingest from various open data sources into Google Big Query project [SOS Datasources](https://console.cloud.google.com/bigquery?ws=!1m4!1m3!3m2!1ssos-datasources) and make them publicly available for use. 

To use the data for your own analysis, you would need your own [Google Cloud project](https://console.cloud.google.com/projectcreate), to which processing/compute costs would be billed. There's a [free trial period](https://cloud.google.com/free/docs/free-cloud-features) during which you have $300 credit, and there is a [free tier](https://cloud.google.com/bigquery/pricing) of 1 TB processing per month.

## Workflow

(in future, this needs to be wrapped in e.g. a Python script) 

- download datafile to local
- extract folder(s) where applicable
- upload folder(s) with compressed json files (json.gz or jsonl.gz) to a GCS bucket
- (optional: extract all files using a [Dataflow template](https://cloud.google.com/dataflow/docs/guides/templates/provided/bulk-decompress-cloud-storage))
- create a table in the GBQ web UI from the json files in GCS, providing the schema as json

Schemas per data source in folder [/databases]

## Data sources

- Crossref public data file (2025-03-13)
