[*Note: This repository is hosted on [Codeberg](https://codeberg.org/TwoBirds/metadata_ingest/) and mirrored to [Github](https://github.com/bmkramer/metadata_ingest)*] 

# Metadata ingest 

Metadata ingest from various open data sources into Google Big Query (GBQ) project [SOS Datasources](https://console.cloud.google.com/bigquery?hl=en&project=sos-datasources) to make them publicly available for analysis and combination with other open datasets available via Google Big Query. 

Currently, the tables in the GBQ dataset SOS Datasources are stored in location US (multiple regions) for interoperability reasons. This may change in future, e.g. to host the tables in location EU with a miror hosted in location US to maintain existing interoperability across regions.

To use the data for your own analysis, you would need your own [Google Cloud project](https://console.cloud.google.com/projectcreate), to which processing/compute costs would be billed. There's a [free trial period](https://cloud.google.com/free/docs/free-cloud-features) during which you have $300 credit, and there is a [free tier](https://cloud.google.com/bigquery/pricing) of 1 TB processing per month.

Dataset collection maintained by [Bianda Kramer](https://orcid.org/0000-0002-5965-6560) and [Cameron Neylon](https://orcid.org/0000-0002-0068-716X). 

## Workflow

_(this could also be wrapped in e.g. a Python script)_ 

- download datafile(s) to local
- extract folder(s) where applicable
- make any modifications to internal files for compatibility with Google BigQuery
- upload folder(s) with compressed json files (json.gz or jsonl.gz) to a Google Cloud Storage (GCS) bucket
- (optional: extract all files using a [Dataflow template](https://cloud.google.com/dataflow/docs/guides/templates/provided/bulk-decompress-cloud-storage))
- create table in the GBQ web UI from the json files in GCS, providing the schema as json  
  (NB fields in the schema that are missing in some of the records will be safely nulled for that record)

For large datasets, this workflow is carried out in batches.

This workflow assumes data can be imported 'as is'. In cases where data first need to be transformed (i.e. to replace dashes with underscores in variable names), this is preferably done locally, using Python scripts. Alternatively, the extracted JSONL files are can first be ingested as csv (1 string per record) and transformed in Big Query using an SQL script. The transformed table is then exported to a GCS bucket as jsonl (with or without compression) and re-imported from there.     

For each data source, JSON schemas and (where applicable) SQL and/or Python scripts used for transformation are available in the folder [databases](./databases).

Tables are currently not partitioned or clustered - this would be a useful future approach to save on computing costs

## Data sources

- **Butler APCs**
  - source and documentation:
    - https://doi.org/10.7910/DVN/CR1MMV (documentation)
    - apclist_by_journal_year: https://dataverse.harvard.edu/file.xhtml?fileId=10272826&version=1.0 (download)
    - journal_level_apcs: https://dataverse.harvard.edu/file.xhtml?fileId=10272829&version=1.0 (download)
  - release date: 2024-06-12
  - [JSON schemas](./databases/butler_apcs/schema/) (automatic schema detection from csv)
  - notes:
    - An open dataset of article processing charges from six large scholarly publishers (2019-2023)

- **Crossref public data file**
  - source and documentation: https://www.crossref.org/learning/public-data-file/
  - release date: 2025-03-12
  - [JSON schema](./databases/crossref/schema/crossref_public_datafile_202503.json) modified from Curtin Open Knowledge Institute (COKI) [Academic Observatory Workflows](https://github.com/The-Academic-Observatory/academic-observatory-workflows/tree/main/academic-observatory-workflows/academic_observatory_workflows/crossref_metadata_telescope/schema)
  - [SQL processing scripts](./databases/crossref/sql/)
  - notes:
    - the dataset in Google Big Query currently contains 2 tables:
      - full public data file (167,008,748 records)
      - data file sample (10,000 records)
 
- **Crossref members** (data underlying the Crossref API members endpoint) 
  - source and documentation: https://api.crossref.org/swagger-ui/index.html#/Members
  - sample date: 2026-01-05 (previous versions 2025-05-31, 2025-12-31)
  - [JSON schema](./databases/crossref/schema/crossref_members_schema.json)

- **Crossref journals** (data underlying the Crossref API journals endpoint)
  - source and documentation: https://api.crossref.org/swagger-ui/index.html#/Journals
  - sample date: 2026-01-05 (previous versions 2025-05-31, 2025-12-31)
  - [JSON schema](./databases/crossref/schema/crossref_members_schema.json)

- **DataCite public data file** 
  - source and documentation: https://datafiles.datacite.org/datafiles/public-2025
  - release date: 2026-01-06
  - [JSON schema](./databases/datacite/schema/datacite_public_datafile_202601.json)
  - [Python script for preprocessing](https://codeberg.org/cameronneylon/schema-wash) [on Codeberg]

- **DOAJ**
  - source and documentation:
    - https://doaj.org/docs/public-data-dump/ (documentation)
    - https://doaj.org/csv (download)
  - release date: 2026-01-03 (previous version 2025-07-31)
  - notes:
    - [JSON schema](./databases/doaj/schema/doaj.json)) (automatic schema detection from csv)
    - DOAJ also makes data snapshot availabe as JSON file

- **GOA** (Walt Crawford Gold Open Access datasets)
  - source and documentation:
    - GOA5 (2014-2019) https://doi.org/10.6084/m9.figshare.12543080
    - GOA6 (2015-2020) https://doi.org/10.6084/m9.figshare.14787888
    - GOA7 (2016-2021) https://doi.org/10.6084/m9.figshare.19929179
    - GOA8 (2017-2022) https://doi.org/10.6084/m9.figshare.23203955
    - GOA9 (2019-2023) https://doi.org/10.6084/m9.figshare.25892869  
    - GOA10 (2020-2024) https://doi.org/10.6084/m9.figshare.29146061
  - notes:
    - [JSON schema GOA10](./databases/doaj/schema/goa10.json) (automatic schema detection from csv)
    - For GOA10 only, a version (GOA10_all) with both included and excluded journals is available, next to the regular version with only included journals (GOA10). 

- **OpenAIRE**
  - source and documentation: https://doi.org/10.5281/zenodo.17098012
  - release date: 2025-09-12
  - [JSON schemas](./databases/openaire/schema/)
  - [Python script to count and split tables](./databases/openaire//count_and_split.py)
  - [overview of relation tables (csv)](./databases/openaire/relation_tables_20250912.csv)
  - notes:
    - the dataset in Google Big Query contains separate tables for the different entities in the OpenAIRE graph:
      - products (publications, datasets, software, other research products)
      - datasources
      - organizations
      - projects
      - communities
      - relations (tables indicating the relation between the different entities)
    - the relation tables are provided as subsets of the full relation table, split by type of entities and (for product-product relations) type of relationship. For all reciprocal relationships, only one side is provided. This was done to save on processing as well as downstream computing costs.

- **OpenCitations Meta** [to be updated to latest version]
  - source and documentation:
      - https://download.opencitations.net/#meta (documentation)
      - https://doi.org/10.6084/m9.figshare.21747461.v9 (download)
  - release date: 2024-06-20
  - [JSON schema](./databases/opencitations/schema/)
  - SQL processing scripts [none]
  - notes:
    - the OpenCitations Meta database contains bibliographic metadata for all publications involved in the OpenCitations Index

- **PKP**
  - source and documentation: https://doi.org/10.7910/DVN/OCZNVY
  - release date: 2025-11-21 (previous version 2024-12-02)
  - [JSON schema](./databases/pkp/schema/)

- **ROR**
  - source and documentation:
    - https://ror.readme.io/docs/data-dump (documentation)
    - https://doi.org/10.5281/zenodo.6347574 (download)
  - release date: 2026-01-29 
  - [JSON schema](./databases/ror/schema/)

  

- **Truthtables**
  - **Processed** tables indicating presence (TRUE/FALSE) and count of several metadata elemements for each record in a data source.
  - Created to facilitate comparison of metadata coverage across sources
  - Data sources:
      - Crossref (data snapshot 20260131)
      - OpenAlex (data snapshot 20260202)
      - OpenAIRE (data snapshot 20250912)
      - DataCite (to be added)
  - metadata elements: abstract, authors (string and PIDs), affiliations (string and PIDs), references, citations, fields/subjects, venue and funders
  - [SQL processing scripts](./databases/truthtables/sql)