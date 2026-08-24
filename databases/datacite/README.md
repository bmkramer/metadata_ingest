Datacite Monthly Data file via SUBG
===================================

The DataCite monthly file is available for members and SUBG provides this to ORION specifically via an online bucket.
This script is run to download, process and upload the relevant DataCite file and is provided for transparency. 
Reuse will require access to a relevant bucket that provides access or the processing part can be run separately.

The script requires schema-wash to process the DataCite JSON (clean up of RelatedItems mostly) as well as rclone_python
and google cloud APIs. RClone requires an rclone config file including credentials and the Google Cloud file also
requires authentication to be setup for bucket upload. Currently the pipeline does not load the resulting files into
BigQuery as we are planning to refine the pipeline to only do updates as required, not a full reprocess.