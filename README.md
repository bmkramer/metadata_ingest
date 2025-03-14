# Metadata ingest 

Metadata ingest from various open data sources

#Workflow

- download datafile to local
- extract folder(s) where applicable
- upload folder(s) with compressed json files (json.gz) to a GCS bucket
- extract all files using a [Dataflow template](https://cloud.google.com/dataflow/docs/guides/templates/provided/bulk-decompress-cloud-storage)
- create a table in the GBQ web UI from the json files in GCS, providing the schema as json

Schemas per data source in folder [\databases]

------------------

Data sources included:

- Crossref public data file (2025-03-13)
- DataCite public data file 2024 
- OpenAIRE graph data (2025-02-11)