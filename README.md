# Metadata ingest 

Metadata ingest from various open data sources into Google Big Query (GBQ) project [SOS Datasources](https://console.cloud.google.com/bigquery?ws=!1m4!1m3!3m2!1ssos-datasources) to make them publicly available for analysis and combination with other open datasets available via Google Big Query.

To use the data for your own analysis, you would need your own [Google Cloud project](https://console.cloud.google.com/projectcreate), to which processing/compute costs would be billed. There's a [free trial period](https://cloud.google.com/free/docs/free-cloud-features) during which you have $300 credit, and there is a [free tier](https://cloud.google.com/bigquery/pricing) of 1 TB processing per month.

## Workflow

_(this still needs to be wrapped in e.g. a Python script)_ 

- download datafile(s) to local
- extract folder(s) where applicable
- upload folder(s) with compressed json files (json.gz or jsonl.gz) to a Google Cloud Storage (GCS) bucket
- (optional: extract all files using a [Dataflow template](https://cloud.google.com/dataflow/docs/guides/templates/provided/bulk-decompress-cloud-storage))
- create table in the GBQ web UI from the json files in GCS, providing the schema as json  
  (NB fields in the schema that are missing in some of the records will be safely nulled for that record)

For large datasets, this workflow is carried out in batches.

This workflow assumes data can be imported 'as is'. In cases where data first need to be transformed (i.e. to replace dashes with underscores in variable names), the extracted JSONL files are first read as csv (1 string per record) and transformed in Big Query using an SQL script. The transformed table is then exported to a GCS bucket as jsonl (with or without compression) and re-imported from there.  
_(NB These steps are resource intensive, and in future probably better done locally)_    

For each data source, JSON schemas and (where applicable) SQL scripts used for ingest and transformation are available in the folder [databases](/databases).

Currently, the tables in the GBQ dataset SOS Datasources are stored in location US (multiple regions) for interoperability reasons. This may change in future. 

Tables are currently not partitioned or clustered - this would be a useful future approach to save on computing costs

## Data sources

- **Crossref public data file**
  - source and documentation: https://www.crossref.org/learning/public-data-file/
  - release date: 2025-03-12
  - [JSON schema](/databases/crossref/schema/crossref_public_datafile_202503.json) modified from Curtin Open Knowledge Institute (COKI) [Academic Observatory Workflows](https://github.com/The-Academic-Observatory/academic-observatory-workflows/tree/main/academic-observatory-workflows/academic_observatory_workflows/crossref_metadata_telescope/schema)
  - [SQL processing scripts](/databases/crossref/sql/)
  - notes:
    - the dataset in Google Big Query currently contains 2 tables:
      - full public data file (167,008,748 records)
      - data file sample (10,000 records)
 
- **Crossref members** (data underlying the Crossref API members endpoint) 
  - source and documentation: https://api.crossref.org/swagger-ui/index.html#/Members
  - sample date: 2025-05-31
  - [JSON schema](/databases/crossref/schema/crossref_members_schema.json)

- **Crossref journals** (data underlying the Crossref API journals endpoint)
  - source and documentation: https://api.crossref.org/swagger-ui/index.html#/Journals
  - sample date: 2025-05-31
  - [JSON schema](/databases/crossref/schema/crossref_members_schema.json)

- **DataCite public data file**  [IN PROGRESS]
  - source and documentation: https://datafiles.datacite.org/datafiles/public-2024
  - release date: 2025-01-06

- **OpenAIRE**
  - source and documentation: https://doi.org/10.5281/zenodo.14851262
  - release date: 2025-02-11
  - [JSON schemas](/databases/openaire/schema/)
  - [SQL processing scripts](/databases/openaire/sql/)
  - notes:
    - the dataset in Google Big Query contains separate tables for the different entities in the OpenAIRE graph:
      - products (publications, datasets, software, other research products)
      - datasources
      - organizations
      - projects
      - communities
      - relations (tables indicating the relation between the different entities)
    - the relation tables are provided as subsets of the full relation table, split by type of entity and (for product-product relations) type of relationship. This was done to save on downstream computing costs.

- **OpenCitations Meta** [to be updated to latest version]
  - source and documentation: https://doi.org/10.5281/zenodo.14851262
  - release date: 2025-02-11
  - [JSON schemas](/databases/opencitations/schema/)
  - [SQL processing scripts](/databases/opencitations/sql/)

- **PKP**
  - source and documentation: https://doi.org/10.7910/DVN/OCZNVY
  - release date: 2024-12-02
  - [JSON schema](/databases/pkp/schema/)
  - [SQL processing scripts](/databases/pkp/sql/)
