from pathlib import Path
from datetime import date
from schemawash import lib

from rclone_python import rclone
from google.cloud.storage import Client, transfer_manager

import logging

"""Note that it is necessary to use the --local-no-set-modtime option to be able to write to the CIFS network drive"""

d = date.today()
run_id = f'{d.year}{d.month:02d}{d.day:02d}'
source = 'sub-bigschol:bigschol/monthly-datafile.datacite.org/'
dest = Path('###') # Your path for the raw data here
processed = Path(f'###_{run_id}') # Your path for processed data
logfile = f'{run_id}.log'
config_path = Path("###").expanduser() # Your path for rclone config

logger = logging.getLogger(__name__)
logging.basicConfig(filename=logfile, encoding='utf-8', level=logging.DEBUG)


### Download
logging.info(f"Starting rclone")
logging.info(f"config path = {config_path}")
logging.info(f"Target path = {dest}")
rclone.set_config_file(config_path)
rclone.copy(source, dest, args = ['--local-no-set-modtime'])

### Process
lib.generate_schema_for_dataset(
        dest,
        processed,
        'data_sources/datacite_metadata.yaml',
        3,
        True,
        'jsonl.gz')

### Upload
storage_client = Client()
bucket = storage_client.bucket('sos_data_transfer')
paths = processed.rglob('*')

string_paths = [str(path.relative_to(processed)) for path in paths if path.is_file()]

logging.info("Found {} files.".format(len(string_paths)))

# Start the upload.
results = transfer_manager.upload_many_from_filenames(
        bucket, string_paths, source_directory=processed, blob_name_prefix='datacite-202604/', max_workers=3
)

for name, result in zip(string_paths, results):
        # The results list is either `None` or an exception for each filename in
        # the input list, in order.

        if isinstance(result, Exception):
                logging.debug("Failed to upload {} due to exception: {}".format(name, result))
        else:
                logger.debug("Uploaded {} to {}.".format(name, bucket.name))


